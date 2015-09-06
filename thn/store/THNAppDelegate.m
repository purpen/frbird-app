//
//  THNAppDelegate.m
//  store
//
//  Created by XiaobinJia on 14-11-7.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNAppDelegate.h"
#import "THNTabBarViewController.h"
#import "THNUserManager.h"
#import "THNCartDB.h"
#import "ShareEngine.h"
#import "XGPush.h"
#import "XGSetting.h"
#import "THNAreaMaker.h"
#import "THNWebViewController.h"
#import "THNProductViewController.h"
#import "THNYuShouViewController.h"
#import "THNBaseNavController.h"
#import "THNPayViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <AlipaySDK/AlipaySDK.h>
#import "MobClick.h"
//for mac
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

//for idfa
#import <AdSupport/AdSupport.h>

@interface THNAppDelegate ()
@property (nonatomic, retain) THNAreaMaker *maker;
@property (nonatomic, retain) NSDictionary *pushUserInfo;
@end

@implementation THNAppDelegate
@synthesize maker = _maker, pushUserInfo = _pushUserInfo, payViewController = _payViewController;
- (void)registerPushForIOS8{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    //Types
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    //Actions
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    //Categories
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    inviteCategory.identifier = @"INVITE_CATEGORY";
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}

- (void)registerPush{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}
- (NSString * )macString{
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *macString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return macString;
}

- (NSString *)idfaString {
    
    NSBundle *adSupportBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/AdSupport.framework"];
    [adSupportBundle load];
    
    if (adSupportBundle == nil) {
        return @"";
    }
    else{
        
        Class asIdentifierMClass = NSClassFromString(@"ASIdentifierManager");
        
        if(asIdentifierMClass == nil){
            return @"";
        }
        else{
            
            //for no arc
            //ASIdentifierManager *asIM = [[[asIdentifierMClass alloc] init] autorelease];
            //for arc
            ASIdentifierManager *asIM = [[asIdentifierMClass alloc] init];
            
            if (asIM == nil) {
                return @"";
            }
            else{
                
                if(asIM.advertisingTrackingEnabled){
                    return [asIM.advertisingIdentifier UUIDString];
                }
                else{
                    return [asIM.advertisingIdentifier UUIDString];
                }
            }
        }
    }
}

- (NSString *)idfvString
{
    if([[UIDevice currentDevice] respondsToSelector:@selector( identifierForVendor)]) {
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return @"";
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    /*获取区域配置文件时候使用
    self.maker = [[THNAreaMaker alloc] init];
    [self.maker refreshArea];*/
    ///*
    //友盟统计
    [MobClick setLogEnabled:kAppDebug];
    [MobClick setAppVersion:[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
    [MobClick setCrashReportEnabled:NO];
    [MobClick startWithAppkey:@"54db2bcffd98c5c9e0000c71" reportPolicy:(ReportPolicy)REALTIME channelId:@"appstore"];
    [MobClick checkUpdate];
    // 友盟推广统计
    // 下载链接：https://itunes.apple.com/cn/app/tai-huo-niao-ding-jian-chuang/id946737402?mt=8
    NSString * appKey = @"54db2bcffd98c5c9e0000c71";
    NSString * deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * mac = [self macString];
    NSString * idfa = [self idfaString];
    NSString * idfv = [self idfvString];
    NSString * urlString = [NSString stringWithFormat:@"http://log.umtrack.com/ping/%@/?devicename=%@&mac=%@&idfa=%@&idfv=%@", appKey, deviceName, mac, idfa, idfv];
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:urlString]] delegate:nil];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] <= 6.0) {
        NSDictionary *navbarTitle = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0],
                                      NSShadowAttributeName:[UIColor colorWithWhite:0.15 alpha:1.0],
                                      NSShadowAttributeName:[UIColor clearColor],
                                      NSShadowAttributeName:[NSValue valueWithCGSize:CGSizeMake(0, 0)]};
        
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.794 green:0.792 blue:0.82 alpha:1.0]];
        [[UINavigationBar appearance] setTitleTextAttributes:navbarTitle];
        [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:2.0 forBarMetrics:UIBarMetricsDefault];
    }
    JYLog(@"%@",NSHomeDirectory());
    [[ShareEngine sharedInstance] registerApp];
    
    [Fabric with:@[CrashlyticsKit]];
    [Crashlytics startWithAPIKey:kAppCrashReport];
    
    THNUserManager *um = [THNUserManager sharedTHNUserManager];
    if (!um.loginState) {
        [um loginWithAnimation:NO];
    }else{
        [self resetTabC];
        [self.window makeKeyAndVisible];
    }
    [XGPush startApp:2200069812 appKey:@"I949LHU9N6HC"];
    [XGPush setAccount:[[THNUserManager sharedTHNUserManager] uuid]];
    if (![XGPush isUnRegisterStatus]) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
        float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (sysVer < 8) {
            [self registerPush];
        }
        else
        {
            [self registerPushForIOS8];
        }
#else
        [self registerPush];
#endif
    }//*/
    return YES;
}

#pragma mark - UI Config

- (void)tabCUserInteractable:(BOOL)can
{
    ((UITabBarController *)self.window.rootViewController).tabBar.userInteractionEnabled = can;
}
- (void)resetTabC
{
    [[THNUserManager sharedTHNUserManager] refreshUserInfo];
    THNTabBarViewController *tabC = [[THNTabBarViewController alloc] init];
    tabC.tabBar.translucent = NO;
    tabC.delegate = self;
    self.window.rootViewController = tabC;
    self.window.backgroundColor = [UIColor whiteColor];
}

#pragma mark - push
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceTokenStr = [XGPush registerDevice:deviceToken];
    
    [XGPush registerDevice:deviceToken];
    
    JYLog(@"deviceToken %@",deviceTokenStr);
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    JYLog(@"获取TOKEN失败，ERROR：%@",error);
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    //如果极简SDK不可用，会跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给SDK
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [self.payViewController hideHUD];
            self.payViewController = nil;
            NSInteger code = [resultDic[@"resultStatus"] integerValue];
            if (code == 9000 ) {
                [self showAlertViewToTips:@"支付成功" tag:200];
            }else
            {
                [self showAlertViewToTips:@"支付失败请重试！" tag:100];
            }
        }];
    }
    if ([url.host isEqualToString:@"platformapi"]){
        //支付宝钱包快登授权返回authCode
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            
        }];
    }
    return YES;
}
-(void)showAlertViewToTips:(NSString *)tips tag:(NSInteger)tag
{
    UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:tips delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = tag;
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==200&&buttonIndex == 1) {
        UITabBarController *tabBar = (UITabBarController*)[UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController *nav = (UINavigationController*)tabBar.selectedViewController;
        [nav popToRootViewControllerAnimated:YES];
    }
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [[ShareEngine sharedInstance] handleOpenURL:url];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (![THNUserManager sharedTHNUserManager].loginState) {
        return;
    }
    //推送反馈(app运行时)
    [XGPush handleReceiveNotification:userInfo];
    
    void (^successBlock)(void) = ^(void){
        //推送结构
        //网页 type=1 url
        //商品 type=2 productID
        JYLog(@"%@",userInfo);
        
        NSDictionary *infoDict = [userInfo objectForKey:@"aps"];
        NSString *info = [infoDict objectForKey:@"alert"];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"通知" message:info delegate:self cancelButtonTitle:@"查看" otherButtonTitles:@"取消", nil];
        alertView.tag = 301;
        alertView.delegate = self;
        [alertView show];
        
        self.pushUserInfo = userInfo;
    };
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        JYLog(@"[XGPush]handleReceiveNotification errorBlock");
    };
    void (^completion)(void) = ^(void){
        //失败之后的处理
        JYLog(@"[xg push completion]userInfo is %@",userInfo);
    };
    [XGPush handleReceiveNotification:userInfo successCallback:successBlock errorCallback:errorBlock completion:completion];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary *userInfo = self.pushUserInfo;
    if (alertView.tag == 301) {
        
        if (buttonIndex == 0) {
            int type = [[userInfo objectForKey:@"type"] intValue];
            if (type==1) {
                //1为webView
                NSString *url = [userInfo objectForKey:@"url"];
                THNWebViewController *webViewController = [[THNWebViewController alloc] initWithUrl:url];
                THNBaseNavController *nav = [[THNBaseNavController alloc] initWithRootViewController:webViewController];
                webViewController.isPush = YES;
                nav.hidesBottomBarWhenPushed = YES;
                [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
            }else if(type==2){
                //2为商店商品
                NSString *productID = [userInfo objectForKey:@"product_id"];
                THNProductBrief *product = [[THNProductBrief alloc] init];
                product.productID = productID;
                THNProductViewController *productViewController = [[THNProductViewController alloc] initWithProduct:product coverImage:nil];
                THNBaseNavController *nav = [[THNBaseNavController alloc] initWithRootViewController:productViewController];
                productViewController.isPush = YES;
                nav.hidesBottomBarWhenPushed = YES;
                [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
            }else if(type==3){
                //3为预售商品
                //2为商店商品
                NSString *productID = [userInfo objectForKey:@"product_id"];
                THNProductBrief *product = [[THNProductBrief alloc] init];
                product.productID = productID;
                THNYuShouViewController *productViewController = [[THNYuShouViewController alloc] initWithProduct:product coverImage:nil];
                THNBaseNavController *nav = [[THNBaseNavController alloc] initWithRootViewController:productViewController];
                productViewController.isPush = YES;
                nav.hidesBottomBarWhenPushed = YES;
                [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
            }
        }else{
        
        }
        
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    /*程序启动就将角标置为0*/
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end
