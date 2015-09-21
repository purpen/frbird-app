//
//  THNCateDetailViewController.m
//  store
//
//  Created by XiaobinJia on 15/9/17.
//  Copyright (c) 2015年 TaiHuoNiao. All rights reserved.
//

#import "THNCateDetailViewController.h"
#import "JYComHttpRequest.h"
#import "RKFootFreshView.h"
#import "UIScrollView+PullToRefreshCoreText.h"
#import "NSMutableDictionary+AddSign.h"
#import "THNUserManager.h"
#import "THNAdModel.h"
#import "THNProductBrief.h"
#import "RKAdBanner.h"
#import "THNWebViewController.h"
#import "THNYuShouViewController.h"
#import "THNProductViewController.h"
#import "THNTopicDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "THNErrorPage.h"

@interface THNCateDetailViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, JYComHttpRequestDelegate>
{
    JYComHttpRequest *_adRequest;
    JYComHttpRequest *_contentRequest;
    RKFootFreshView *_loadFooterView;
    
    NSInteger _currentPage;
    NSInteger _totalPage;
    BOOL    _afterRequest;
    BOOL _nibsRegistered;
    
    THNCategory *_cateModel;
}
@property (strong, nonatomic) NSMutableArray *adsData;
@property (strong, nonatomic) NSMutableArray *contentData;
@property (nonatomic, strong) RKFootFreshView *loadFooterView;
@property (nonatomic, assign) BOOL loadingmore;

@end

@implementation THNCateDetailViewController
@synthesize collectionView = _collectionView, adsData = _adsData, contentData = _contentData, loadFooterView = _loadFooterView, loadingmore = _loadingmore;

- (id)initWithCateModel:(THNCategory *)cate
{
    if (self = [super init]) {
        _adRequest = [[JYComHttpRequest alloc] init];
        _contentRequest = [[JYComHttpRequest alloc] init];
        
        _adsData = [[NSMutableArray alloc] init];
        _contentData = [[NSMutableArray alloc] init];
        _nibsRegistered = NO;
        _cateModel = cate;
    }
    return self;
}
- (void)dealloc
{
    [self.collectionView setDelegate:nil];
    [self.collectionView setDataSource:nil];
    [_adRequest clearDelegatesAndCancel];
    _adRequest = nil;
    [_contentRequest clearDelegatesAndCancel];
    _contentRequest = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = _cateModel.cateTitle;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, -5, 10, 25)];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.collectionView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    _currentPage = 1;
    _totalPage = MAXFLOAT;
    _afterRequest = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView setContentSize:CGSizeMake(self.view.frame.size.width, self.collectionView.frame.size.height + 1)];
    [self.collectionView registerClass:[RKAdBanner class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"RKAdBanner"];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.collectionView.collectionViewLayout = layout;
    
    __weak typeof(self) weakSelf = self;
    [self.collectionView addPullToRefreshWithPullText:@"taihuoniao.com"
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
    
    [self.collectionView.pullToRefreshView autoRefresh];
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
}
- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个section的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_contentData count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"THNProductCell";
    static BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        [collectionView registerNib:[UINib nibWithNibName:@"THNProductCell" bundle:nil] forCellWithReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    THNProductBrief *product = [_contentData objectAtIndex:indexPath.row];
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [((UIImageView *)[cell viewWithTag:21001]) sd_setImageWithURL:[NSURL URLWithString:product.productImage]];
    ((UILabel *)[cell viewWithTag:21002]).text = product.productTitle;
    return cell;
}
//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(290/2, 338/2);
}

//每个section中不同的行之间的行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}
//每个item之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
    for (THNAdModel *model in _adsData) {
        if (model.adImage) {
            [arr addObject:model.adImage];
        }
    }
    
    RKAdBanner *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"RKAdBanner" forIndexPath:indexPath];
    headerView.imageArray = arr;
    headerView.retBlock = ^(int order){
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
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        reusableview = (UICollectionReusableView *)headerView;
    }
    
    return reusableview;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return _afterRequest?CGSizeMake(SCREEN_WIDTH, kTHNAdBannerHeight):CGSizeZero;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    THNProductBrief *product = [_contentData objectAtIndex:indexPath.row];
    THNProductViewController *productViewController = [[THNProductViewController alloc] initWithProduct:product coverImage:nil];
    [self.navigationController pushViewController:productViewController animated:YES];
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
        if (self.collectionView.pullToRefreshView.loading) {
            __weak typeof(UIScrollView *) weakScrollView = self.collectionView;
            __weak typeof(self) weakSelf = self;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .3 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                weakSelf.view.userInteractionEnabled = YES;
                [weakScrollView finishLoading];
                [self.collectionView reloadData];
            });
        }
        
        if(self.loadingmore)
        {
            self.loadingmore = NO;
            self.view.userInteractionEnabled = YES;
            self.loadFooterView.showActivityIndicator = NO;
            
            [self.collectionView reloadData];
        }
    }
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    if (self.collectionView.pullToRefreshView.loading) {
        __weak typeof(UIScrollView *) weakScrollView = self.collectionView;
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
        [self.collectionView.pullToRefreshView autoRefresh];
    };
    errorPage.tag = 9328301;
    if (![self.view viewWithTag:9328301]) {
        [self.view addSubview:errorPage];
    }
    
}

@end
