//
//  THNPartyViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-10.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNPartyViewController.h"
#import "JYComHttpRequest.h"
#import "RKFootFreshView.h"
#import "NSMutableDictionary+AddSign.h"
#import "THNUserManager.h"
#import "THNTopicCategory.h"
#import "THNTopicsViewController.h"
#import <UIViewController+AMThumblrHud.h>
#import <UIImageView+WebCache.h>
#import "THNErrorPage.h"

@interface THNPartyViewController ()<UITableViewDataSource, UITableViewDelegate, JYComHttpRequestDelegate>
@property (nonatomic, retain) NSMutableArray *contentData;

@end

@implementation THNPartyViewController
{
    JYComHttpRequest *_cateRequest;
    JYComHttpRequest *_contentRequest;
    NSMutableArray *_contentData;//每个元素为cate
    //NSMutableArray *_sectionTitleData;//每个元素为cate数组
    
    NSInteger _currentPage;
    BOOL        _requestSuccessed;
}
@synthesize tableView = _tableView;
@synthesize contentData = _contentData;

- (id)init
{
    if (self = [super init]) {
        _contentRequest = [[JYComHttpRequest alloc] init];
        //_sectionTitleData = [[NSMutableArray alloc] init];
        _contentData = [[NSMutableArray alloc] init];
        _requestSuccessed = NO;
    }
    return self;
}
- (void)dealloc
{
    [self.tableView setDelegate:nil];
    [self.tableView setDataSource:nil];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"社区";
    
    self.tableView.tableFooterView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_requestSuccessed) {
        //此处参数为0，服务端接口从1开始
        _currentPage = 1;
        [self requestForContentOfPage:(int)_currentPage];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)requestForContentOfPage:(int)page
{
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[THNUserManager sharedTHNUserManager] userid],    @"current_user_id",
                                     @"30",                                             @"size",
                                     [NSString stringWithFormat:@"%d",page],            @"page",
                                     [THNUserManager channel],                          @"channel",
                                     [THNUserManager client_id],                        @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],      @"uuid",
                                     kParaTime,                                         @"time",
                                     nil];
    [listPara addSign];
    if (!_contentRequest) {
        _contentRequest = [[JYComHttpRequest alloc] init];
    }
    [_contentRequest clearDelegatesAndCancel];
    _contentRequest.delegate = self;
    [_contentRequest getInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiPartyCategory]];
    [self showLoadingWithAni:YES];
}
#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 41)];
    bgView.backgroundColor = [UIColor whiteColor];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(27, 0, 165, 41)];
    title.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
    title.font = [UIFont systemFontOfSize:15];
    title.textColor = [UIColor BlackTextColor];
    [bgView addSubview:title];
    return bgView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    THNTopicCategory *cate = [_contentData objectAtIndex:indexPath.section];
    THNTopicCategory *subCate = [cate.cateSubCates objectAtIndex:indexPath.row];
    
    THNTopicsViewController *topics = [[THNTopicsViewController alloc] initWithCategory:subCate andMainCate:cate];
    
    topics.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:topics animated:YES];
}
#pragma mark - tableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [((THNTopicCategory *)[_contentData objectAtIndex:section]).cateSubCates count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor = UIColorFromRGB(0xf8f8f8);
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = UIColorFromRGB(0xaaaaaa);
        cell.textLabel.textColor = [UIColor SecondColor];
        cell.detailTextLabel.numberOfLines = 2;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    THNTopicCategory *subCate = (THNTopicCategory *)[((THNTopicCategory *)[_contentData objectAtIndex:indexPath.section]).cateSubCates objectAtIndex:indexPath.row];
    cell.textLabel.text = subCate.cateTitle;
    NSArray *arr = @[@[@"icon_01", @"icon_02", @"icon_niao",    @"icon_niao", @"icon_niao", @"icon_niao"],
                     @[@"icon_04", @"icon_05", @"icon_06",      @"icon_niao", @"icon_niao", @"icon_niao"],
                     @[@"icon_07", @"icon_08", @"icon_09",      @"icon_niao", @"icon_niao", @"icon_niao"],
                     @[@"icon_niao", @"icon_11", @"icon_12",    @"icon_13", @"icon_14", @"icon_15"]];
    NSString *imageName = @"icon_niao";
    if (indexPath.section<4 && indexPath.row<6) {
        imageName = arr[indexPath.section][indexPath.row];
    }
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.detailTextLabel.text = subCate.cateSummary;
    /*
    if (indexPath.row<[_contentData count] || indexPath.row==[_contentData count]) {
        THNProduct *product = [self.contentData objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",product.productID];
    }
    */
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return [_contentData count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return ((THNTopicCategory *)[_contentData objectAtIndex:section]).cateTitle;
}

#pragma mark - ASI Delegate
- (void)arrangeDataOfArray:(NSArray *)arr
{
    NSMutableArray *subCate = [[NSMutableArray alloc] initWithCapacity:0];
    for (THNTopicCategory *cate in arr) {
        if (cate.catePID==0) {
            [_contentData addObject:cate];
        }else{
            [subCate addObject:cate];
        }
    }
    for (THNTopicCategory *cate in subCate) {
        long pid = cate.catePID;
        for (THNTopicCategory *mainCate in _contentData) {
            if (mainCate.cateID == pid) {
                if (!mainCate.cateSubCates) {
                    mainCate.cateSubCates = [[NSMutableArray alloc] initWithCapacity:0];
                }
                
                [mainCate.cateSubCates addObject:cate];
            }
        }
    }
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    _requestSuccessed = YES;
    // 解析数据
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSArray *rows = [result objectForKey:@"rows"];
        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSDictionary *dict in rows) {
            THNTopicCategory *cate = [[THNTopicCategory alloc] init];
            cate.cateID = [dict longValueForKey:@"_id"];
            cate.cateName = [dict stringValueForKey:@"name"];
            cate.cateTitle = [dict stringValueForKey:@"title"];
            cate.cateSummary = [dict stringValueForKey:@"summary"];
            cate.catePID = [dict longValueForKey:@"pid"];
            cate.cateTopicCount = [dict stringValueForKey:@"total_count"];
            cate.cateIcon = [dict stringValueForKey:@""];
            
            [arr addObject:cate];
        }
        
        //整合数据到若干个数组中；——
        [self arrangeDataOfArray:arr];
    }
    //刷新界面
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .3 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView reloadData];
        [self hideLoading];
    });
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    _requestSuccessed = NO;
    NSString *errorInfo = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    [self hideLoadingWithCompletionMessage:errorInfo];
    THNErrorPage *errorPage = [[THNErrorPage alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-20-44-50)];
    __block THNErrorPage *weakError = errorPage;
    errorPage.callBack = ^{
        JYLog(@"XXXXXXXXX");
        [weakError removeFromSuperview];
        if (!_requestSuccessed) {
            //此处参数为0，服务端接口从1开始
            _currentPage = 1;
            [self requestForContentOfPage:(int)_currentPage];
        }
    };
    errorPage.tag = 9328301;
    if (![self.view viewWithTag:9328301]) {
        [self.view addSubview:errorPage];
    }
}
-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,30,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,30,0,0)];
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
