//
//  THNTopicCommentViewController.m
//  store
//
//  Created by XiaobinJia on 14-12-12.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNTopicCommentViewController.h"
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
#import "THNTextField.h"

@interface THNTopicCommentViewController ()<JYComHttpRequestDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (nonatomic, strong) RKFootFreshView *loadFooterView;
@property(nonatomic, assign) BOOL loadingmore;
@end

@implementation THNTopicCommentViewController
{
    BOOL                            _nibsRegistered;
    THNTopic                        *_topic;
    NSInteger                       _currentPage;
    NSInteger                       _totalPage;
    
    RKFootFreshView                 *_loadFooterView;
    
    JYComHttpRequest                *_contentRequest;
    JYComHttpRequest                *_request;
    NSMutableArray                  *_contentData;//每个元素为cate
    
    THNTextField            *adviceTextField;
    UIView                  *toolBarView;
}


- (id)initWithTopic:(THNTopic *)topic
{
    if (self = [super init]) {
        _topic = topic;
        _contentData = [[NSMutableArray alloc] initWithCapacity:0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [_contentRequest clearDelegatesAndCancel];
    _contentRequest = nil;
    [_request clearDelegatesAndCancel];
    _request = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"相关评论";
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
    
    _loadFooterView = [[RKFootFreshView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.f)];
    self.loadingmore = NO;
    self.tableview.tableFooterView = self.loadFooterView;
    
    toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-64-55, SCREEN_WIDTH, 55)];
    toolBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:toolBarView];
    
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
    [submitBtn.layer setMasksToBounds:YES];
    [submitBtn.layer setCornerRadius:4.0];
    [submitBtn setBackgroundColor:[UIColor SecondColor]];
    [submitBtn setTitle:@"评论" forState:UIControlStateNormal];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitToServer) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:submitBtn];
    
    [self requestForPage:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - request
- (void)requestForPage:(int)page
{
    if (page==1) {
        [_contentData removeAllObjects];
        _contentData = [[NSMutableArray alloc] initWithCapacity:0];
        
        [self showLoadingWithAni:YES];
    }
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     _topic.topicID,                                    @"target_id",
                                     [[THNUserManager sharedTHNUserManager] userid],    @"current_user_id",
                                     [NSString stringWithFormat:@"%d",page],            @"page",
                                     [THNUserManager channel],                          @"channel",
                                     [THNUserManager client_id],                        @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],      @"uuid",
                                     [THNUserManager time],                             @"time",
                                     nil];
    [listPara addSign];
    if (!_contentRequest) {
        _contentRequest = [[JYComHttpRequest alloc] init];
    }
    [_contentRequest clearDelegatesAndCancel];
    _contentRequest.delegate = self;
    [_contentRequest getInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiPartyReplys]];
    
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
                                     _topic.topicID,                                        @"target_id",
                                     adviceTextField.text,                                  @"content",
                                     [THNUserManager channel],                              @"channel",
                                     [THNUserManager client_id],                            @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],          @"uuid",
                                     [THNUserManager time],                                 @"time",
                                     nil];
    [listPara addSign];
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request getInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiTopicComment]];
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
{}

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
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
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
    if ([jyRequest.requestUrl hasSuffix:kTHNApiPartyReplys]) {
        // 解析数据
        if ([result isKindOfClass:[NSDictionary class]]) {
            _totalPage = [result intValueForKey:@"total_page"];
            NSArray *rows = [result objectForKey:@"rows"];
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
    
        
        if(self.loadingmore)
        {
            self.loadingmore = NO;
            self.view.userInteractionEnabled = YES;
            self.loadFooterView.showActivityIndicator = NO;
            
            [self.tableview reloadData];
        }else{
            //刷新界面
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .3 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.view.userInteractionEnabled = YES;
                [self.tableview reloadData];
                [self hideLoading];
            });
        }
    }else{
//        [JDStatusBarNotification showWithStatus:@"评论成功！"
//                                   dismissAfter:4.0
//                                      styleName:JDStatusBarStyleMatrix];
        [self alertWithInfo:@"评论成功！"];
        [self requestForPage:1];
    }
    
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    if(self.loadingmore)
    {
        _currentPage--;
        self.loadingmore = NO;
        self.view.userInteractionEnabled = YES;
        self.loadFooterView.showActivityIndicator = NO;
    }
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
        frame.origin.y = keyboardFrame.origin.y - frame.size.height - 40 - 20;
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
        frame.origin.y = keyboardFrame.origin.y - frame.size.height - 40 - 20;
        toolBarView.frame = frame;
    }];
}

- (void)keyboardHidden:(NSNotification *)note{
    NSDictionary *userInfo = note.userInfo;
    NSNumber *duration = [userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"];
    [UIView animateWithDuration:duration.floatValue animations:^(void){
        toolBarView.frame = CGRectMake(0, SCREEN_HEIGHT-64-55, SCREEN_WIDTH, 55);
    }];
}

@end
