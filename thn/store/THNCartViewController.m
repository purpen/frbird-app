//
//  THNCartViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-10.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNCartViewController.h"
#import "THNCartDB.h"
#import "THNAppDelegate.h"
#import "THNOrderViewController.h"
#import "THNCartItem.h"
#import <UIImageView+WebCache.h>
#import "THNSku.h"
#import "THNUserManager.h"
#import <JSONKit.h>
#import "JYComHttpRequest.h"
#import "THNProduct.h"
#import "NSMutableDictionary+AddSign.h"

@interface THNCartViewController ()<JYComHttpRequestDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray  *_contentData;
    BOOL            _nibsRegistered;
    BOOL            _tableVeiwEditState;
    UIButton        *_rightButton;
    
    IBOutlet UIButton   *_payButton;
    IBOutlet UILabel    *_totalMoney;
    
    JYComHttpRequest    *_request;
}
@property (nonatomic, retain) NSMutableArray *contentData;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@end

@implementation THNCartViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"购物车";    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, -5, 10, 25)];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    _rightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_rightButton setTitle:@"编辑" forState:UIControlStateNormal];
    _rightButton.frame = CGRectMake(0, 0, 44, 44);
    [_rightButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_rightButton setTitleColor:[UIColor SecondColor] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    _payButton.layer.borderWidth = .5;
    _payButton.layer.borderColor = [[UIColor colorWithRed:255/255.0 green:74/255.0 blue:133/255.0 alpha:1.0] CGColor];
    [_payButton.layer setMasksToBounds:YES];
    [_payButton.layer setCornerRadius:4.0];
    
    
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    [_request clearDelegatesAndCancel];
    _request = nil;
    [self.tableview setDelegate:nil];
    [self.tableview setDataSource:nil];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
}
#pragma mark - Back
- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightButtonClicked:(UIButton *)sender
{
    [self.tableview setEditing:!_tableVeiwEditState animated:YES];
    _tableVeiwEditState = !_tableVeiwEditState;
    if (_tableVeiwEditState) {
        [_rightButton setTitle:@"完成" forState:UIControlStateNormal];
        for (UITableViewCell *cell in self.tableview.visibleCells) {
            ((UIView *)[cell viewWithTag:1004]).hidden = NO;
        }
    }else{
        [_rightButton setTitle:@"编辑" forState:UIControlStateNormal];
        for (UITableViewCell *cell in self.tableview.visibleCells) {
            ((UIView *)[cell viewWithTag:1004]).hidden = NO;
        }
    }
    
}
- (IBAction)createOrder:(id)sender
{
    NSMutableArray *itemArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (THNCartItem *item in _contentData) {
        NSDictionary *dic = nil;
        //是否有SKU，以保存的SKUID为准，不能以SKUCount为准，因为这里从数据库读取的product信息不完整
        if (item.itemProductSKUID) {
            dic = [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSString stringWithFormat:@"%d",item.itemProductSKUID],@"sku_id",
                   item.itemProduct.brief.productID,@"product_id",
                   item.itemProductCount,@"n",
                   nil];
        }else{
            dic = [NSDictionary dictionaryWithObjectsAndKeys:
                   item.itemProduct.brief.productID,@"product_id",
                   item.itemProductCount,@"n",
                   nil];
        }
        if (dic) {
            [itemArray addObject:dic];
        }
    }
    NSString *jsonS = [itemArray JSONString];
    
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [THNUserManager sharedTHNUserManager].userid,  @"current_user_id",
                                     jsonS,                                         @"array",
                                     [THNUserManager channel],                      @"channel",
                                     [THNUserManager client_id],                    @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],  @"uuid",
                                     [THNUserManager time],                         @"time",
                                     nil];
    [listPara addSign];
    //开始请求商品详情
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiProductCartBuy]];
    [self showLoadingWithAni:YES];
}
#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.000001f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
#pragma mark - tableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_contentData count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"THNCartCell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *mainNib = [UINib nibWithNibName:@"THNCartCell" bundle:nil];
        [tableView registerNib:mainNib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    THNCartItem *item = [self.contentData objectAtIndex:indexPath.row];
    //图片
    [((UIImageView *)[cell viewWithTag:32101]) sd_setImageWithURL:[NSURL URLWithString:item.itemProduct.brief.productImage]];
    //标题
    ((UILabel *)[cell viewWithTag:32102]).text = item.itemProduct.brief.productTitle;
    //类型
    ((UILabel *)[cell viewWithTag:32103]).text = [NSString stringWithFormat:@"类型：%@",item.itemProductSKUTitle];
    //数量
    ((UILabel *)[cell viewWithTag:32104]).text = [NSString stringWithFormat:@"数量：%@",item.itemProductCount];
    //价格
    ((UILabel *)[cell viewWithTag:32105]).text = [NSString stringWithFormat:@"￥%@",item.itemProductPrice];
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

#pragma mark - tableview 编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"aaa");
        THNCartItem *item = [self.contentData objectAtIndex:indexPath.row];
        [self.contentData removeObject:item];
        
        [[THNCartDB sharedTHNCartDB] deleteItem:item];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        NSLog(@"aaa");
    }
    [self reloadData];
}
- (void)reloadData
{
    //刷新列表
    NSArray *arr = [[THNCartDB sharedTHNCartDB] allItem];
    self.contentData = [NSMutableArray arrayWithArray:arr];
    if (![self.contentData count]) {
        //购物车中没有商品
    }
    
    CGFloat total = 0.0f;
    for (THNCartItem *item in arr) {
        total += [item.itemProductPrice floatValue] * [item.itemProductCount intValue];
    }
    _totalMoney.text = [NSString stringWithFormat:@"￥%.2f",total];
    [self.tableview  reloadData];
}
#pragma mark - ASI Delegate
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    if([jyRequest.requestUrl hasSuffix:kTHNApiProductCartBuy]){
        //验证订单信息
        id orderInfo = [result objectForKey:@"order_info"];
        int payMoney = [result intValueForKey:@"pay_money"];
        int localTotal = [[_totalMoney.text substringFromIndex:1] intValue];
        if (payMoney != localTotal) {
//            [JDStatusBarNotification showWithStatus:@"订单金额和本地金额不一致"
//                                       dismissAfter:2.0
//                                          styleName:JDStatusBarStyleMatrix];
            [self alertWithInfo:@"订单金额和本地金额不一致"];
            return;
        }
        if ([orderInfo isKindOfClass:[NSDictionary class]]) {
            
            NSString *tmpOrderID = [orderInfo stringValueForKey:@"_id"];
            if (tmpOrderID) {
                THNOrderViewController *order = [[THNOrderViewController alloc] init];
                order.tmpOrderID = tmpOrderID;
                order.isNowBuy = 0;
                order.isPresale = 0;
                
                order.productArray = _contentData;
                [self.navigationController pushViewController:order animated:YES];
                [self hideLoading];
            }else{
                [self hideLoadingWithCompletionMessage:@"订单创建失败！"];
            }
        }
        
        
    }
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    NSString *errorInfo = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    [self hideLoadingWithCompletionMessage:errorInfo];
}

@end
