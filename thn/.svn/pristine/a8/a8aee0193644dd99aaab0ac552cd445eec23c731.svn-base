//
//  THNTopicDetailViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-25.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNTopicDetailViewController.h"
#import "THNParagraph.h"
#import <CoreText/CoreText.h>
#import <UIImageView+WebCache.h>
#import "JYComHttpRequest.h"
#import "NSMutableDictionary+AddSign.h"
#import "THNUserManager.h"
#import <UIViewController+AMThumblrHud.h>
#import "JYShareViewController.h"
#import "THNTopicCommentViewController.h"
#import "NJKWebViewProgressView.h"
#import "THNUserManager.h"

#define kTHNParagraphFont 12

@interface THNTopicDetailViewController ()<UIWebViewDelegate, JYComHttpRequestDelegate, NJKWebViewProgressDelegate>

@property (nonatomic, retain) IBOutlet UIButton *FavButton;
@property (nonatomic, retain) IBOutlet UIButton *likeButton;
@end

@implementation THNTopicDetailViewController
{
    JYComHttpRequest                *_request;
    IBOutlet UIButton               *returnButton;
    THNTopic                        *_topicData;
    IBOutlet UIWebView              *_webView;
    
    JYComHttpRequest                *_contentRequest;
    NJKWebViewProgressView          *_progressView;
    NJKWebViewProgress              *_progressProxy;
    
    IBOutlet UIView                 *_toolBar;
}

- (id)initWithTopic:(THNTopic *)topic
{
    if (self = [super init]) {
        _topicData = topic;
    }
    return self;
}
- (void)dealloc
{
    [_request clearDelegatesAndCancel];
    _request = nil;
    [_contentRequest clearDelegatesAndCancel];
    _contentRequest = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 0, 0);
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UILabel *bgView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70+17, 44)];
    bgView.backgroundColor = [UIColor clearColor];
    bgView.lineBreakMode = NSLineBreakByCharWrapping;
    bgView.numberOfLines = 2;
    bgView.textColor = [UIColor SecondColor];
    bgView.text = _topicData.topicTitle;
    bgView.font = [UIFont systemFontOfSize:15];
    
    self.navigationItem.titleView = bgView;
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, 0, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    [self requestForDetail];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [super viewWillAppear:animated];
    
    [_toolBar addSubview:_progressView];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
}
- (BOOL)prefersStatusBarHidden
{
    // iOS7后,[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    // 已经不起作用了
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)requestForDetail
{
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     _topicData.topicID,                            @"id",
                                     [THNUserManager sharedTHNUserManager].userid,  @"current_user_id",
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
    [_contentRequest getInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiTopicDetail]];
    
    [self showLoadingWithAni:YES];
}
#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

- (IBAction)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{

}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    JYLog(@"request'url:%@",[request URL]);
    
    return YES;
}
- (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    
    if ([jyRequest.requestUrl hasSuffix:kTHNApiTopicStore]) {
        _topicData.topicStore = YES;
        [self.FavButton setImage:[UIImage imageNamed:@"topic_fav_red"] forState:UIControlStateNormal];
        [self hideLoadingWithCompletionMessage:@"成功加入收藏！"];
    }else if ([jyRequest.requestUrl hasSuffix:kTHNApiTopicUnStore]) {
        _topicData.topicStore = NO;
        [self.FavButton setImage:[UIImage imageNamed:@"topic_fav"] forState:UIControlStateNormal];
        [self hideLoadingWithCompletionMessage:@"成功取消收藏！"];
    }else if([jyRequest.requestUrl hasSuffix:kTHNApiTopicZan]){
        _topicData.topicZan = YES;
        [self.likeButton setImage:[UIImage imageNamed:@"topic_like_red"] forState:UIControlStateNormal];
        [self hideLoadingWithCompletionMessage:@"点赞成功！"];
    }else if([jyRequest.requestUrl hasSuffix:kTHNApiTopicUnZan]){
        _topicData.topicZan = NO;
        [self.likeButton setImage:[UIImage imageNamed:@"topic_like"] forState:UIControlStateNormal];
        [self hideLoadingWithCompletionMessage:@"取消点赞成功！"];
    }else if([jyRequest.requestUrl hasSuffix:kTHNApiTopicDetail]){
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = [result objectForKey:@"topic"];
            _topicData.topicStore = [dic boolValueForKey:@"is_favorite"];
            _topicData.topicZan = [dic boolValueForKey:@"is_love"];
            _topicData.topicID = [dic stringValueForKey:@"_id"];
            _topicData.topicTitle = [dic stringValueForKey:@"title"];
            _topicData.topicCommentNumber = [dic stringValueForKey:@"comment_count"];
            int time = [dic intValueForKey:@"created_on"];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
            _topicData.topicDate = [self stringFromDate:date];
            _topicData.topicDescription = [dic stringValueForKey:@"content_view_url"];
            
            _topicData.topicUserID = [dic stringValueForKey:@"user_id"];
            _topicData.topicUsername = [dic stringValueForKey:@"username"];
            _topicData.topicAvatar = [dic stringValueForKey:@"small_avatar_url"];
        }
        if (_topicData.topicStore) {
            [self.FavButton setImage:[UIImage imageNamed:@"topic_fav_red"] forState:UIControlStateNormal];
        }
        if (_topicData.topicZan) {
            [self.likeButton setImage:[UIImage imageNamed:@"topic_like_red"] forState:UIControlStateNormal];
        }
        [self hideLoading];
        //不需要请求详情的话，直接加载描述地址
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_topicData.topicDescription]]];
    }
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    NSString *errorInfo = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    [self hideLoadingWithCompletionMessage:errorInfo];
}

#pragma mark - Button Clicked
- (IBAction)shareButtonClicked:(id)sender
{
    JYShareViewController *shareViewController = [[JYShareViewController alloc] init];
    shareViewController.shareContent = [NSString stringWithFormat:@"太火鸟：%@",_topicData.topicTitle];
    shareViewController.shareUrl = [NSString stringWithFormat:@"http://m.taihuoniao.com/social/show-%@-0.html",_topicData.topicID];
    shareViewController.shareImage = [UIImage imageNamed:@"logo-home"];
    shareViewController.shareType = shareTypeOther;
    [self presentViewController:shareViewController animated:YES completion:^{
        
    }];
}
// 赞话题
- (IBAction)zan:(id)sender
{
    if (!_topicData) {
        return;
    }
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [THNUserManager sharedTHNUserManager].userid, @"current_user_id",
                                     _topicData.topicID,                           @"id",
                                     [THNUserManager channel],                     @"channel",
                                     [THNUserManager client_id],                   @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],                        @"uuid",
                                     [THNUserManager time],                        @"time",
                                     nil];
    [listPara addSign];
    //开始请求商品详情
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request getInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, _topicData.topicZan?kTHNApiTopicUnZan:kTHNApiTopicZan]];
    [self showLoadingWithAni:YES];
}
//收藏话题
- (IBAction)store:(id)sender
{
    if (!_topicData) {
        return;
    }
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [THNUserManager sharedTHNUserManager].userid, @"current_user_id",
                                     _topicData.topicID,                           @"id",
                                     [THNUserManager channel],                     @"channel",
                                     [THNUserManager client_id],                   @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],                        @"uuid",
                                     [THNUserManager time],                        @"time",
                                     nil];
    [listPara addSign];
    //开始请求商品详情
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request getInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, _topicData.topicStore?kTHNApiTopicUnStore:kTHNApiTopicStore]];
    [self showLoadingWithAni:YES];
}

- (IBAction)comment:(id)sender
{
    THNTopicCommentViewController *comment = [[THNTopicCommentViewController alloc] initWithTopic:_topicData];
    [self.navigationController pushViewController:comment animated:YES];
}

@end
