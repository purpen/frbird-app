//
//  THNForgetViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-7.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNForgetViewController.h"
#import "JYComHttpRequest.h"
#import "THNUserManager.h"
#import "JYComCustomTextField.h"
#import "NSMutableDictionary+AddSign.h"
#import <UIViewController+AMThumblrHud.h>

@interface THNForgetViewController ()<UITextFieldDelegate, JYComHttpRequestDelegate>
{
    
    UIWebView                   *_proView;
    
    /*隐私政策
     BOOL                        _provOrNot;
     */
    
    JYComHttpRequest            *_request;
    
    IBOutlet UIButton           *_getAuthBtn;
    
    
    IBOutlet JYComCustomTextField       *mobileTextField;
    IBOutlet JYComCustomTextField       *mobileAuthTextField;
    IBOutlet JYComCustomTextField       *mobilePasswordTextField;
    IBOutlet UIButton           *mobileRegisterBtn;
}
@property (nonatomic, strong) NSTimer *codeTimer;
@end

@implementation THNForgetViewController
@synthesize codeTimer = _codeTimer;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _request = [[JYComHttpRequest alloc] init];
        /*隐私政策
         _provOrNot = YES;*/
    }
    return self;
}
- (void)dealloc
{
    [_request clearDelegatesAndCancel];
    _request = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"修改密码";
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, -5, 10, 25)];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self addMobileRegisterViewToView:self.view];
}

- (void)addMobileRegisterViewToView:(UIView *)view{
    mobileTextField.placeholder = @"手机号";
    mobileTextField.text = @"";
    mobileTextField.layer.borderWidth = .5;
    mobileTextField.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    mobileTextField.font = [UIFont systemFontOfSize:15];
    mobileTextField.delegate = self;
    mobileTextField.placeholdOffSet = CGPointMake(10, .01);
    mobileTextField.textOffSet = CGPointMake(10, .01);
    
    [_getAuthBtn.layer setMasksToBounds:YES];
    [_getAuthBtn.layer setCornerRadius:4.0];
    _getAuthBtn.layer.borderWidth = .5;
    _getAuthBtn.layer.borderColor = [[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0] CGColor];
    [_getAuthBtn addTarget:self action:@selector(getMobileAuth) forControlEvents:UIControlEventTouchUpInside];
    
    mobileAuthTextField.placeholder = @"验证码";
    mobileAuthTextField.placeholdOffSet = CGPointMake(10, .01);
    mobileAuthTextField.textOffSet = CGPointMake(10, .01);
    mobileAuthTextField.layer.borderWidth = .5;
    mobileAuthTextField.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    mobileAuthTextField.delegate = self;
    
    mobilePasswordTextField.placeholder = @"请输入新密码";
    mobilePasswordTextField.placeholdOffSet = CGPointMake(10, .01);
    mobilePasswordTextField.textOffSet = CGPointMake(10, .01);
    mobilePasswordTextField.layer.borderWidth = .5;
    mobilePasswordTextField.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    mobilePasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    mobilePasswordTextField.delegate = self;
    /*隐私政策
     UIButton *provButton = [UIButton buttonWithType:UIButtonTypeCustom];
     [provButton setImage:[UIImage imageNamed:@"jy_green_on.png"] forState:UIControlStateNormal];
     [provButton addTarget:self action:@selector(provButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
     
     UILabel *provLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 0, 85, 15)];
     provLabel.backgroundColor = [UIColor clearColor];
     provLabel.textColor = [UIColor colorWithRed:0.545 green:0.545 blue:0.545 alpha:1];
     provLabel.font = [UIFont systemFontOfSize:12];
     provLabel.text = @"已阅读并同意";
     
     UIButton *provContent = [UIButton buttonWithType:UIButtonTypeCustom];
     provContent.titleLabel.font = [UIFont systemFontOfSize:12];
     [provContent setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
     provContent.frame = CGRectMake(97, 0, 125, 15);
     provContent.backgroundColor = [UIColor clearColor];
     [provContent setTitle:@"太火鸟使用协议" forState:UIControlStateNormal];
     [provContent addTarget:self action:@selector(provContentClicked) forControlEvents:UIControlEventTouchUpInside];
     
     [view addSubview:provButton];
     [view addSubview:provLabel];
     [view addSubview:provContent];
     */
    [mobileRegisterBtn.layer setMasksToBounds:YES];
    [mobileRegisterBtn.layer setCornerRadius:4.0];
}

#pragma mark - Back
- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 太火鸟协议
- (void)provContentClicked
{
    [[self firstResponder] resignFirstResponder];
    
    if (!_proView) {
        _proView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT-44-20)];
    }
    
    [_proView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kTHNPageClause]]];
    UIViewController *c = [[UIViewController alloc] init];
    [c.view addSubview:_proView];
    
    [self.navigationController pushViewController:c animated:YES];
}
/*隐私政策
 - (void)provButtonClicked:(UIButton *)sender
 {
 if (_provOrNot) {
 [sender setImage:[UIImage imageNamed:@"jy_green_off.png"] forState:UIControlStateNormal];
 }else{
 [sender setImage:[UIImage imageNamed:@"jy_green_on.png"] forState:UIControlStateNormal];
 }
 _provOrNot = !_provOrNot;
 }
 */
#pragma mark - 授权
- (BOOL)isValidateEmail:(NSString *)Email
{
    NSString *emailCheck = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailCheck];
    return [emailTest evaluateWithObject:Email];
}
- (BOOL)judgePhoneNumber:(NSString *)num
{
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    
    return [phoneTest evaluateWithObject:num];
}
- (IBAction)getMobileAuth{
    [[self firstResponder] resignFirstResponder];
    NSString *phone = mobileTextField.text;
    if (![self judgePhoneNumber:phone] && ![self isValidateEmail:phone]) {
        [self alertWithInfo:@"请输入正确的手机号或邮箱！"];
        return;
    }
    NSMutableDictionary *paras = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  phone,                                        @"mobile",
                                  [THNUserManager channel],                     @"channel",
                                  [THNUserManager client_id],                   @"client_id",
                                  [[THNUserManager sharedTHNUserManager] uuid],                        @"uuid",
                                  [THNUserManager time],                        @"time",
                                  nil];
    [paras addSign];
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:paras andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiPhoneCode]];
    
    [self showLoadingWithAni:YES];
    mobileTextField.userInteractionEnabled = NO;
}
static int __time = 60;
- (void)codeNext
{
    __time--;
    [_getAuthBtn setTitle:[NSString stringWithFormat:@"重发(%d)",__time] forState:UIControlStateNormal];
    if (__time==0) {
        [_codeTimer invalidate];
        __time = 60;
        //设置获取按钮文字，并且可点击
        [_getAuthBtn setTitle:@"重发" forState:UIControlStateNormal];
        _getAuthBtn.userInteractionEnabled = YES;
    }
}
#pragma mark - 手机注册
- (IBAction)mobileRegister{
    [[self firstResponder] resignFirstResponder];
    /*隐私政策
     if (!_provOrNot) {
     [self alertWithInfo:@"请阅读并同意太火鸟使用协议"];
     return;
     }
     */
    NSString *phone = mobileTextField.text;
    NSString *code = mobileAuthTextField.text;
    NSString *pw = mobilePasswordTextField.text;
    if (pw) {
        if (pw.length < 6) {
            [self alertWithInfo:@"密码长度为6-20个字符"];
            return;
        }
    }
    NSMutableDictionary *paras = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  pw,                                           @"content",
                                  code,                                         @"verify_code",
                                  phone,                                        @"mobile",
                                  [mobilePasswordTextField text],               @"password",
                                  [THNUserManager channel],                     @"channel",
                                  [THNUserManager client_id],                   @"client_id",
                                  [[THNUserManager sharedTHNUserManager] uuid],                        @"uuid",
                                  [THNUserManager time],                        @"time",
                                  nil];
    [paras addSign];
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:paras andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiForget]];
    [self showHUDWithMessage:@"正在修改"];
}

#pragma mark - ASI Delegate
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    if ([jyRequest.requestUrl isEqualToString:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiPhoneCode]]) {
        _getAuthBtn.userInteractionEnabled = NO;
        self.codeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(codeNext) userInfo:nil repeats:YES];
        [self.codeTimer fire];
        [self hideLoading];
        [self alertWithInfo:@"验证码已发送！"];
        return;
    }else{
        [self hideHUD];
//        [JDStatusBarNotification showWithStatus:@"密码修改成功！"
//                                   dismissAfter:3.0
//                                      styleName:JDStatusBarStyleMatrix];
        [self alertWithInfo:@"密码修改成功！"];
        [self doBack:nil];
    }
    
    
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    NSString *errorInfo = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    if ([jyRequest.requestUrl isEqualToString:kTHNApiPhoneCode]) {
        mobileTextField.userInteractionEnabled = YES;
    }
    [self hideHUD];
    [self alertWithInfo:errorInfo];
}

#pragma mark - 键盘代理
#pragma mark- UITextFielDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == mobilePasswordTextField) {
        if (range.location>=20)return NO;
        return YES;
    }
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (UIView *)firstResponder{
    if ([mobileTextField isFirstResponder]) {
        return mobileTextField;
    }
    if ([mobilePasswordTextField isFirstResponder]) {
        return mobilePasswordTextField;
    }
    if ([mobileAuthTextField isFirstResponder]) {
        return mobileAuthTextField;
    }
    return nil;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}
#pragma mark - other
#pragma mark - 其他函数
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self firstResponder] resignFirstResponder];
}


@end
