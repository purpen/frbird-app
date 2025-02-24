//
//  THNProductDetailViewController.m
//  store
//
//  Created by XiaobinJia on 14-12-3.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNProductDetailViewController.h"
#import "THNCartViewController.h"
#import "HMSegmentedControl.h"
#import "JYComHttpRequest.h"
#import "THNUserManager.h"
#import "NSMutableDictionary+AddSign.h"
#import "THNTopic.h"
#import "RKFootFreshView.h"
#import <UIViewController+AMThumblrHud.h>
#import "UIScrollView+PullToRefreshCoreText.h"
#import "THNTextField.h"
#import "JYShareViewController.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"
#import "THNTopicDetailViewController.h"

typedef enum : NSUInteger {
    kTHNProductDetailTypeImages = 0,
    kTHNProductDetailTypeTopic,
    kTHNProductDetailTypeQuetion
} THNProductDetailType;

@interface THNProductDetailViewController ()<UITableViewDataSource,UITableViewDelegate, UIScrollViewDelegate, UIWebViewDelegate, JYComHttpRequestDelegate, UITextFieldDelegate, NJKWebViewProgressDelegate>
@property (nonatomic, assign) THNProductDetailType type;
@end

@implementation THNProductDetailViewController
{
    JYComHttpRequest        *_request;
    IBOutlet UIButton       *_cartButton;
    IBOutlet UIButton       *_buyButton;
    BOOL                    _nibsRegistered;
    THNProduct              *_product;
    THNProductDetailType    _type;
    
    
    UITableView             *_tableView;
    UIWebView               *_webView;
    IBOutlet UIView         *_tabView;
    
    NSMutableArray          *_contentData;
    
    THNTextField            *adviceTextField;
    UIView                  *toolBarView;
    
    int                     _totalNum;
    
    NJKWebViewProgressView          *_progressView;
    NJKWebViewProgress              *_progressProxy;
}
@synthesize product = _product;
@synthesize coverImage = _coverImage;
@dynamic type;
- (id)init{
    if (self = [super init]) {
        self.title = @"详情";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [_tableView setDelegate:nil];
    [_tableView setDataSource:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [_request clearDelegatesAndCancel];
    _request = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"详情";
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, -5, 10, 25)];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, 44)];
    right.backgroundColor = [UIColor whiteColor];
    
    UIButton *cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cartButton setTitleColor:[UIColor SecondColor] forState:UIControlStateNormal];
    [cartButton setImage:[UIImage imageNamed:@"cart"] forState:UIControlStateNormal];
    cartButton.frame = CGRectMake(15, 2, 44, 44);
    [cartButton addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [right addSubview:cartButton];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setTitleColor:[UIColor SecondColor] forState:UIControlStateNormal];
    [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    shareButton.frame = CGRectMake(44+12, 2, 44, 44);
    [shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [right addSubview:shareButton];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:right];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    _cartButton.layer.borderWidth = .5;
    _cartButton.layer.borderColor = [[UIColor colorWithRed:255/255.0 green:74/255.0 blue:133/255.0 alpha:1.0] CGColor];
    [_cartButton.layer setMasksToBounds:YES];
    [_cartButton.layer setCornerRadius:4.0];
    
    _buyButton.layer.borderWidth = .5;
    _buyButton.layer.borderColor = [[UIColor colorWithRed:3/255.0 green:3/255.0 blue:3/255.0 alpha:1.0] CGColor];
    [_buyButton.layer setMasksToBounds:YES];
    [_buyButton.layer setCornerRadius:4.0];
    
    NSString *centerTitle = (_product.brief.productStage == kTHNProductStageSelling)?@"用户评价":@"讨论话题";
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    view.backgroundColor = UIColorFromRGB(0xffffff);
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"产品详情", centerTitle, @"常见问题"]];
    segmentedControl.tag = 31001;
    segmentedControl.font = [UIFont systemFontOfSize:15];
    segmentedControl.textColor = UIColorFromRGB(0xa4a4a4a);
    segmentedControl.backgroundColor = UIColorFromRGB(0xffffff);
    segmentedControl.selectionIndicatorColor = [UIColor SecondColor];
    segmentedControl.selectionIndicatorHeight = 2;
    segmentedControl.selectionIndicatorMode = HMSelectionIndicatorFillsSegment;
    switch (_type) {
        case kTHNProductDetailTypeImages:
        {
            [segmentedControl setSelectedIndex:0 animated:NO];
        }
            break;
        case kTHNProductDetailTypeTopic:
        {
            [segmentedControl setSelectedIndex:1 animated:NO];
        }
            break;
        case kTHNProductDetailTypeQuetion:
        {
            [segmentedControl setSelectedIndex:2 animated:NO];
        }
            break;
        default:
            break;
    }
    __weak typeof(self) weakSelf = self;
    segmentedControl.indexChangeBlock = ^(NSUInteger index){
        weakSelf.type = index;
    };
    [segmentedControl setFrame:CGRectMake(10, 0, SCREEN_WIDTH-10-10, 40)];
    [view addSubview:segmentedControl];
    [self.view addSubview:view];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT-64-44+5)];
    scrollView.tag = 31002;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH*3, scrollView.frame.size.height);
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    //1屏
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-44+5)];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.scrollView.bounces = YES;
    _webView.delegate = self;
    _webView.backgroundColor = UIColorFromRGB(0xf8f8f8);
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_product.productContentURL]]];
    [scrollView addSubview:_webView];
    
    //2屏
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, scrollView.frame.size.height) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.bounces = NO;
    _tableView.backgroundColor = UIColorFromRGB(0xf8f8f8);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    /*
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    footView.backgroundColor = UIColorFromRGB(0xf8f8f8);
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    commentButton.frame = CGRectMake(0, 0, SCREEN_WIDTH/2+100, 40);
    commentButton.center = CGPointMake(SCREEN_WIDTH/2, 15+15);
    [commentButton setTitleColor:[UIColor BlackTextColor] forState:UIControlStateNormal];
    commentButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [commentButton.layer setMasksToBounds:YES];
    [commentButton.layer setCornerRadius:4.0];
    commentButton.layer.borderWidth = .5;
    commentButton.layer.borderColor = [[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0] CGColor];
    commentButton.backgroundColor = [UIColor whiteColor];
    [commentButton setTitle:@"马上评价" forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(commentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:commentButton];
    _tableView.tableFooterView = footView;
    
    */
    [scrollView addSubview:_tableView];
    
    if (_product.brief.productStage == kTHNProductStageSelling) {
        toolBarView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT-64-55-40, SCREEN_WIDTH, 55)];
        toolBarView.backgroundColor = [UIColor whiteColor];
        [scrollView addSubview:toolBarView];
        
        UIView *textBgview = [[UIView alloc] initWithFrame:CGRectMake(12, 10, 230, 30)];
        textBgview.backgroundColor = [UIColor colorWithRed:228/255.f green:228/255.f blue:228/255.f alpha:1.0];
        [toolBarView addSubview:textBgview];
        
        adviceTextField = [[THNTextField alloc] initWithFrame:CGRectMake(0,-5, 250, 44)];
        adviceTextField.placeholdOffSet = CGPointMake(30, 9);
        adviceTextField.textOffSet = CGPointMake(30, 9);
        adviceTextField.borderStyle = UITextBorderStyleNone;
        adviceTextField.delegate = self;
        adviceTextField.adjustsFontSizeToFitWidth = YES;
        adviceTextField.backgroundColor = [UIColor clearColor];
        adviceTextField.layer.borderColor = [UIColor colorWithRed:175/255.f green:175/255.f blue:175/255.f alpha:1.0].CGColor;
        adviceTextField.textColor = [UIColor colorWithRed:175/255.f green:175/255.f blue:175/255.f alpha:1.0];
        adviceTextField.placeholder = [NSString stringWithFormat:@"说点什么吧!"];
        [textBgview addSubview:adviceTextField];
        
        adviceTextField.leftViewMode = UITextFieldViewModeAlways;
        //需要图片
        UIImageView *pinlunImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pinglun_input.png"]];
        adviceTextField.leftView = pinlunImage;
        adviceTextField.leftViewRect = CGRectMake(6,10, 21, 20);
        
        UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        submitBtn.frame = CGRectMake(250, 10, 55, 30);
        [submitBtn setBackgroundColor:[UIColor SecondColor]];
        [submitBtn setTitle:@"评论" forState:UIControlStateNormal];
        [submitBtn.layer setMasksToBounds:YES];
        [submitBtn.layer setCornerRadius:4.0];
        [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [submitBtn addTarget:self action:@selector(submitToServer) forControlEvents:UIControlEventTouchUpInside];
        [toolBarView addSubview:submitBtn];
    }
    
    //3屏
    UIView *questionView1 = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*2, 0, SCREEN_WIDTH, 90)];
    [questionView1 createGapWithPointOne:CGPointMake(0, 89) pointTwo:CGPointMake(SCREEN_WIDTH+0, 89) andR:205/255.0 G:205/255.0 B:205/255.0 andWidth:1.0f];
    UILabel *questionTitle1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH-30, 15)];
    questionTitle1.backgroundColor = [UIColor clearColor];
    questionTitle1.textColor = UIColorFromRGB(0x3c3c3c);

    UILabel *questionContent1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 29, SCREEN_WIDTH-30, 53)];
    questionContent1.backgroundColor = [UIColor clearColor];
    questionContent1.textColor = UIColorFromRGB(0x959595);
    questionTitle1.text = @"收藏商品功能";
    questionTitle1.font = [UIFont systemFontOfSize:13];
    questionContent1.text = @"点击“收藏按钮”后，按钮中的填实黑色,代表收藏成功，再次点击取消收藏。您可在“个人中心”中的我的收藏查看所有收藏商品。";
    questionContent1.font = [UIFont systemFontOfSize:13];
    questionContent1.numberOfLines = MAXFLOAT;
    [questionView1 addSubview:questionTitle1];
    [questionView1 addSubview:questionContent1];
    
    UIView *questionView2 = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*2, 90-.5, SCREEN_WIDTH, 90)];
    [questionView2 createGapWithPointOne:CGPointMake(0, 89) pointTwo:CGPointMake(SCREEN_WIDTH, 89) andR:205/255.0 G:205/255.0 B:205/255.0 andWidth:1.0f];
    UILabel *questionTitle2 = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH-30, 15)];
    questionTitle2.backgroundColor = [UIColor clearColor];
    questionTitle2.textColor = UIColorFromRGB(0x3c3c3c);
    
    UILabel *questionContent2 = [[UILabel alloc] initWithFrame:CGRectMake(15, 29, SCREEN_WIDTH-30, 53)];
    questionContent2.backgroundColor = [UIColor clearColor];
    questionContent2.textColor = UIColorFromRGB(0x959595);
    questionTitle2.text = @"订单取消，怎样退款？";
    
    questionTitle2.font = [UIFont systemFontOfSize:13];
    questionContent2.text = @"订单取消时，您的支持金额将自动退款至【账户余额】中。您可以支持其他产品，或在此【申请取现】至您的支付宝或其他付款账户。";
    
    questionContent2.font = [UIFont systemFontOfSize:13];
    questionContent2.numberOfLines = MAXFLOAT;
    [questionView2 addSubview:questionTitle2];
    [questionView2 addSubview:questionContent2];
    
    questionView1.backgroundColor = UIColorFromRGB(0xf8f8f8);
    questionView2.backgroundColor = UIColorFromRGB(0xf8f8f8);
    scrollView.backgroundColor = UIColorFromRGB(0xf8f8f8);
    
    
    [scrollView addSubview:questionView1];
    [scrollView addSubview:questionView2];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*2, 180-1, SCREEN_WIDTH, 3)];
    lineView.backgroundColor = UIColorFromRGB(0xf8f8f8);
    [scrollView addSubview:lineView];
    
    [_tabView removeFromSuperview];
    
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
}
#pragma mark - request
- (void)requestForPage:(int)page
{
    if (page==1) {
        [_contentData removeAllObjects];
        _contentData = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (_product.brief.productStage == kTHNProductStagePre) {
        // 请求预售的话题
        // 开始请求列表，页面进入正在加载状态
        NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [[THNUserManager sharedTHNUserManager] userid], @"current_user_id",
                                         _product.brief.productID,                              @"target_id",
                                         [NSString stringWithFormat:@"%d",page],                @"page",
                                         @"30",                                                 @"size",
                                         [THNUserManager channel],                              @"channel",
                                         [THNUserManager client_id],                            @"client_id",
                                         [[THNUserManager sharedTHNUserManager] uuid],                                 @"uuid",
                                         [THNUserManager time],                                 @"time",
                                         nil];
        [listPara addSign];
        if (!_request) {
            _request = [[JYComHttpRequest alloc] init];
        }
        [_request clearDelegatesAndCancel];
        _request.delegate = self;
        [_request getInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiPartyList]];
    }else{
        //请求商品的评论列表
        // 开始请求列表，页面进入正在加载状态
        NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [[THNUserManager sharedTHNUserManager] userid], @"current_user_id",
                                         _product.brief.productID,                              @"target_id",
                                         [NSString stringWithFormat:@"%d",page],                @"page",
                                         @"30",                                                 @"size",
                                         [THNUserManager channel],                              @"channel",
                                         [THNUserManager client_id],                            @"client_id",
                                         [[THNUserManager sharedTHNUserManager] uuid],                                 @"uuid",
                                         [THNUserManager time],                                 @"time",
                                         nil];
        [listPara addSign];
        if (!_request) {
            _request = [[JYComHttpRequest alloc] init];
        }
        [_request clearDelegatesAndCancel];
        _request.delegate = self;
        [_request getInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiProductCommentsList]];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.0000001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001f;
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

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [_contentData count];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_product.brief.productStage==kTHNProductStagePre) {
        THNTopic *topic = nil;
        if (indexPath.row<[_contentData count]) {
            topic = [_contentData objectAtIndex:indexPath.row];
        }
        THNTopicDetailViewController *topicDetail = [[THNTopicDetailViewController alloc] initWithTopic:topic];
        [self.navigationController pushViewController:topicDetail animated:YES];
        return;
    }
    return;
}
#pragma mark - Back
- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Button Clicked
- (void)submitToServer
{
    [adviceTextField resignFirstResponder];
    if (!adviceTextField.text || [adviceTextField.text isEqualToString:@""]) {
//        [JDStatusBarNotification showWithStatus:@"请输入您的评论内容哦！"
//                                   dismissAfter:4.0
//                                      styleName:JDStatusBarStyleMatrix];
        [self alertWithInfo:@"请输入您的评论内容哦！"];
        return;
    }
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[THNUserManager sharedTHNUserManager] userid],        @"current_user_id",
                                     _product.brief.productID,                              @"target_id",
                                     adviceTextField.text,                @"content",
                                     [THNUserManager channel],                              @"channel",
                                     [THNUserManager client_id],                            @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],                                 @"uuid",
                                     [THNUserManager time],                                 @"time",
                                     nil];
    [listPara addSign];
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request getInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiProductComment]];
}
- (void)cartButtonClicked:(id)sender
{
    THNCartViewController *cart = [[THNCartViewController alloc] init];
    [self.navigationController pushViewController:cart animated:YES];
}
- (void)shareButtonClicked:(id)sender
{
    JYShareViewController *shareViewController = [[JYShareViewController alloc] init];
    shareViewController.shareContent = [NSString stringWithFormat:@"太火鸟商城：%@",_product.brief.productTitle];
    shareViewController.shareUrl = [NSString stringWithFormat:@"http://m.taihuoniao.com/shop/%@.html",_product.brief.productID];
    shareViewController.shareImage = self.coverImage;
    shareViewController.shareType = shareTypeOther;
    [self presentViewController:shareViewController animated:YES completion:^{
        
    }];
}
- (void)commentButtonClicked
{
    THNCartViewController *cart = [[THNCartViewController alloc] init];
    [self.navigationController pushViewController:cart animated:YES];
}
#pragma mark - change
- (void)setType:(THNProductDetailType)type
{
    if (_type != type) {
        _type = type;
        //切换页面
        [UIView animateWithDuration:.25 animations:^{
            ((UIScrollView *)[self.view viewWithTag:31002]).contentOffset = CGPointMake(SCREEN_WIDTH*_type, 0);
        }];
        HMSegmentedControl *seg = ((HMSegmentedControl *)[self.view viewWithTag:31001]);
        if (seg.selectedIndex != _type) {
            seg.selectedIndex = _type;
        }
        if (type==kTHNProductDetailTypeTopic) {
            [self requestForPage:1];
        }
    }
}
- (THNProductDetailType)type
{
    return _type;
}
#pragma mark - Scroll Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UITableView class]]) {
        return;
    }
    
    int index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
    self.type = index;
}
#pragma mark - WebView Delegate
#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

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
    if ([jyRequest.requestUrl hasSuffix:kTHNApiPartyList]) {
        // 解析数据
        if ([result isKindOfClass:[NSDictionary class]]) {
            _totalNum = [result intValueForKey:@"total_rows"];
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
                
                topic.topicUserID = [dict stringValueForKey:@"current_user_id"];
                topic.topicUsername = [dict stringValueForKey:@"username"];
                topic.topicAvatar = [dict stringValueForKey:@"small_avatar_url"];
                
                [_contentData addObject:topic];
                
            }
        }
    }else if([jyRequest.requestUrl hasSuffix:kTHNApiProductCommentsList]){
        // 解析数据
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSArray *rows = [result objectForKey:@"rows"];
            if (!_contentData) {
                _contentData = [[NSMutableArray alloc] initWithCapacity:0];
            }
            for (NSDictionary *dict in rows) {
                NSString *username = [((NSDictionary *)[dict objectForKey:@"user"]) objectForKey:@"nickname"];
                NSString *content = [dict objectForKey:@"content"];
                NSString *date = [dict objectForKey:@"created_on"];
                THNTopic *t = [[THNTopic alloc] init];
                t.topicTitle = content;
                t.topicUsername = username;
                t.topicDate = date;
                t.topicCommentNumber = @"0";
                [_contentData addObject:t];
            }
        }
    }else{
        [self alertWithInfo:@"评论成功！"];
        [self requestForPage:1];
    }
    
    [_tableView reloadData];
    
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    NSString *errorInfo = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    [self hideLoadingWithCompletionMessage:errorInfo];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == adviceTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}
#pragma mark - keyboard methods
- (void)keyboardShow:(NSNotification *)note{
    NSDictionary *userInfo = note.userInfo;
    NSValue *boundsValue = [userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
    NSNumber *duration = [userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"];
    CGRect keyboardFrame = boundsValue.CGRectValue;
    [UIView animateWithDuration:duration.floatValue animations:^(void){
        CGRect frame = toolBarView.frame;
        frame.origin.y = keyboardFrame.origin.y - frame.size.height - 40 - 40 - 20;
        toolBarView.frame = frame;
    }];
}

- (void)keyboardChange:(NSNotification *)note{
    NSDictionary *userInfo = note.userInfo;
    NSValue *boundsValue = [userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
    NSNumber *duration = [userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"];
    CGRect keyboardFrame = boundsValue.CGRectValue;
    [UIView animateWithDuration:duration.floatValue animations:^(void){
        CGRect frame = toolBarView.frame;
        frame.origin.y = keyboardFrame.origin.y - frame.size.height - 40 - 40 - 20;
        toolBarView.frame = frame;
    }];
}

- (void)keyboardHidden:(NSNotification *)note{
    NSDictionary *userInfo = note.userInfo;
    NSNumber *duration = [userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"];
    [UIView animateWithDuration:duration.floatValue animations:^(void){
        toolBarView.frame = CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT-64-55-40, SCREEN_WIDTH, 55);
    }];
}

@end
