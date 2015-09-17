//
//  THNMainViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-10.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNMainViewController.h"
#import "NSMutableDictionary+AddSign.h"
#import "THNUserManager.h"
#import "JYComHttpRequest.h"
#import "RKFootFreshView.h"
#import "THNProductBrief.h"
#import "RKAdBanner.h"
#import "THNProductViewController.h"
#import <UIImageView+WebCache.h>
#import "UIScrollView+PullToRefreshCoreText.h"
#import "THNYuShouViewController.h"
#import "THNAdModel.h"
#import "THNWebViewController.h"
#import "THNTopic.h"
#import "THNTopicDetailViewController.h"
#import "THNErrorPage.h"

@interface THNMainViewController ()<UITableViewDataSource, UITableViewDelegate, JYComHttpRequestDelegate>
{
    JYComHttpRequest *_adRequest;
    JYComHttpRequest *_contentRequest;
    RKFootFreshView *_loadFooterView;
    
    NSInteger _currentPage;
    NSInteger _totalPage;
    BOOL    _afterRequest;
    BOOL _nibsRegistered;
}
@property (strong, nonatomic) NSMutableArray *adsData;
@property (strong, nonatomic) NSMutableArray *contentData;
@property (nonatomic, strong) RKFootFreshView *loadFooterView;
@property(nonatomic, assign) BOOL loadingmore;
@end

@implementation THNMainViewController
@synthesize loadFooterView = _loadFooterView, loadingmore = _loadingmore;
@synthesize tableView = _tableView;
@synthesize adsData = _adsData, contentData = _contentData;
- (id)init
{
    if (self = [super init]) {
        _adRequest = [[JYComHttpRequest alloc] init];
        _contentRequest = [[JYComHttpRequest alloc] init];
        
        _adsData = [[NSMutableArray alloc] init];
        _contentData = [[NSMutableArray alloc] init];
        _nibsRegistered = NO;
    }
    return self;
}
- (void)dealloc
{
    [self.tableView setDelegate:nil];
    [self.tableView setDataSource:nil];
    [_adRequest clearDelegatesAndCancel];
    _adRequest = nil;
    [_contentRequest clearDelegatesAndCancel];
    _contentRequest = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"精选";
    
    _currentPage = 1;
    _totalPage = MAXFLOAT;
    _afterRequest = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView setContentSize:CGSizeMake(self.view.frame.size.width, self.tableView.frame.size.height + 1)];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithPullText:@"taihuoniao.com"
                                   pullTextColor:[UIColor SecondColor]
                                    pullTextFont:DefaultTextFont
                                  refreshingText:@"taihuoniao.com"
                             refreshingTextColor:[UIColor SecondColor]
                              refreshingTextFont:DefaultTextFont
                                          action:^{
        weakSelf.view.userInteractionEnabled = NO;
        
        //重新刷新数据之前要加载设置可翻页
        [weakSelf.loadFooterView setEnabled:YES];
        [weakSelf requestForData];
    }];
    
    _loadFooterView = [[RKFootFreshView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.f)];
    self.loadingmore = NO;
    self.tableView.tableFooterView = self.loadFooterView;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.0001)];
    v.backgroundColor = [UIColor cyanColor];
    self.tableView.tableHeaderView = v;
    
    [self.tableView.pullToRefreshView autoRefresh];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestForData
{
    _afterRequest = NO;
    [self.adsData removeAllObjects];
    [self.contentData removeAllObjects];
    self.adsData = [[NSMutableArray alloc] initWithCapacity:0];
    self.contentData = [[NSMutableArray alloc] initWithCapacity:0];
    
    _currentPage = 1;
    //开始请求轮播，轮播控件进入正在加载状态
    NSMutableDictionary *paras = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"app_index_slide",                           @"name",
                                  [THNUserManager channel],                     @"channel",
                                  [THNUserManager client_id],                   @"client_id",
                                  [[THNUserManager sharedTHNUserManager] uuid], @"uuid",
                                  kParaTime,                                    @"time",
                                  [[THNUserManager sharedTHNUserManager] userid], @"current_user_id",
                                  nil];
    [paras addSign];
    if (!_adRequest) {
        _adRequest = [[JYComHttpRequest alloc] init];
    }
    [_adRequest clearDelegatesAndCancel];
    _adRequest.delegate = self;
    [_adRequest getInfoWithParas:paras andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiMainSlide]];
    //[self showHUD];
}

- (void)requestForContentOfPage:(int)page
{
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"1",                                          @"stick",
                                     [NSString stringWithFormat:@"%d",page],       @"page",
                                     [THNUserManager channel],                     @"channel",
                                     [THNUserManager client_id],                   @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],                        @"uuid",
                                     kParaTime,                        @"time",
                                     [[THNUserManager sharedTHNUserManager] userid], @"current_user_id",
                                     nil];
    [listPara addSign];
    if (!_contentRequest) {
        _contentRequest = [[JYComHttpRequest alloc] init];
    }
    [_contentRequest clearDelegatesAndCancel];
    _contentRequest.delegate = self;
    [_contentRequest getInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiList]];
    //[self showHUD];
}
#pragma mark - 上拉刷新的状态监测
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if (bottomEdge >=  floor(scrollView.contentSize.height) )
    {
        if (self.loadingmore || !self.loadFooterView.enabled)
            return;
        if ([_contentData count]==0)
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
            
            [self requestForContentOfPage:(int)_currentPage];
        }
    }
}

#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.contentData count]==0 || indexPath.row>[self.contentData count]-1) {
        return 0;
    }
    THNProductBrief *product = [self.contentData objectAtIndex:indexPath.row];
    return (product.productStage==kTHNProductStageSelling)?kTHNMainTableCellHeightSelling:kTHNMainTableCellHeightPre;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return _afterRequest?kTHNAdBannerHeight:0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectio
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
    for (THNAdModel *model in _adsData) {
        if (model.adImage) {
            [arr addObject:model.adImage];
        }
    }
    RKAdBanner *ad = [[RKAdBanner alloc] initWithFrameRect:CGRectMake(0, 0, SCREEN_WIDTH, kTHNAdBannerHeight) ImageArray:arr TitleArray:nil];
    ad.retBlock = ^(int order){
        JYLog(@"&&&&&&&&&**********%d",order);
        THNAdModel *model =  [_adsData objectAtIndex:order];
        if (model.adType == kTHNAdTypeProduct) {
            THNProductBrief *product = model.product;
            THNProductViewController *productViewController = [[THNProductViewController alloc] initWithProduct:product coverImage:nil];
            productViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:productViewController animated:YES];
        }else if(model.adType == kTHNAdTypeWeb){
            THNWebViewController *webViewController = [[THNWebViewController alloc] initWithUrl:model.adWebUrl];
            webViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:webViewController animated:YES];
        }else if(model.adType == kTHNAdTypeYushou){
            THNProductBrief *product = model.product;
            THNYuShouViewController *productViewController = [[THNYuShouViewController alloc] initWithProduct:product coverImage:nil];
            productViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:productViewController animated:YES];
        }else if(model.adType == kTHNAdTypeTopic){
            THNTopic *topic = model.topic;
            THNTopicDetailViewController *detail = [[THNTopicDetailViewController alloc] initWithTopic:topic];
            detail.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detail animated:YES];
        }
    };
    return ad;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    THNProductBrief *product = [self.contentData objectAtIndex:indexPath.row];
    UIImage *coverImage = ((UIImageView *)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:12001]).image;
    if (product.productStage==kTHNProductStagePre) {
        THNYuShouViewController *yushou = [[THNYuShouViewController alloc] initWithProduct:product coverImage:coverImage];
        yushou.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:yushou animated:YES];
        return;
    }
    THNProductViewController *productViewController = [[THNProductViewController alloc] initWithProduct:product coverImage:coverImage];
    productViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:productViewController animated:YES];
}
#pragma mark - tableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _afterRequest?[_contentData count]:0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"THNMainCellIdentifier";
    if (!_nibsRegistered) {
        UINib *mainNib = [UINib nibWithNibName:@"THNMainCell2" bundle:nil];
        [tableView registerNib:mainNib forCellReuseIdentifier:cellIdentifier];
        _nibsRegistered = YES;
    }
    THNProductBrief *product = nil;
    if (indexPath.row<[_contentData count]) {
        product = [self.contentData objectAtIndex:indexPath.row];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];;
    [(UIImageView *)[cell viewWithTag:12001] sd_setImageWithURL:[NSURL URLWithString:product.productImage]];
    return cell;
}
/*Version1.0
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *mainCellIdentifier = @"THNMainCellIdentifier";
    static NSString *sellingCellIdentifier = @"THNSellingCellIdentifier";

    if (!_nibsRegistered) {
        UINib *mainNib = [UINib nibWithNibName:@"THNMainCell" bundle:nil];
        [tableView registerNib:mainNib forCellReuseIdentifier:mainCellIdentifier];
        UINib *sellingNib = [UINib nibWithNibName:@"THNSellingCell" bundle:nil];
        [tableView registerNib:sellingNib forCellReuseIdentifier:sellingCellIdentifier];
        _nibsRegistered = YES;
    }
    THNProductBrief *product = nil;
    if (indexPath.row<[_contentData count]) {
        product = [self.contentData objectAtIndex:indexPath.row];
    }
    UITableViewCell *cell;
    if (product.productStage == kTHNProductStagePre) {
        cell = [tableView dequeueReusableCellWithIdentifier:sellingCellIdentifier];
        
        //显示预售标记
        
        //配置额外信息
        //12006-百分比
        ((UILabel *)[cell viewWithTag:12006]).text = [NSString stringWithFormat:@"%@%%",product.productPresagePercent];
        //12007-进度条
        UIView *progressBarBG = ((UIView *)[cell viewWithTag:12007]);
        CGFloat totalWidth = progressBarBG.frame.size.width;
        CGFloat width = totalWidth*[product.productPresagePercent intValue]/100;
        if (width>totalWidth) {
            width = totalWidth;
        }
        UIView *progress = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, progressBarBG.frame.size.height)];
        progress.backgroundColor = [UIColor SecondColor];
        [progressBarBG addSubview:progress];
        
        //12008-话题数
        ((UILabel *)[cell viewWithTag:12008]).text = [NSString stringWithFormat:@"%@",product.productTopicCount];
        //12009-支持人数
        ((UILabel *)[cell viewWithTag:12009]).text = [NSString stringWithFormat:@"%@",product.productPresagePeople];
        //12010-剩余天数
        int start = [product.productPresageStartTime intValue];
        int finished = [product.productPresageFinishedTime intValue];
        int surplus = finished - start;
        int dayNum = surplus/(60*60*24);
        if (dayNum<0) {
            dayNum = 0;
        }
        ((UILabel *)[cell viewWithTag:12010]).text = [NSString stringWithFormat:@"%d",dayNum];
        
        //售价-12004
        ((UILabel *)[cell viewWithTag:12004]).text = [NSString stringWithFormat:@"￥%@",product.productPreSaleMoney];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:mainCellIdentifier];
        
        //售价-12004
        ((UILabel *)[cell viewWithTag:12004]).text = [NSString stringWithFormat:@"￥%@",product.productSalePrice];
    }
    
    //公用配置部分
    //封面图-12001
    //[(UIImageView *)[cell viewWithTag:12001] sd_setImageWithURL:[NSURL URLWithString:@"http://frbird.qiniudn.com/product/141008/5434e42f867094fb188b4635-1-bi.jpg"]];
    [(UIImageView *)[cell viewWithTag:12001] sd_setImageWithURL:[NSURL URLWithString:product.productImage]];
    //标题-12002
    NSString *title = product.productTitle;
    if ([title length]>15) {
        title = [product.productTitle substringToIndex:15];
    }
    ((UILabel *)[cell viewWithTag:12002]).text = [NSString stringWithFormat:@"%@",title];
    //优势-12003
    ((UILabel *)[cell viewWithTag:12003]).text = [NSString stringWithFormat:@"%@",product.productAdvantage];
    //售价-12004
    ((UILabel *)[cell viewWithTag:12004]).text = [NSString stringWithFormat:@"￥%@",product.productSalePrice];
    
    
    return cell;
}
*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

#pragma mark - ASI Delegate
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    if ([jyRequest.requestUrl hasSuffix:kTHNApiMainSlide]) {
        // 解析数据
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSArray *rows = [result objectForKey:@"rows"];
            for (NSDictionary *dict in rows) {
                THNAdModel *ad = [[THNAdModel alloc] init];
                ad.adID = [dict stringValueForKey:@"_id"];
                ad.adTitle = [dict stringValueForKey:@"title"];
                ad.adSubTitle = [dict stringValueForKey:@"sub_title"];
                ad.adType = [dict intValueForKey:@"type"];
                if (ad.adType==2) {
                    NSString *itemType = [dict stringValueForKey:@"item_type"];
                    if ([itemType isEqualToString:@"Topic"]) {
                        ad.adType = kTHNAdTypeTopic;
                    }else{
                        int stage = [dict intValueForKey:@"item_stage"];
                        if (stage) {
                            ad.adType = kTHNAdTypeYushou;
                        }else{
                            ad.adType = kTHNAdTypeProduct;
                        }
                    }
                }
                ad.adImage = [dict stringValueForKey:@"cover_url"];

                if (ad.adType==kTHNAdTypeProduct || ad.adType==kTHNAdTypeYushou) {
                    THNProductBrief *p = [[THNProductBrief alloc] init];
                    p.productID = [dict stringValueForKey:@"item_id"];
                    ad.product = p;
                    ad.adWebUrl = nil;
                    ad.topic = nil;
                }else if(ad.adType==kTHNAdTypeTopic){
                    THNTopic *topic = [[THNTopic alloc] init];
                    topic.topicID = [dict stringValueForKey:@"item_id"];
                    ad.topic = topic;
                    ad.product = nil;
                    ad.adWebUrl = nil;
                }else{
                    ad.product = nil;
                    ad.topic = nil;
                    ad.adWebUrl = [dict stringValueForKey:@"web_url"];
                }
                
                [_adsData addObject:ad];
            }
        }
        //请求第一页内容
        [self requestForContentOfPage:1];
    }else{
        _afterRequest = YES;
        // 解析数据
        if ([result isKindOfClass:[NSDictionary class]]) {
            _totalPage = [result intValueForKey:@"total_page"];
            NSArray *rows = [result objectForKey:@"rows"];
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
                
                product.productCanSaled = [dict boolValueForKey:@"can_saled"];
                
                [_contentData addObject:product];
            }
        }
        
        //上拉刷新结束
        if (self.tableView.pullToRefreshView.loading) {
            __weak typeof(UIScrollView *) weakScrollView = self.tableView;
            __weak typeof(self) weakSelf = self;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .3 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                weakSelf.view.userInteractionEnabled = YES;
                [weakScrollView finishLoading];
                [self.tableView reloadData];
            });
        }
        
        if(self.loadingmore)
        {
            self.loadingmore = NO;
            self.view.userInteractionEnabled = YES;
            self.loadFooterView.showActivityIndicator = NO;
            
            [self.tableView reloadData];
        }
    }
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    if (self.tableView.pullToRefreshView.loading) {
        __weak typeof(UIScrollView *) weakScrollView = self.tableView;
        __weak typeof(self) weakSelf = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .3 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            weakSelf.view.userInteractionEnabled = YES;
            [weakScrollView finishLoading];
        });
        
    }
    if(self.loadingmore)
    {
        _currentPage--;
        self.loadingmore = NO;
        self.view.userInteractionEnabled = YES;
        self.loadFooterView.showActivityIndicator = NO;
    }
    NSString *errorInfo = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    [self hideLoadingWithCompletionMessage:errorInfo];
    
    THNErrorPage *errorPage = [[THNErrorPage alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-20-44-50)];
    __block THNErrorPage *weakError = errorPage;
    errorPage.callBack = ^{
        JYLog(@"XXXXXXXXX");
        [weakError removeFromSuperview];
        [self.tableView.pullToRefreshView autoRefresh];
    };
    errorPage.tag = 9328301;
    if (![self.view viewWithTag:9328301]) {
        [self.view addSubview:errorPage];
    }
    
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
