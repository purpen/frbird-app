//
//  THNMyOrderViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-16.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNMyOrderViewController.h"
#import "JYComHttpRequest.h"
#import "NSMutableDictionary+AddSign.h"
#import "THNUserManager.h"
#import "THNOrder.h"
#import "THNProductBrief.h"
#import <UIImageView+WebCache.h>
#import "RKFootFreshView.h"
#import "THNPayViewController.h"
#import "THNErrorPage.h"

#define PaybuttonTag__      493300

@interface THNMyOrderViewController ()<UITableViewDataSource, UITableViewDelegate, JYComHttpRequestDelegate>
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, strong) RKFootFreshView *loadFooterView;
@property (nonatomic, assign) BOOL loadingmore;
@end

@implementation THNMyOrderViewController
{
    BOOL                    _nibsRegistered;
    
    JYComHttpRequest        *_request;
    NSMutableArray          *_orderArray;
    BOOL                    _afterRequest;
    
    int                     _requestStatus;
    
    NSInteger               _currentPage;
    NSInteger               _totalPage;
}
@synthesize loadFooterView = _loadFooterView, loadingmore = _loadingmore;

- (void)dealloc
{
    [self.tableView setDelegate:nil];
    [self.tableView setDataSource:nil];
    [_request clearDelegatesAndCancel];
    _request = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的订单";
    _nibsRegistered = NO;
    _afterRequest = NO;
    _requestStatus = 9999;
    _currentPage = 1;
    _totalPage = MAXFLOAT;
    self.view.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0  blue:248/255.0  alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0  blue:248/255.0  alpha:1.0];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, -5, 10, 25)];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    view.backgroundColor = UIColorFromRGB(0xf8f8f8);
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"全部", @"未支付", @"待收货", nil]];
    segment.tintColor = [UIColor SecondColor];
    segment.selectedSegmentIndex = 0;
    [segment addTarget:self action:@selector(timeChange:)
      forControlEvents:UIControlEventValueChanged];
    segment.frame = CGRectMake(15, 14, SCREEN_WIDTH-15*2, 58/2);
    [view addSubview:segment];
    
    self.tableView.tableHeaderView = view;
    
    _loadFooterView = [[RKFootFreshView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.f)];
    self.loadingmore = NO;
    self.tableView.tableFooterView = self.loadFooterView;
    
    [self requestForOrderList:(int)_currentPage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestForOrderList:(int)page
{
    if (!_orderArray) {
        _orderArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[THNUserManager sharedTHNUserManager] userid],    @"current_user_id",
                                     [NSString stringWithFormat:@"%d",page],            @"page",
                                     [THNUserManager channel],                          @"channel",
                                     [THNUserManager client_id],                        @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],      @"uuid",
                                     @"8",                                             @"size",
                                     [THNUserManager time],                             @"time",
                                     nil];
    if (_requestStatus<9998) {
        [listPara setObject:[NSString stringWithFormat:@"%d",_requestStatus] forKey:@"status"];
    }
    [listPara addSign];
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiMyOrder]];
    if (page==1) {
        [self showLoadingWithAni:YES];
    }
}

#pragma mark table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _afterRequest?[_orderArray count]:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 44.0000001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    THNOrder *order = [_orderArray objectAtIndex:section];
    return order.orderStatus==1?44.0000001:0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"THNOrderItem";
    if (!_nibsRegistered) {
        UINib *mainNib = [UINib nibWithNibName:@"THNOrderItem" bundle:nil];
        [tableView registerNib:mainNib forCellReuseIdentifier:CellIdentifier];
        _nibsRegistered = YES;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    THNOrder *order = [_orderArray objectAtIndex:indexPath.section];
    THNProductBrief *product = [order.orderItems objectAtIndex:indexPath.row];
    //图片
    [((UIImageView *)[cell viewWithTag:32101]) sd_setImageWithURL:[NSURL URLWithString:product.productImage]];
    //标题
    ((UILabel *)[cell viewWithTag:32102]).text = product.productTitle;
    //价格
    ((UILabel *)[cell viewWithTag:32105]).text = [NSString stringWithFormat:@"￥%@",product.productSalePrice];
    //ID
    ((UILabel *)[cell viewWithTag:32103]).text = [NSString stringWithFormat:@"编号:%@",product.productID];
    return cell;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    THNOrder *order = [_orderArray objectAtIndex:section];
    return [order.orderItems count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    THNOrder *order = [_orderArray objectAtIndex:section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    view.backgroundColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1.0];
    UILabel *orderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, SCREEN_WIDTH-80, 13)];
    orderLabel.backgroundColor = [UIColor clearColor];
    orderLabel.textColor = [UIColor BlackTextColor];
    orderLabel.font = [UIFont systemFontOfSize:13];
    orderLabel.text = [NSString stringWithFormat:@"订单号:%@",order.orderID];
    [view addSubview:orderLabel];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, SCREEN_WIDTH-80, 13)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor BlackTextColor];
    nameLabel.font = [UIFont systemFontOfSize:13];
    nameLabel.text = [NSString stringWithFormat:@"收货人:%@",order.orderUserName];
    [view addSubview:nameLabel];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-86, 23, 86, 15)];
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.textColor = [UIColor BlackTextColor];
    dateLabel.font = [UIFont systemFontOfSize:15];
    dateLabel.text = order.orderStatusInfo;
    [view addSubview:dateLabel];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    THNOrder *order = [_orderArray objectAtIndex:section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    view.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    
    if (order.orderStatus == 1) {
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.tag = section;
        deleteButton.frame = CGRectMake(SCREEN_WIDTH-90, 7, 80, 25);
        [deleteButton setTitle:@"取消订单" forState:UIControlStateNormal];
        deleteButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [deleteButton setTitleColor:[UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0] forState:UIControlStateNormal];
        [deleteButton.layer setMasksToBounds:YES];
        [deleteButton.layer setCornerRadius:4.0];
        [deleteButton.layer setBorderWidth:.5]; //边框宽度
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 100/255.0, 100/255.0, 100/255.0, 1 });
        [deleteButton.layer setBorderColor:colorref];//边框颜色
        [deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:deleteButton];
        
        UIButton *payButton = [UIButton buttonWithType:UIButtonTypeCustom];
        payButton.frame = CGRectMake(SCREEN_WIDTH-180, 7, 80, 25);
        [payButton setTitle:@"立即支付" forState:UIControlStateNormal];
        payButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [payButton setTitleColor:[UIColor colorWithRed:255/255.0 green:51/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateNormal];
        [payButton.layer setMasksToBounds:YES];
        [payButton.layer setCornerRadius:4.0];
        [payButton.layer setBorderWidth:.5]; //边框宽度
        CGColorRef colorref2 = CGColorCreate(colorSpace,(CGFloat[]){ 255/255.0, 51/255.0, 102/255.0, 1 });
        [payButton.layer setBorderColor:colorref2];//边框颜色
        [payButton addTarget:self action:@selector(payButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        payButton.tag = PaybuttonTag__+section;
        [view addSubview:payButton];
    }else{
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
//        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        detailButton.frame = CGRectMake(SCREEN_WIDTH-90, 7, 80, 25);
//        [detailButton setTitle:@"订单详情" forState:UIControlStateNormal];
//        detailButton.titleLabel.font = [UIFont systemFontOfSize:15];
//        [detailButton setTitleColor:[UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0] forState:UIControlStateNormal];
//        [detailButton.layer setMasksToBounds:YES];
//        [detailButton.layer setCornerRadius:4.0];
//        [detailButton.layer setBorderWidth:.5]; //边框宽度
//        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 100/255.0, 100/255.0, 100/255.0, 1 });
//        [detailButton.layer setBorderColor:colorref];//边框颜色
//        [detailButton addTarget:self action:@selector(detailButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [view addSubview:detailButton];
    }
    
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - Button clicked
- (void)detailButtonClicked:(id)sender
{
    
}
- (void)payButtonClicked:(UIButton *)sender
{
    long section = sender.tag-PaybuttonTag__;
    THNOrder *order = [_orderArray objectAtIndex:section];
    
    //显示支付页面
    THNPayViewController *payView = [[THNPayViewController alloc] init];
    payView.orderID = order.orderID;
    payView.totalMoney = order.orderTotalMoney;
    [self.navigationController pushViewController:payView animated:YES];
}
- (void)deleteButtonClicked:(UIButton *)sender
{
    THNOrder *order = [_orderArray objectAtIndex:sender.tag];
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[THNUserManager sharedTHNUserManager] userid],    @"current_user_id",
                                     order.orderID,                                     @"rid",
                                     [THNUserManager channel],                          @"channel",
                                     [THNUserManager client_id],                        @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],      @"uuid",
                                     @"8",                                              @"size",
                                     [THNUserManager time],                             @"time",
                                     nil];
    [listPara addSign];
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiProductCancelOrder]];
    [self showLoadingWithAni:YES];
}

#pragma mark - Back
- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)timeChange:(UISegmentedControl *)sender
{
    int tmp = _requestStatus;
    if (sender.selectedSegmentIndex==1) {
        _requestStatus = 1;
    }else if(sender.selectedSegmentIndex==2){
        _requestStatus = 3;
    }else{
        _requestStatus = 9999;
    }
    
    if (_requestStatus != tmp) {
        [self.loadFooterView setEnabled:YES];
        [_orderArray removeAllObjects];
        _orderArray = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
        _currentPage = 1;
        [self requestForOrderList:(int)_currentPage];
    }
    
}
#pragma mark - delegate
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    if ([jyRequest.requestUrl hasSuffix:kTHNApiMyOrder]) {
        // 解析数据
        _afterRequest = YES;
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSArray *rows = [result objectForKey:@"rows"];
            _totalPage = [result intValueForKey:@"total_page"];
            for (NSDictionary *dict in rows) {
                THNOrder *order = [[THNOrder alloc] init];
                order.orderID = [dict stringValueForKey:@"rid"];
                order.orderTotalMoney = [dict floatValueForKey:@"total_money"];
                NSDictionary *expressInfo = [dict objectForKey:@"express_info"];
                if (expressInfo && [expressInfo isKindOfClass:[NSDictionary class]]) {
                    order.orderUserName = [expressInfo stringValueForKey:@"name"];
                }
                order.orderStatus = [dict intValueForKey:@"status"];
                NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:0];
                NSArray *arr = [dict objectForKey:@"items"];
                for (NSDictionary *item in arr) {
                    THNProductBrief *product = [[THNProductBrief alloc] init];
                    product.productID = [item stringValueForKey:@"product_id"];
                    product.productSalePrice = [item stringValueForKey:@"sale_price"];
                    product.productTitle = [item stringValueForKey:@"name"];
                    product.productImage = [item stringValueForKey:@"cover_url"];
                    [items addObject:product];
                }
                order.orderItems = items;
                [_orderArray addObject:order];
            }
        }
        if(self.loadingmore)
        {
            //刷新界面
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .3 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.loadFooterView.showActivityIndicator = NO;
                self.loadingmore = NO;
                self.view.userInteractionEnabled = YES;
                [_tableView reloadData];
            });
        }else{
            //刷新界面
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .3 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [_tableView reloadData];
                [self hideLoading];
            });
        }
    }else if([jyRequest.requestUrl hasSuffix:kTHNApiProductCancelOrder]){
        [self hideLoading];
//        [JDStatusBarNotification showWithStatus:@"取消订单成功"
//                                   dismissAfter:2.0
//                                      styleName:JDStatusBarStyleMatrix];
        [self alertWithInfo:@"取消订单成功"];
        [_orderArray removeAllObjects];
        _orderArray = nil;
        _currentPage = 1;
        [self.tableView reloadData];
        [self requestForOrderList:(int)_currentPage];
    }
    
    
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    _afterRequest = YES;
    NSString *errorInfo = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    if (self.loadingmore) {
        _currentPage--;
        self.loadFooterView.showActivityIndicator = NO;
        self.loadingmore = NO;
        self.view.userInteractionEnabled = YES;
//        [JDStatusBarNotification showWithStatus:errorInfo
//                                   dismissAfter:2.0
//                                      styleName:JDStatusBarStyleMatrix];
        [self alertWithInfo:errorInfo];
    }else{
        [self hideLoadingWithCompletionMessage:errorInfo];
        THNErrorPage *errorPage = [[THNErrorPage alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-20-44-50)];
        __block THNErrorPage *weakError = errorPage;
        errorPage.callBack = ^{
            JYLog(@"XXXXXXXXX");
            [weakError removeFromSuperview];
            _currentPage = 1;
            [self requestForOrderList:(int)_currentPage];
        };
        errorPage.tag = 9328301;
        if (![self.view viewWithTag:9328301]) {
            [self.view addSubview:errorPage];
        }

    }
}
#pragma mark - 上拉刷新的状态监测
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if (bottomEdge >=  floor(scrollView.contentSize.height) )
    {
        if (self.loadingmore || !self.loadFooterView.enabled)
            return;
        if ([_orderArray count]==0)
            return;
        _currentPage ++;
        if (_currentPage>_totalPage) {
            
            JYLog(@"Last Page");
            [self.loadFooterView setEnabled:NO];
            _currentPage--;
        }else{
            
            self.view.userInteractionEnabled = NO;
            JYLog(@"load more");
            self.loadingmore = YES;
            self.loadFooterView.showActivityIndicator = YES;
            
            [self requestForOrderList:(int)_currentPage];
        }
    }
}

@end
