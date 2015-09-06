//
//  THNLoginViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-7.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNLoginViewController.h"
#import "JYComHttpRequest.h"
#import "THNForgetViewController.h"
#import "THNUserManager.h"
#import "JYComCustomTextField.h"
#import <UIViewController+AMThumblrHud.h>
#import "NSMutableDictionary+AddSign.h"

@interface THNLoginViewController ()<UITextFieldDelegate, JYComHttpRequestDelegate>
{
    JYComHttpRequest                    *_request;
    IBOutlet JYComCustomTextField       *_account;
    IBOutlet JYComCustomTextField       *_secret;
    IBOutlet UIButton                   *_bigButton;
}
@end

@implementation THNLoginViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _request = [[JYComHttpRequest alloc] init];
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
    self.title = @"登录";
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, -5, 10, 25)];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    //添加输入框
    _account.delegate = self;
    _account.keyboardAppearance = UIKeyboardAppearanceAlert;
    _account.keyboardType = UIKeyboardTypeEmailAddress;
    [_account setPlaceholder:@"手机号"];
    
    _account.layer.borderWidth = .5;
    _account.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    _account.font = [UIFont systemFontOfSize:15];
    _account.placeholdOffSet = CGPointMake(10, .01);
    _account.textOffSet = CGPointMake(10, .01);
    
    
    [_secret setSecureTextEntry:YES];
    _secret.delegate = self;
    _secret.placeholdOffSet = CGPointMake(10, .01);
    _secret.textOffSet = CGPointMake(10, .01);
    _secret.layer.borderWidth = .5;
    _secret.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    _secret.font = [UIFont systemFontOfSize:15];
    _secret.keyboardAppearance = UIKeyboardAppearanceAlert;
    _secret.keyboardType = UIKeyboardTypeASCIICapable;
    _secret.returnKeyType = UIReturnKeySend;
    _secret.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_secret setBackgroundColor:[UIColor clearColor]];
    
    [_secret setPlaceholder:@"密码"];
    
    _bigButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    _bigButton.frame = CGRectMake(17, 144, 281, 32);
    [_bigButton.layer setMasksToBounds:YES];
    [_bigButton.layer setCornerRadius:4.0];
    [_bigButton setTitle:@"登录" forState:UIControlStateNormal];
    [_bigButton addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:bigButton];
}
#pragma mark - Button Clicked

-(IBAction)forgetButtonClicked
{
    [_account resignFirstResponder];
    [_secret resignFirstResponder];
    //打开忘记密码页面
    THNForgetViewController *forgetPage = [[THNForgetViewController alloc] init];
    [self.navigationController pushViewController:forgetPage animated:YES];
}

- (void)loginButtonClicked:(UIButton *)sender
{
    [_account resignFirstResponder];
    [_secret resignFirstResponder];
    if ([self judgeTheUserName]) {
        return;
    }
    if ([self judgeTheScret]) {
        return;
    }
    NSMutableDictionary *paras = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [_account text],                              @"mobile",
                                  [_secret text],                               @"password",
                                  [THNUserManager channel],                     @"channel",
                                  [THNUserManager client_id],                   @"client_id",
                                  [[THNUserManager sharedTHNUserManager] uuid],                        @"uuid",
                                  [THNUserManager time],                        @"time",
                                  nil];
    [paras addSign];
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:paras andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiLogin]];
    
    self.view.userInteractionEnabled = NO;
    [self showHUDWithMessage:@"登录中"];
}
#pragma mark - Back
- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - ASI Delegate
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    //登录成功
    if ([result isKindOfClass:[NSDictionary class]]) {
        //为UserManager赋值
        THNUserManager *um = [THNUserManager sharedTHNUserManager];
        um.userid = [result stringValueForKey:@"id"];
        [um loginSuccess];
    }
    [self hideHUD];
    self.view.userInteractionEnabled = YES;
    
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    NSString *errorInfo = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    [self hideHUD];
    [self alertWithInfo:errorInfo];
    self.view.userInteractionEnabled = YES;
}

#pragma mark - 键盘代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _secret) {
        [self loginButtonClicked:nil];
    }else if((textField == _account) && [_secret canBecomeFirstResponder]){
        [_secret becomeFirstResponder];
    }
    return YES;
}



#pragma mark - other
#pragma mark - 其他函数
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_account resignFirstResponder];
    [_secret resignFirstResponder];
}

#pragma mark - 判断和警告
- (BOOL)judgeTheUserName
{
    NSString *username = [_account text];
    if (!username || [username isEqualToString:@""] || [username length]<6) {
        //markmark弹框提示
        [self alertWithInfo:@"用户名不能为空，并且大于6位"];
        return YES;
    }
    return NO;
}
-(BOOL)judgeTheScret
{
    NSString *password = [_secret text];
    NSString *username = [_account text];
    if (!password || [password isEqualToString:@""] || [password length]<6) {
        //markmark弹框提示
        [self alertWithInfo:@"密码必须大于等于六位字符"];
        return YES;
    }
    if ([password isEqualToString:username]) {
        ///markmark弹框提示
        [self alertWithInfo:@"用户名密码不能相同"];
        return YES;
    }
    return NO;
}


@end
