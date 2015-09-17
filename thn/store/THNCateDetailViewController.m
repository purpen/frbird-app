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

@interface THNCateDetailViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, JYComHttpRequestDelegate>
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

@implementation THNCateDetailViewController
@synthesize collectionView = _collectionView, adsData = _adsData, contentData = _contentData, loadFooterView = _loadFooterView, loadingmore = _loadingmore;
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
    _currentPage = 1;
    _totalPage = MAXFLOAT;
    _afterRequest = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView setContentSize:CGSizeMake(self.view.frame.size.width, self.collectionView.frame.size.height + 1)];
    
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
    
//    [self.tableView.pullToRefreshView autoRefresh];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
