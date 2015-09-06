//
//  THNMyTopicViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-16.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNMyTopicViewController.h"
#import "THNAddTopicViewController.h"
#import "THNTopicDetailViewController.h"
#import "THNBaseNavController.h"
#import "THNTopicCategory.h"
#import "THNTopic.h"
#import "JYComHttpRequest.h"
#import "RKFootFreshView.h"
#import "NSMutableDictionary+AddSign.h"
#import "THNUserManager.h"
#import <UIViewController+AMThumblrHud.h>
#import "UIScrollView+PullToRefreshCoreText.h"
#import "THNErrorPage.h"

@interface THNMyTopicViewController ()<UITableViewDataSource,UITableViewDelegate,JYComHttpRequestDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (nonatomic, strong) RKFootFreshView *loadFooterView;
@property(nonatomic, assign) BOOL loadingmore;
@end

@implementation THNMyTopicViewController
{
    BOOL                    _nibsRegistered;
    //    UIButton                *_segmentButtonLeft;
    //    UIButton                *_segmentButtonCenter;
    //    UIButton                *_segmentButtonRight;
    THNTopicCategory        *_cateData;
    NSInteger                     _currentPage;
    NSInteger                     _totalPage;
    
    RKFootFreshView *_loadFooterView;
    
    JYComHttpRequest        *_contentRequest;
    NSMutableArray          *_contentData;//每个元素为cate
}


- (id)initWithCategory:(THNTopicCategory *)cate
{
    if (self = [super init]) {
        _cateData = cate;
        _contentData = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}
- (void)dealloc
{
    [self.tableview setDelegate:nil];
    [self.tableview setDataSource:nil];
    [_contentRequest clearDelegatesAndCancel];
    _contentRequest = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的话题";
    _nibsRegistered = NO;
    _currentPage = 1;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, -5, 10, 25)];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self.tableview setContentSize:CGSizeMake(self.view.frame.size.width, self.tableview.frame.size.height + 1)];
    
    __weak typeof(self) weakSelf = self;
    [self.tableview addPullToRefreshWithPullText:@"taihuoniao.com" pullTextColor:[UIColor SecondColor] pullTextFont:DefaultTextFont refreshingText:@"taihuoniao.com" refreshingTextColor:[UIColor SecondColor] refreshingTextFont:DefaultTextFont action:^{
        
        //重新刷新数据之前要加载设置可翻页
        [weakSelf.loadFooterView setEnabled:YES];
        weakSelf.view.userInteractionEnabled = NO;
        _currentPage = 1;
        [self requestForPage:(int)_currentPage];
    }];
    
    _loadFooterView = [[RKFootFreshView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.f)];
    self.loadingmore = NO;
    self.tableview.tableFooterView = self.loadFooterView;
    
    [self.tableview.pullToRefreshView autoRefresh];
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
#pragma mark - request
- (void)requestForPage:(int)page
{
    if (page==1) {
        [_contentData removeAllObjects];
        _contentData = [[NSMutableArray alloc] initWithCapacity:0];
    }
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[THNUserManager sharedTHNUserManager] userid],    @"user_id",
                                     [[THNUserManager sharedTHNUserManager] userid], @"current_user_id",
                                     [NSString stringWithFormat:@"%d",page],        @"page",
                                     @"20",                                         @"size",
                                     [THNUserManager channel],                      @"channel",
                                     [THNUserManager client_id],                    @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],                         @"uuid",
                                     [THNUserManager time],                         @"time",
                                     nil];
    [listPara addSign];
    if (!_contentRequest) {
        _contentRequest = [[JYComHttpRequest alloc] init];
    }
    [_contentRequest clearDelegatesAndCancel];
    _contentRequest.delegate = self;
    [_contentRequest postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiPartyList]];
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
            
            [self requestForPage:_currentPage];
        }
    }
}

#pragma mark - Back
- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonClicked:(id)sender
{
    THNAddTopicViewController *addTopic = [[THNAddTopicViewController alloc] init];
    THNBaseNavController *nav = [[THNBaseNavController alloc] initWithRootViewController:addTopic];
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}
#pragma mark table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    THNTopic *topic = [_contentData objectAtIndex:indexPath.row];
    THNTopicDetailViewController *topicDetail = [[THNTopicDetailViewController alloc] initWithTopic:topic];
    [self.navigationController pushViewController:topicDetail animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.0000001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TopicCell";
    if (!_nibsRegistered) {
        UINib *mainNib = [UINib nibWithNibName:@"THNTopicCell" bundle:nil];
        [tableView registerNib:mainNib forCellReuseIdentifier:CellIdentifier];
        _nibsRegistered = YES;
    }
    THNTopic *topic = nil;
    if (indexPath.row<[_contentData count]) {
        topic = [_contentData objectAtIndex:indexPath.row];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    ((UILabel *)[cell viewWithTag:11001]).text = topic.topicTitle;
    ((UILabel *)[cell viewWithTag:11002]).text = topic.topicDate;
    ((UILabel *)[cell viewWithTag:11003]).text = [NSString stringWithFormat:@"%@分享   评论：%@",topic.topicUsername ,  topic.topicCommentNumber];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectio
{
    
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    //    view.backgroundColor = UIColorFromRGB(0xf8f8f8);
    //    CGFloat width = (SCREEN_WIDTH-15*2)/3;
    //    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"业界动态", @"灵感之源", @"太火鸟动态", nil]];
    //    //[segment setWidth:100 forSegmentAtIndex:0];
    //    segment.segmentedControlStyle = UISegmentedControlStyleBar;
    //    segment.tintColor = [UIColor SecondColor];
    //    segment.selectedSegmentIndex = 0;
    //    [segment addTarget:self action:@selector(valueChange:)
    //                forControlEvents:UIControlEventValueChanged];
    //    segment.frame = CGRectMake(15, 14, SCREEN_WIDTH-15*2, 58/2);
    //    [view addSubview:segment];
    return nil;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [_contentData count];
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableview setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableview setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
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

#pragma mark - 上拉刷新的状态监测
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    
//    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
//    
//    if (bottomEdge >=  floor(scrollView.contentSize.height) )
//    {
//        if (self.loadingmore || !self.loadFooterView.enabled) return;
//        
//        NSLog(@"load more");
//        self.loadingmore = YES;
//        self.loadFooterView.showActivityIndicator = YES;
//        
//        _currentPage ++;
//        self.view.userInteractionEnabled = NO;
//        [self requestForPage:_currentPage];
//    }
//    
//}
#pragma mark - Request Delegate
- (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}


- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    
    // 解析数据
    if ([result isKindOfClass:[NSDictionary class]]) {
        _totalPage = [result intValueForKey:@"total_page"];
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
            
            [_contentData addObject:topic];
            
        }
    }
    //[self hideHUD];
    
    //上拉刷新结束
    if (self.tableview.pullToRefreshView.loading) {
        __weak typeof(UIScrollView *) weakScrollView = self.tableview;
        __weak typeof(self) weakSelf = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .3 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            weakSelf.view.userInteractionEnabled = YES;
            [weakScrollView finishLoading];
            
            [self.tableview reloadData];
        });
    }
    
    if(self.loadingmore)
    {
        self.loadingmore = NO;
        self.view.userInteractionEnabled = YES;
        self.loadFooterView.showActivityIndicator = NO;
        
        [self.tableview reloadData];
    }
    
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    if (self.tableview.pullToRefreshView.loading) {
        __weak typeof(UIScrollView *) weakScrollView = self.tableview;
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
        [self.tableview.pullToRefreshView autoRefresh];
    };
    errorPage.tag = 9328301;
    if (![self.view viewWithTag:9328301]) {
        [self.view addSubview:errorPage];
    }
}
@end
