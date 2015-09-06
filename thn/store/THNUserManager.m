//
//  THNUserManager.m
//  store
//
//  Created by XiaobinJia on 14-11-7.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNUserManager.h"
#import "THNUMNavController.h"
#import "JYComEncryptorDES.h"
#import <JSONKit/JSONKit.h>
#import "THNHomeViewController.h"
#import "THNWeiboUser.h"
#import "ShareEngine.h"
#import "THNAppDelegate.h"
#import "JYComHttpRequest.h"
#import "THNUserInfo.h"
#import "NSMutableDictionary+AddSign.h"

#define kJYComLocalKeyUUID @"THN__uuid__"
/*
 UserManager不仅管理用户的登录注册信息，而且管理界面的另一个window
 */
@interface THNUserManager()<JYComHttpRequestDelegate>
@property (nonatomic, retain) UIWindow *umWindow;
@property (nonatomic, retain) UIViewController *umRoot;
@property (nonatomic, retain) UIWindow *lastKeyWindow;
@end

@implementation THNUserManager
{
    THNWeiboUser *_weiboUser;
    JYComHttpRequest *_request;
    THNUserInfo *_userInfo;
}
@synthesize umWindow = _umWindow, lastKeyWindow = _lastKeyWindow, umRoot = _umRoot;
@synthesize userid = _userid, userInfo = _userInfo;
@dynamic loginState;
SYNTHESIZE_SINGLETON_FOR_CLASS(THNUserManager);

- (id)init
{
    if (self = [super init]) {
        //添加新的window
        _umWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _umWindow.windowLevel = UIWindowLevelNormal;
        _umWindow.userInteractionEnabled = YES;
        _umWindow.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5f];
        _umWindow.hidden = YES;
        _umRoot = [[UIViewController alloc] init];
        THNUMNavController *umNav = [[THNUMNavController alloc] initWithRootViewController:_umRoot];
        umNav.navigationBarHidden = YES;
        [_umWindow setRootViewController:umNav];
        [umNav release];
        
        //读取登录信息
        NSString *logInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kTHNUserInfoPath];
        if (logInfo) {
            //解密
            NSString *decrypted = [JYComEncryptorDES decryptBase64String:logInfo
                                                            keyString:@"keykeyke"];
            //解析Json数据
            NSDictionary *ret = [decrypted objectFromJSONString];
            if (ret) {
                self.userid = [ret objectForKey:@"userid"];
            }else{
                //初始化各个值为未登录默认值
                [self resetValue];
            }
        }else{
            //初始化各个值为未登录默认值
            [self resetValue];
        }
    }
    return self;
}

- (void)dealloc
{
    [_request clearDelegatesAndCancel];
    _request = nil;
    [super dealloc];
}

#pragma mark -  1
#pragma mark - 取得获取用户信息
- (BOOL)loginState
{
    if (!self.userid || [self.userid isEqualToString:@""]) {
        return NO;
    }
    return YES;
}
- (void)setLoginState:(BOOL)loginState
{
    return;
}
/*
 *  修改头像之后修改本地保存的头像信息
 */
- (void)modifyLocalAvatar:(NSString *)avatar
{
    self.userInfo.userAvata = avatar;
    [self storeDetailUserInfo];
}

#pragma mark - 基本资料
- (NSString *)gender
{
    if (self.userInfo.userSex == 1) {
        return @"男";
    }else if (self.userInfo.userSex == 2) {
        return @"女";
    }else{
        return @"";
    }
}
- (NSString *)uuid
{
    //将UUID本地化
    NSString *k = [[NSUserDefaults standardUserDefaults] objectForKey:kJYComLocalKeyUUID];
    if (k) {
        return k;
    }
    //如果k为空，就创建一个新的，并调用保存（处理被人工从沙盒删除的异常情况）
    //如果此时的private key不为空或者userid不为@“0”，属于异常情况，防止再次创建新的uuid漏洞
    NSString *k2 = [self pri_uuid];
    [self saveUUIDToLocal:k2];
    return k2;
}
- (void)saveUUIDToLocal:(NSString *)uuid
{
    //将privateKey本地化
    NSString *k = [[NSUserDefaults standardUserDefaults] objectForKey:kJYComLocalKeyUUID];
    if (!k) {
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:kJYComLocalKeyUUID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
- (NSString*)pri_uuid {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFStringCreateCopy( NULL, uuidString);
    NSLog(@"UUID %@",result);
    CFRelease(puuid);
    CFRelease(uuidString);
    return [result autorelease];
}

+ (NSString *)time
{
    NSDate *sendDate = [NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    NSCalendar  *cal=[NSCalendar  currentCalendar];
    NSUInteger  unitFlags = NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:sendDate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month];
    NSInteger day=[conponent day];
    NSString *  nsDateString= [NSString  stringWithFormat:@"%4ld-%2ld-%2ld",(long)year,(long)month,(long)day];
    
    [dateformatter release];
    return nsDateString;
}
+ (NSString *)channel
{
    return @"appstore";
}
+ (NSString *)client_id
{
    return @"1415289600";
}
+ (NSString *)client_secret
{
    return @"545d9f8aac6b7a4d04abffe5";
}
#pragma mark - 2
#pragma mark - User Interaction
- (void)login
{
    [self loginWithAnimation:YES];
}
- (void)loginWithAnimation:(BOOL)ani
{
    if (!self.loginState) {
        THNHomeViewController *logView = [[THNHomeViewController alloc] init];
        [self pushController:logView animation:ani];
        //[logView release];
    }
    JYLog(@"打开登录界面");
}

- (void)loginSuccess
{
    [self storeUserInfo];
    [SharedApp resetTabC];
    [self backToGame];
    if (![SharedApp.window isKeyWindow]) {
        
        [SharedApp.window makeKeyAndVisible];
    }
}

- (void)logout
{
    [self removeUserInfo];
    [self removeDetailUserInfo];
    [self resetValue];
}
#pragma mark - 本地化信息
- (void)storeUserInfo
{
    //VbSu4SFKoEli5Hrmf2IzZA==         - 64
    //VbSu4SFKoEli5Hrmf2IzZA==         - 32 {"userid":"8"}
    NSDictionary *storeDic = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.userid, @"userid",
                              nil];
    NSString *storeData = [storeDic JSONString];
    NSString *encrypted = [JYComEncryptorDES encryptBase64String:storeData keyString:@"keykeyke"];
    [[NSUserDefaults standardUserDefaults] setObject:encrypted forKey:kTHNUserInfoPath];
    BOOL status = [[NSUserDefaults standardUserDefaults] synchronize];
    if (status == YES){
        NSLog(@"store success.");
    } else {
        NSLog(@"store fail.");
    }
}
- (void)storeDetailUserInfo
{
    NSDictionary *storeDic = [NSDictionary dictionaryWithObjectsAndKeys:
                              _userInfo.userAccount, @"account",
                              _userInfo.userNickName, @"nickname",
                              _userInfo.userAvata, @"avatar",
                              _userInfo.userCity, @"city",
                              _userInfo.userid, @"_id",
                              _userInfo.userJob, @"job",
                              _userInfo.userPhone, @"phone",
                              [NSString stringWithFormat:@"%d",_userInfo.userSex], @"sex",
                              _userInfo.userSummery, @"summary",
                              _userInfo.userMail, @"mail",
                              _userInfo.userAddress, @"address",
                              _userInfo.userRealname, @"realname",
                              nil];
    NSString *storeData = [storeDic JSONString];
    NSString *encrypted = [JYComEncryptorDES encryptBase64String:storeData keyString:@"key"];
    [[NSUserDefaults standardUserDefaults] setObject:encrypted forKey:kTHNDetailUserInfoPath];
    BOOL status = [[NSUserDefaults standardUserDefaults] synchronize];
    if (status == YES){
        NSLog(@"store success.");
    } else {
        NSLog(@"store fail.");
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserInfoStored" object:nil userInfo:nil];
}
- (void)removeUserInfo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTHNUserInfoPath];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)removeDetailUserInfo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTHNDetailUserInfoPath];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Weibo Control
- (void)thirdLoginWithType:(WeiboType)type;
{
    if (!_weiboUser) {
        _weiboUser = [[THNWeiboUser alloc] init];
    }
    if (type == sinaWeibo) {
        _weiboUser.weiboType = sinaWeibo;
        _weiboUser.weiboUserID = [ShareEngine sharedInstance].sinaWeiboEngine.userID;
        _weiboUser.weiboUserAccessToken = [ShareEngine sharedInstance].sinaWeiboEngine.accessToken;
        _weiboUser.weiboUserExDate =  [NSString stringWithFormat:@"%ld", (long)[[ShareEngine sharedInstance].sinaWeiboEngine.expirationDate timeIntervalSince1970]];
        _weiboUser.weiboUserRefrehToken = [ShareEngine sharedInstance].sinaWeiboEngine.refreshToken;
        _weiboUser.weiboUserName = [ShareEngine sharedInstance].sinaWeiboEngine.username;
        _weiboUser.weiboUserAvatar = [ShareEngine sharedInstance].sinaWeiboEngine.usericon;
    }
    
    //请求服务器进行第三方登陆
    /*
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   
                                   [self uuid],                     @"uuid",
                                   [self time],                     @"time",
                                   [self clientID],                 @"client_id",
                                   [self channel],                  @"channel",
                                   
                                   @"1",                            @"logintype",
                                   opentype,                        @"open_type",
                                   openuid,                         @"open_uid",
                                   token,                           @"open_accesstoken",
                                   ex,                              @"open_expiryin",
                                   uname,                           @"nickname",
                                   uIcon,                           @"avatar",
                                   rToken,                          @"open_refreshtoken",
                                   
                                   nil];
    [self addSign:params];
    [self.request clearDelegatesAndCancel];
    self.request.delegate = self;
    [self.request postInfoWithParas:params andUrl:JYApiThirdLogin];
    self.requestHud = AlertLoading(@"正在登录...");
    */
}

#pragma mark - 3
#pragma mark - Other Windows
- (void)pushController:(UIViewController *)con
{
    [self pushController:con animation:NO];
}
- (void)pushController:(UIViewController *)con animation:(BOOL)ani
{
    //先出来混，再变老大
    [_umWindow setHidden:NO];
    self.lastKeyWindow = [UIApplication sharedApplication].keyWindow;
    [_umWindow makeKeyWindow];
    [_umRoot.navigationController pushViewController:con animated:NO];
    
    CGRect lastKeyFrame = self.lastKeyWindow.frame;
    //进入动画
    CGRect frame = con.view.frame;
    CGRect navFrame = _umRoot.navigationController.navigationBar.frame;
    con.view.frame = CGRectMake(320, frame.origin.y-44, frame.size.width, frame.size.height);
    _umRoot.navigationController.navigationBar.frame = CGRectMake(320, navFrame.origin.y, navFrame.size.width, navFrame.size.height);
    
    [UIView beginAnimations:@"NavAni" context:nil];
    [UIView setAnimationDuration:(ani?.3f:.0f)];
    con.view.frame = CGRectMake(0, frame.origin.y, frame.size.width, frame.size.height);
    _umRoot.navigationController.navigationBar.frame = CGRectMake(0, navFrame.origin.y, navFrame.size.width, navFrame.size.height);
    self.lastKeyWindow.frame = CGRectMake(-320, lastKeyFrame.origin.y, lastKeyFrame.size.width, lastKeyFrame.size.height);
    [UIView commitAnimations];
}

- (void)backToGame
{
    //退出动画
    CGRect lastKeyFrame = self.lastKeyWindow.frame;
    UIViewController *con = [_umRoot.navigationController.viewControllers lastObject];
    CGRect frame = con.view.frame;
    CGRect navFrame = _umRoot.navigationController.navigationBar.frame;
    [UIView beginAnimations:@"NavAni" context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(backToGameAniStop)];
    con.view.frame = CGRectMake(320, frame.origin.y, frame.size.width, frame.size.height);
    _umRoot.navigationController.navigationBar.frame = CGRectMake(320, navFrame.origin.y, navFrame.size.width, navFrame.size.height);
    self.lastKeyWindow.frame = CGRectMake(0, lastKeyFrame.origin.y, lastKeyFrame.size.width, lastKeyFrame.size.height);
    [UIView commitAnimations];
    
}
- (void)backToGameAniStop
{
    [(THNUMNavController *)_umRoot.navigationController popLast];
    //先交出权，你再消失
    if (self.lastKeyWindow) {
        if (![self.lastKeyWindow isKeyWindow]) {
            [self.lastKeyWindow makeKeyWindow];
        }
        [_umWindow setHidden:YES];
    }
    self.lastKeyWindow = nil;
}

#pragma mark - 4
#pragma mark - 初始化其他值
- (void)resetValue
{
    _userid = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [self login];
    }
}
#pragma mark - userinfo
- (void)refreshUserInfo
{
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[THNUserManager sharedTHNUserManager] userid],    @"id",
                                     [THNUserManager channel],                          @"channel",
                                     [THNUserManager client_id],                        @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],      @"uuid",
                                     [THNUserManager time],                             @"time",
                                     nil];
    [listPara addSign];
    //开始请求商品详情
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiAccountUserInfo]];
}
#pragma mark - JYComHttp delegate
- (void)jyRequest:(id)jyRequest didFailLoading:(NSError *)error{
    
    NSString *errorInfo = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    JYLog(@"request error:%@",errorInfo);
    //读取用户详细信息的缓存
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *logInfo = [defaults objectForKey:kTHNDetailUserInfoPath];
    if (logInfo) {
        //解密
        NSString *decrypted = [JYComEncryptorDES decryptBase64String:logInfo
                                                           keyString:@"key"];
        //解析Json数据
        NSDictionary *result = [decrypted objectFromJSONString];
        if (result) {
            THNUserInfo *userInfo = [[THNUserInfo alloc] init];
            userInfo.userAccount =      [result stringValueForKey:@"account"];
            userInfo.userNickName =     [result stringValueForKey:@"nickname"];
            userInfo.userAvata =        [result stringValueForKey:@"avatar"];
            userInfo.userCity =         [result stringValueForKey:@"city"];
            userInfo.userid =           [result stringValueForKey:@"_id"];
            userInfo.userJob =          [result stringValueForKey:@"job"];
            userInfo.userPhone =        [result stringValueForKey:@"phone"];
            userInfo.userSex =          [result intValueForKey:@"sex"];
            userInfo.userSummery =      [result stringValueForKey:@"summary"];
            userInfo.userAddress =      [result stringValueForKey:@"address"];
            userInfo.userMail =      [result stringValueForKey:@"mail"];
            userInfo.userRealname =      [result stringValueForKey:@"realname"];
            _userInfo = userInfo;
        }
    }
}

- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result{
    JYLog(@"receive result:%@",result);
    if ([result isKindOfClass:[NSDictionary class]]) {
        THNUserInfo *userInfo = [[THNUserInfo alloc] init];
        userInfo.userAccount =      [result stringValueForKey:@"account"];
        userInfo.userNickName =     [result stringValueForKey:@"nickname"];
        userInfo.userAvata =        [result stringValueForKey:@"avatar"];
        userInfo.userCity =         [result stringValueForKey:@"city"];
        userInfo.userid =           [result stringValueForKey:@"_id"];
        userInfo.userJob =          [result stringValueForKey:@"job"];
        userInfo.userPhone =        [result stringValueForKey:@"phone"];
        userInfo.userSex =          [result intValueForKey:@"sex"];
        userInfo.userSummery =      [result stringValueForKey:@"summary"];
        userInfo.userMail =         [result stringValueForKey:@"email"];
        NSDictionary *profile = [result objectForKey:@"profile"];
        if (profile) {
            userInfo.userAddress = [profile stringValueForKey:@"address"];
            userInfo.userRealname = [profile stringValueForKey:@"realname"];
        }
        _userInfo = userInfo;
    }
    [self storeDetailUserInfo];
}

@end
