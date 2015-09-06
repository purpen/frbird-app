//
//  THNStoreViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-10.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNStoreViewController.h"
#import "NSMutableDictionary+AddSign.h"
#import "THNUserManager.h"
#import "JYComHttpRequest.h"
#import "RKFootFreshView.h"
#import "THNProductBrief.h"
#import "THNCategory.h"
#import "THNTagView.h"
#import "UIView+CreateSepret.h"
#import "THNProductViewController.h"
#import "THNYuShouViewController.h"
#import <UIImageView+WebCache.h>
#import "UIScrollView+PullToRefreshCoreText.h"
#import "THNAppDelegate.h"
#import <pop/POP.h>
#import "THNErrorPage.h"

@interface THNStoreViewController ()<JYComHttpRequestDelegate>
@property (strong, nonatomic) NSMutableArray *contentData;
@property (strong, nonatomic) NSMutableArray *cateData;
@property (nonatomic, strong) RKFootFreshView *loadFooterView;
@property (nonatomic, assign) BOOL loadingmore;
@end

@implementation THNStoreViewController
{
    JYComHttpRequest *_cateRequest;
    JYComHttpRequest *_contentRequest;
    NSMutableArray *_contentData;
    NSMutableArray *_cateData;
    
    RKFootFreshView *_loadFooterView;
    
    NSInteger _currentPage;
    NSInteger _totalPage;
    
    UIImageView *_indicat;
    BOOL    _afterRequest;
    BOOL _showMenu;
    UIButton *_titleButton;
    
    /*
     * 当前列表要展示的分类的ID
     */
    NSString *_cateIDOfcurrentList;
}
@synthesize loadFooterView = _loadFooterView, loadingmore = _loadingmore;
@synthesize contentData = _contentData, cateData = _cateData;

- (id)init
{
    if (self = [super init]) {
        _cateRequest = [[JYComHttpRequest alloc] init];
        _contentRequest = [[JYComHttpRequest alloc] init];
        
        _contentData = [[NSMutableArray alloc] init];
        _cateData = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)dealloc
{
    [_cateRequest clearDelegatesAndCancel];
    _cateRequest = nil;
    [_contentRequest clearDelegatesAndCancel];
    _contentRequest = nil;
}
- (NSMutableArray *)contentData{
    if (!_contentData) {
        _contentData = [[NSMutableArray alloc] init];
    }
    return _contentData;
}
- (NSMutableArray *)cateData
{
    if (!_cateData) {
        _cateData = [[NSMutableArray alloc] init];
    }
    return _cateData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"商店";
    
    /*
     * 初始默认加载“全部”，ID为0
     */
    _cateIDOfcurrentList = @"0";
    _showMenu = NO;
    _totalPage = MAXFLOAT;
    _afterRequest = NO;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70+17, 44)];
    bgView.backgroundColor = [UIColor clearColor];
    
    
    _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _titleButton.frame = CGRectMake(0, 0, 70, 44);
    _titleButton.backgroundColor = [UIColor clearColor];
    [_titleButton setTitle:@"商店" forState:UIControlStateNormal];
    _titleButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [_titleButton setTitleColor:[UIColor SecondColor] forState:UIControlStateNormal];
    [_titleButton addTarget:self action:@selector(titleButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:_titleButton];
    
    _indicat = [[UIImageView alloc] initWithFrame:CGRectMake(60, 17, 17, 9)];
    _indicat.image = [UIImage imageNamed:@"right_arrow"];
    [bgView addSubview:_indicat];
    self.navigationItem.titleView = bgView;
    
    [self.tableView setContentSize:CGSizeMake(self.view.frame.size.width, self.tableView.frame.size.height + 1)];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithPullText:@"taihuoniao.com" pullTextColor:[UIColor SecondColor] pullTextFont:DefaultTextFont refreshingText:@"taihuoniao.com" refreshingTextColor:[UIColor SecondColor] refreshingTextFont:DefaultTextFont action:^{
        //重新刷新数据之前要加载设置可翻页
        [weakSelf.loadFooterView setEnabled:YES];
        weakSelf.view.userInteractionEnabled = NO;
        [weakSelf requestForCategory];
    }];
    
    _currentPage = 1;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    _loadFooterView = [[RKFootFreshView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.f)];
    self.loadingmore = NO;
    self.tableView.tableFooterView = self.loadFooterView;
    
    CGAffineTransform at = CGAffineTransformMakeRotation(M_PI);//
    at =CGAffineTransformTranslate(at,0,0);
    [[(UIView *)[UIApplication sharedApplication].keyWindow viewWithTag:99188] removeFromSuperview];
    [_indicat setTransform:at];
    
    [self.tableView.pullToRefreshView autoRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)menuButtonClicked:(UIButton *)sender
{
    //移除error page
    if ([self.view viewWithTag:9328301]) {
        [[self.view viewWithTag:9328301] removeFromSuperview];
    }
    
    NSMutableArray *titles = [NSMutableArray arrayWithCapacity:0];
    [titles addObject:@"全部"];
    for (THNCategory *cate in self.cateData) {
        [titles addObject:cate.cateTitle];
    }
    NSString *t = [titles objectAtIndex:sender.tag-2000];
    if ([t isEqualToString:@"全部"]) {
        t = @"商店";
    }
    [_titleButton setTitle:t forState:UIControlStateNormal];
    if (sender.tag-2000==0) {
        //箭头的位置改变，“全部”只有两个字
        _indicat.frame = CGRectMake(60, 17, 17, 9);
        _cateIDOfcurrentList = @"0";
    }else{
        //箭头的位置改变，分类标题有四个字
        _indicat.frame = CGRectMake(75, 17, 17, 9);
        int order = (int)(sender.tag - 2000);
        THNCategory *cate = [self.cateData objectAtIndex:order-1];
        _cateIDOfcurrentList = cate.cateID;
    }
    //切换列表
    [self titleButtonClicked];
    [_cateData removeAllObjects];
    [_contentData removeAllObjects];
    [self.tableView reloadData];
    [self.tableView.pullToRefreshView autoRefresh];
    
}

- (void)titleButtonClicked
{
    if (!_showMenu) {
        NSMutableArray *titles = [NSMutableArray arrayWithCapacity:0];
        [titles addObject:@"全部"];
        for (THNCategory *cate in self.cateData) {
            [titles addObject:cate.cateTitle];
        }
        THNTagView *bgView = [[THNTagView alloc] initWithFrame:CGRectMake(0, 44+20, SCREEN_WIDTH, [titles count]*35) andLines:(int)[titles count]];
        bgView.backgroundColor = [UIColor redColor];
        bgView.tag = 99188;
        
        bgView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.8];
        for (int i=0; i<[titles count]; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(15, 35*i, SCREEN_WIDTH-15, 35);
            button.tag = 2000+i;
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            [button addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [button setTitleColor:[UIColor colorWithRed:124/255.0 green:111/255.0 blue:106/255.0 alpha:1.0] forState:UIControlStateNormal];
            [button setTitle:titles[i] forState:UIControlStateNormal];
            [bgView addSubview:button];
        }
        [[UIApplication sharedApplication].keyWindow addSubview:bgView];
        self.view.userInteractionEnabled = NO;
        [SharedApp tabCUserInteractable:NO];
        
        _showMenu = !_showMenu;
    }else{
        _showMenu = !_showMenu;
        
        UIView *tagView =[[UIApplication sharedApplication].keyWindow viewWithTag:99188];
        [tagView removeFromSuperview];
        self.view.userInteractionEnabled = YES;
        [SharedApp tabCUserInteractable:YES];
    }
}

- (void)requestForCategory
{
    _currentPage = 1;
    [self.cateData removeAllObjects];
    [self.contentData removeAllObjects];
    self.cateData = [[NSMutableArray alloc] initWithCapacity:0];
    self.contentData = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [THNUserManager channel],                      @"channel",
                                     [THNUserManager client_id],                    @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],  @"uuid",
                                     kParaTime,                                     @"time",
                                     [[THNUserManager sharedTHNUserManager] userid],@"current_user_id",
                                     nil];
    [listPara addSign];
    //开始请求分类
    if (!_cateRequest) {
        _cateRequest = [[JYComHttpRequest alloc] init];
    }
    [_cateRequest clearDelegatesAndCancel];
    _cateRequest.delegate = self;
    [_cateRequest getInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiStoreCategory]];
}
- (void)requestForContentOfPage:(int)page
{
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     _cateIDOfcurrentList,                          @"category_id",
                                     [NSString stringWithFormat:@"%d",page],        @"page",
                                     [THNUserManager channel],                      @"channel",
                                     [THNUserManager client_id],                    @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],  @"uuid",
                                     kParaTime,                                     @"time",
                                     [[THNUserManager sharedTHNUserManager] userid],@"current_user_id",
                                     nil];
    [listPara addSign];
    if (!_contentRequest) {
        _contentRequest = [[JYComHttpRequest alloc] init];
    }
    [_contentRequest clearDelegatesAndCancel];
    _contentRequest.delegate = self;
    [_contentRequest getInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiList]];
}
#pragma mark - 上拉刷新的状态监测

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if (bottomEdge >=  floor(scrollView.contentSize.height) )
    {
        if (self.loadingmore || !self.loadFooterView.enabled) return;
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.contentData count] == 0 ||  indexPath.row>[self.contentData count]-1) {
        return 0;
    }
    THNProductBrief *product = [self.contentData objectAtIndex:indexPath.row];
    return (product.productStage==kTHNProductStageSelling)?kTHNMainTableCellHeightSelling:kTHNMainTableCellHeightPre;

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
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
    return _afterRequest?[_contentData count]:0;;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *mainCellIdentifier = @"THNMainCellIdentifier";
    static NSString *sellingCellIdentifier = @"THNSellingCellIdentifier";
    static BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *mainNib = [UINib nibWithNibName:@"THNMainCell" bundle:nil];
        [tableView registerNib:mainNib forCellReuseIdentifier:mainCellIdentifier];
        UINib *sellingNib = [UINib nibWithNibName:@"THNSellingCell" bundle:nil];
        [tableView registerNib:sellingNib forCellReuseIdentifier:sellingCellIdentifier];
        nibsRegistered = YES;
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
        int start = [[NSDate date] timeIntervalSince1970];
        int finished = [product.productPresageFinishedTime intValue];
        int surplus = finished - start;//单位是s
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
    
    /*公用配置部分*/
    //封面图-12001
    //[(UIImageView *)[cell viewWithTag:12001] sd_setImageWithURL:[NSURL URLWithString:@"http://frbird.qiniudn.com/product/141008/5434e42f867094fb188b4635-1-bi.jpg"]];
    [(UIImageView *)[cell viewWithTag:12001] sd_setImageWithURL:[NSURL URLWithString:product.productImage]];
    //标题-12002
    NSString *title = product.productTitle;
    if ([title length]>16) {
        title = [product.productTitle substringToIndex:16];
    }
    ((UILabel *)[cell viewWithTag:12002]).text = [NSString stringWithFormat:@"%@",title];
    //优势-12003
    ((UILabel *)[cell viewWithTag:12003]).text = [NSString stringWithFormat:@"%@",product.productAdvantage];
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

#pragma mark - ASI Delegate
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    if ([jyRequest.requestUrl hasSuffix:kTHNApiStoreCategory]) {
        // 解析数据
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSArray *rows = [result objectForKey:@"rows"];
            for (NSDictionary *dict in rows) {
                THNCategory *cate = [[THNCategory alloc] init];
                cate.cateID = [dict stringValueForKey:@"_id"];
                cate.cateName = [dict stringValueForKey:@"name"];
                cate.cateTitle = [dict stringValueForKey:@"title"];
                cate.cateCount = [dict intValueForKey:@"total_count"];
                [_cateData addObject:cate];
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
                
                product.productPresageStartTime = [dict stringValueForKey:@"presale_start_time"];
                product.productPresageFinishedTime = [dict stringValueForKey:@"presale_finish_time"];
                product.productPresagePeople = [dict stringValueForKey:@"presale_people"];
                product.productPresagePercent = [dict stringValueForKey:@"presale_percent"];
                product.productTopicCount = [dict stringValueForKey:@"topic_count"];
                
                product.productCanSaled = [dict boolValueForKey:@"can_saled"];
                
                [_contentData addObject:product];
            }
        }
        //[self hideHUD];
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
    JYLog(@"接口数据返回成功：%@",error);
    if ([jyRequest.requestUrl hasSuffix:kTHNApiList]) {
        
    }
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

@end
