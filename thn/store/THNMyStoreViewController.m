//
//  THNMyStoreViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-16.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNMyStoreViewController.h"
#import <UIImageView+WebCache.h>
#import "JYComHttpRequest.h"
#import "THNUserManager.h"
#import <UIViewController+AMThumblrHud.h>
#import "NSMutableDictionary+AddSign.h"
#import "THNProductBrief.h"
#import "THNTopic.h"
#import "THNTopicDetailViewController.h"
#import "THNProductViewController.h"
#import "RKFootFreshView.h"
#import "THNYuShouViewController.h"
#import "THNErrorPage.h"

typedef enum : NSInteger {
    kTHNStorePageStateProduct = 1,
    kTHNStorePageStateTopic = 2
} THNStorePageState;

@interface THNMyStoreViewController ()<UITableViewDataSource,UITableViewDelegate, JYComHttpRequestDelegate>
@property (nonatomic, strong) RKFootFreshView *loadFooterView;
@property (nonatomic, assign) BOOL loadingmore;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@end

@implementation THNMyStoreViewController
{
    BOOL                    _nibsRegistered;
    THNStorePageState       _state;
    IBOutlet UITableView    *_tableView;
    
    JYComHttpRequest        *_request;
    NSMutableArray          *_productArray;
    NSMutableArray          *_topicArray;
    
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
    
    self.title = @"我的收藏";
    _nibsRegistered = NO;
    _state = kTHNStorePageStateProduct;
    _totalPage = MAXFLOAT;
    _currentPage = 1;
    
    _productArray = [[NSMutableArray alloc] initWithCapacity:0];
    _topicArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, -5, 10, 25)];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    _loadFooterView = [[RKFootFreshView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.f)];
    self.loadingmore = NO;
    self.tableView.tableFooterView = self.loadFooterView;
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self requestForContentOfPage:(int)_currentPage];
}
- (void)requestForContentOfPage:(int)page
{
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[THNUserManager sharedTHNUserManager] userid],    @"current_user_id",
                                     [NSString stringWithFormat:@"%ld",_state],                                             @"type",
                                     [NSString stringWithFormat:@"%d",page],            @"page",
                                     @"20",                                             @"size",
                                     [THNUserManager channel],                          @"channel",
                                     [THNUserManager client_id],                        @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],      @"uuid",
                                     [THNUserManager time],                             @"time",
                                     [[THNUserManager sharedTHNUserManager] userid],    @"user_id",
                                     nil];
    [listPara addSign];
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiAccountFavorite]];
    if (page==1) {
        [self showLoadingWithAni:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:animated];
}

#pragma mark table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_state == kTHNStorePageStateProduct) {
        return;
    }else{
        THNTopic *topic = [_topicArray objectAtIndex:indexPath.row];
        THNTopicDetailViewController *topicDetail = [[THNTopicDetailViewController alloc] initWithTopic:topic];
        [self.navigationController pushViewController:topicDetail animated:YES];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 50.0000001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return _state==kTHNStorePageStateTopic?78:160;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TopicCellIdentifier = @"TopicCell";
    static NSString *ProductCellIdentifier = @"MyProductCell";
    if (!_nibsRegistered) {
        UINib *myTopicNib = [UINib nibWithNibName:@"THNTopicCell" bundle:nil];
        [tableView registerNib:myTopicNib forCellReuseIdentifier:TopicCellIdentifier];
        _nibsRegistered = YES;
    }
    UITableViewCell *cell;
    if (_state == kTHNStorePageStateTopic) {
        THNTopic *topic = [_topicArray objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:TopicCellIdentifier];
        ((UILabel *)[cell viewWithTag:11001]).text = topic.topicTitle;
        ((UILabel *)[cell viewWithTag:11002]).text = topic.topicDate;
        ((UILabel *)[cell viewWithTag:11003]).text = [NSString stringWithFormat:@" 评论：%@",topic.topicCommentNumber];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:ProductCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ProductCellIdentifier];
            UIImageView *imageViewLeft = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, (SCREEN_WIDTH-15*2-10)/2, 90)];
            imageViewLeft.tag = 1001;
            [cell.contentView addSubview:imageViewLeft];
            
            UIImageView *imageViewRight = [[UIImageView alloc] initWithFrame:CGRectMake(15+10+(SCREEN_WIDTH-15*2-10)/2, 10, (SCREEN_WIDTH-15*2-10)/2, 90)];
            imageViewRight.tag = 1002;
            [cell.contentView addSubview:imageViewRight];
            //9-6-14
            UILabel *titleLabelL = [[UILabel alloc] initWithFrame:CGRectMake(15, imageViewLeft.frame.origin.y+imageViewLeft.frame.size.height+4, (SCREEN_WIDTH-15*2-10)/2, 12)];
            titleLabelL.font = [UIFont systemFontOfSize:12];
            titleLabelL.tag = 1003;
            titleLabelL.textColor = [UIColor BlackTextColor];
            [cell.contentView addSubview:titleLabelL];
            
            UILabel *desLabelL = [[UILabel alloc] initWithFrame:CGRectMake(15, titleLabelL.frame.origin.y+titleLabelL.frame.size.height+3.5, (SCREEN_WIDTH-15*2-10)/2, 22)];
            desLabelL.font = [UIFont systemFontOfSize:9];
            desLabelL.tag = 1004;
            desLabelL.backgroundColor = [UIColor clearColor];
            desLabelL.lineBreakMode = NSLineBreakByCharWrapping;
            desLabelL.numberOfLines = 2;
            desLabelL.textColor = UIColorFromRGB(0x949494);
            [cell.contentView addSubview:desLabelL];
            
            UILabel *priceLabelL = [[UILabel alloc] initWithFrame:CGRectMake(15, desLabelL.frame.origin.y+desLabelL.frame.size.height+4, (SCREEN_WIDTH-15*2-10)/2, 12)];
            priceLabelL.font = [UIFont systemFontOfSize:12];
            priceLabelL.tag = 1005;
            priceLabelL.textColor = [UIColor SecondColor];
            [cell.contentView addSubview:priceLabelL];
            //9-6-14
            UILabel *titleLabelR = [[UILabel alloc] initWithFrame:CGRectMake(15+10+(SCREEN_WIDTH-15*2-10)/2, imageViewRight.frame.origin.y+imageViewRight.frame.size.height+4, (SCREEN_WIDTH-15*2-10)/2, 12)];
            titleLabelR.font = [UIFont systemFontOfSize:12];
            titleLabelR.tag = 1006;
            titleLabelR.textColor = [UIColor BlackTextColor];
            [cell.contentView addSubview:titleLabelR];
            
            UILabel *desLabelR = [[UILabel alloc] initWithFrame:CGRectMake(15+10+(SCREEN_WIDTH-15*2-10)/2, titleLabelR.frame.origin.y+titleLabelR.frame.size.height+3.5, (SCREEN_WIDTH-15*2-10)/2, 22)];
            desLabelR.lineBreakMode = NSLineBreakByCharWrapping;
            desLabelR.numberOfLines = 2;
            desLabelR.textColor = UIColorFromRGB(0x949494);
            desLabelR.font = [UIFont systemFontOfSize:9];
            desLabelR.tag = 1007;
            [cell.contentView addSubview:desLabelR];
            
            UILabel *priceLabelR = [[UILabel alloc] initWithFrame:CGRectMake(15+10+(SCREEN_WIDTH-15*2-10)/2, desLabelR.frame.origin.y+desLabelR.frame.size.height+4, (SCREEN_WIDTH-15*2-10)/2, 12)];
            priceLabelR.font = [UIFont systemFontOfSize:12];
            priceLabelR.tag = 1008;
            priceLabelR.textColor = [UIColor SecondColor];
            [cell.contentView addSubview:priceLabelR];
            
            UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            leftButton.frame = CGRectMake(15, 10, (SCREEN_WIDTH-15*2-10)/2,136);
            leftButton.tag = indexPath.row*2+3010;
            [leftButton addTarget:self action:@selector(productDetail:) forControlEvents:UIControlEventTouchUpInside];
            [leftButton setBackgroundColor:[UIColor clearColor]];
            [cell.contentView addSubview:leftButton];
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [rightButton addTarget:self action:@selector(productDetail:) forControlEvents:UIControlEventTouchUpInside];
            rightButton.tag = indexPath.row*2+1+3010;
            rightButton.frame = CGRectMake(15+10+(SCREEN_WIDTH-15*2-10)/2, 10, (SCREEN_WIDTH-15*2-10)/2,136);
            [rightButton setBackgroundColor:[UIColor clearColor]];
            [cell.contentView addSubview:rightButton];
            
            
            cell.backgroundColor = UIColorFromRGB(0xf8f8f8);
        }
        THNProductBrief *p1 = [_productArray objectAtIndex:indexPath.row*2];
        if (indexPath.row*2+1<[_productArray count]) {
            
            THNProductBrief *p2 = [_productArray objectAtIndex:indexPath.row*2+1];
            
            [((UIImageView *)[cell.contentView viewWithTag:1002]) sd_setImageWithURL:[NSURL URLWithString:p2.productImage]];
            ((UILabel *)[cell.contentView viewWithTag:1006]).text = p2.productTitle;
            ((UILabel *)[cell.contentView viewWithTag:1007]).text = p2.productAdvantage;
            ((UILabel *)[cell.contentView viewWithTag:1008]).text = [NSString stringWithFormat:@"￥%@",p2.productSalePrice];
        }else{
            ((UIImageView *)[cell.contentView viewWithTag:1002]).hidden = YES;
            ((UILabel *)[cell.contentView viewWithTag:1006]).hidden = YES;
            ((UILabel *)[cell.contentView viewWithTag:1007]).hidden = YES;
            ((UILabel *)[cell.contentView viewWithTag:1008]).hidden = YES;
        }
        [((UIImageView *)[cell.contentView viewWithTag:1001]) sd_setImageWithURL:[NSURL URLWithString:p1.productImage]];
        ((UILabel *)[cell.contentView viewWithTag:1003]).text = p1.productTitle;
        ((UILabel *)[cell.contentView viewWithTag:1004]).text = p1.productAdvantage;
        ((UILabel *)[cell.contentView viewWithTag:1005]).text = [NSString stringWithFormat:@"￥%@",p1.productSalePrice];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return _state==kTHNStorePageStateProduct?([_productArray count]+1)/2:[_topicArray count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    view.backgroundColor = UIColorFromRGB(0xf8f8f8);
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"商品", @"话题",nil]];
    segment.tintColor = [UIColor SecondColor];
    segment.tag = 333;
    if (_state == kTHNStorePageStateProduct) {
        segment.selectedSegmentIndex = 0;
    }else{
        segment.selectedSegmentIndex = 1;
    }
    
    [segment addTarget:self action:@selector(timeChange:)
      forControlEvents:UIControlEventValueChanged];
    segment.frame = CGRectMake(15, 14, SCREEN_WIDTH-15*2, 58/2);
    [view addSubview:segment];
    return view;
}


#pragma mark - Back
- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)timeChange:(UISegmentedControl *)sender
{
    THNStorePageState s = _state;
    if (sender.selectedSegmentIndex == 0) {
        _state = kTHNStorePageStateProduct;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else{
        _state = kTHNStorePageStateTopic;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    if (s != _state) {
        
        [self.loadFooterView setEnabled:YES];
        [_productArray removeAllObjects];
        [_topicArray removeAllObjects];
        _productArray = [[NSMutableArray alloc] initWithCapacity:0];
        _topicArray = [[NSMutableArray alloc] initWithCapacity:0];
        [self.tableView reloadData];
        //请求数据
        [self requestForContentOfPage:1];
    }
}
- (void)productDetail:(UIButton *)sender
{
    int index = sender.tag-3010;
    THNProductBrief *product = [_productArray objectAtIndex:index];
    int row = (sender.tag-3010)/2;
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    int imageOrder = (sender.tag-3010)%2;
    UIImageView *coverImage = (UIImageView *)[cell viewWithTag:imageOrder+1001];
    
    if (product.productStage==kTHNProductStagePre) {
        THNYuShouViewController *yushou = [[THNYuShouViewController alloc] initWithProduct:product coverImage:coverImage.image];
        yushou.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:yushou animated:YES];
        return;
    }
    THNProductViewController *productViewController = [[THNProductViewController alloc] initWithProduct:product coverImage:coverImage.image];
    productViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:productViewController animated:YES];
    
}
#pragma mark - 上拉刷新的状态监测
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if (bottomEdge >=  floor(scrollView.contentSize.height) )
    {
        if (self.loadingmore || !self.loadFooterView.enabled)
            return;
        if ([_productArray count]==0)
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
            
            [self requestForContentOfPage:_currentPage];
        }
    }
}
#pragma mark - ASI Delegate
- (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    if (_state == kTHNStorePageStateProduct) {
        // 解析数据
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSArray *rows = [result objectForKey:@"rows"];
            _totalPage = [result intValueForKey:@"total_page"];
            for (NSDictionary *dict in rows) {
                THNProductBrief *product = [[THNProductBrief alloc] init];
                int stage = [dict intValueForKey:@"stage"];
                product.productStage = (stage==5)?kTHNProductStagePre:kTHNProductStageSelling;
                
                product.productID = [dict stringValueForKey:@"_id"];
                product.productImage = [dict stringValueForKey:@"cover_url"];
                product.productAdvantage = [dict stringValueForKey:@"advantage"];
                product.productTitle = [dict stringValueForKey:@"title"];
                
                product.productMarketPrice = [dict stringValueForKey:@"market_price"];
                product.productSalePrice = [dict stringValueForKey:@"sale_price"];
                product.productPreSaleMoney = [dict stringValueForKey:@"presale_money"];
                
                NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
                product.productPresageStartTime = timeSp;
                product.productPresageFinishedTime = [dict stringValueForKey:@"presale_finish_time"];
                product.productPresagePeople = [dict stringValueForKey:@"presale_people"];
                product.productPresagePercent = [dict stringValueForKey:@"presale_percent"];
                product.productTopicCount = [dict stringValueForKey:@"topic_count"];
                
                [_productArray addObject:product];
            }
        }
    }else{
        // 解析数据
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSArray *rows = [result objectForKey:@"rows"];
            for (NSDictionary *dict in rows) {
                THNTopic *topic = [[THNTopic alloc] init];
                topic.topicID = [dict stringValueForKey:@"_id"];
                topic.topicTitle = [dict stringValueForKey:@"title"];
                topic.topicCommentNumber = [dict stringValueForKey:@"comment_count"];
                int time = [dict intValueForKey:@"created_on"];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
                topic.topicDate = [self stringFromDate:date];
                topic.topicDescription = [dict stringValueForKey:@"content_view_url"];
                topic.topicUserID = [dict stringValueForKey:@"user_id"];
                topic.topicUsername = [dict stringValueForKey:@"username"];
                topic.topicAvatar = [dict stringValueForKey:@"small_avatar_url"];
                
                [_topicArray addObject:topic];
            }
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
    
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
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
            [self requestForContentOfPage:(int)_currentPage];
        };
        errorPage.tag = 9328301;
        if (![self.view viewWithTag:9328301]) {
            [self.view addSubview:errorPage];
        }
    }
}

@end
