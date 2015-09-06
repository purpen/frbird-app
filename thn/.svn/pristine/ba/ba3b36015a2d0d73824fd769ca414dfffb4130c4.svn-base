//
//  ShareEngine.m
//  ShareEngineExample
//
//  Created by 陈欢 on 13-10-8.
//  Copyright (c) 2013年 陈欢. All rights reserved.
//

#import "ShareEngine.h"

@implementation ShareEngine
@synthesize sinaWeiboEngine;

static ShareEngine *sharedSingleton_ = nil;

+ (ShareEngine *) sharedInstance
{
    if (sharedSingleton_ == nil)
    {
        sharedSingleton_ = [NSAllocateObject([self class], 0, NULL) init];
    }
    
    return sharedSingleton_;
}


+ (id) allocWithZone:(NSZone *)zone
{
    return [[self sharedInstance] retain];
}


- (id) copyWithZone:(NSZone*)zone
{
    return self;
}

- (id) retain
{
    return self;
}

- (NSUInteger) retainCount
{
    return NSUIntegerMax; // denotes an object that cannot be released
}

- (void) release
{
    // do nothing
}

- (id) autorelease
{
    return self;
}

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        sinaWeiboEngine = [[SinaWeibo alloc] initWithAppKey:kSinaAppKey appSecret:kSinaSecret appRedirectURI:kSinaRedirectURI andDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    if (nil != sinaWeiboEngine)
    {
        [sinaWeiboEngine release];
        sinaWeiboEngine = nil;
    }
    [super dealloc];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    BOOL weiboRet = NO;
    if ([url.absoluteString hasPrefix:@"sina"])
    {
        weiboRet = [sinaWeiboEngine handleOpenURL:url];
    }
    else
    {
        weiboRet = [WXApi handleOpenURL:url delegate:self];
    }
    return weiboRet;
}

#pragma mark - weibo method

/**
 * @description 存储内容读取
 */
- (void)registerApp
{
    //向微信注册
    [WXApi registerApp:kWeChatAppId];
    [self sinaWeiboReadAuthData];
}

- (BOOL)isLogin:(WeiboType)weiboType
{
    if (sinaWeibo == weiboType)
    {
        return [sinaWeiboEngine isLoggedIn];
    }
    else
    {
        return NO;
    }
}

- (void)loginWithType:(WeiboType)weiboType
{
    if (sinaWeibo == weiboType)
    {
        [sinaWeiboEngine logIn];
    }
    else if(tcWeibo == weiboType)
    {
        [self tcWeiboLogin];
    }
    else
    {
        
    }
}

- (void)logOutWithType:(WeiboType)weiboType
{
    if (sinaWeibo == weiboType)
    {
        [sinaWeiboEngine logOut];
    }
    else
    {
        
    }
}

- (void)sendWeChatMessage:(NSString*)message WithUrl:(NSString*)url image:(UIImage *)image WithType:(WeiboType)weiboType
{
    if(weChat == weiboType)
    {
        [self sendAppContentWithMessage:message WithUrl:url image:image WithScene:WXSceneSession];
        return;
    }
    else if(weChatFriend == weiboType)
    {
        [self sendAppContentWithMessage:message WithUrl:url image:image WithScene:WXSceneTimeline];
        return;
    }
}

- (void)sendShareMessage:(NSString*)message andImage:(UIImage *)image WithType:(WeiboType)weiboType
{
    if (NO == [self isLogin:weiboType])
    {
        [self loginWithType:weiboType];
        return;
    }
    if (sinaWeibo == weiboType)
    {
        [self sinaWeiboPostImage:image WithStatus:message];
    }
    
}

#pragma mark - weibo respon
- (void)loginSuccess:(WeiboType)weibotype
{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(shareEngineDidLogIn:)])
    {
        [self.delegate shareEngineDidLogIn:weibotype];
    }
}

- (void)logOutSuccess:(WeiboType)weibotype
{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(shareEngineDidLogOut:)])
    {
        [self.delegate shareEngineDidLogOut:weibotype];
    }
}

- (void)loginFail
{

}

- (void)weiboSendSuccess
{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(shareEngineSendSuccess)])
    {
        [self.delegate shareEngineSendSuccess];
    }
}

- (void)weiboSendFail:(NSError *)error
{
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(shareEngineSendFail:)])
    {
        [self.delegate shareEngineSendFail:error];
    }
//    if (20019 == error.code)
//    {
//        NSLog(@"重复内容!");
//    }
//    else
//    {
//        NSLog(@"发送失败!");
//    }
}

#pragma mark - SinaWeibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogIn userID = %@ accesstoken = %@ expirationDate = %@ refresh_token = %@", sinaweibo.userID, sinaweibo.accessToken, sinaweibo.expirationDate,sinaweibo.refreshToken);
    
    [self sinaWeiboStoreAuthData];
    
    [self loginSuccess:sinaWeibo];
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogOut");
    [self sinaWeiboRemoveAuthData];
    
    [self logOutSuccess:sinaWeibo];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboLogInDidCancel");
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"sinaweibo logInDidFailWithError %@", error);
    [self loginFail];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"sinaweiboAccessTokenInvalidOrExpired %@", error);
    [self sinaWeiboRemoveAuthData];
    
    [self loginFail];
}

#pragma mark - sinaWeibo method
- (void)sinaWeiboRemoveAuthData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
    [sinaWeiboEngine removeAuthData];
}

- (void)sinaWeiboStoreAuthData
{
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaWeiboEngine.accessToken, AccessTokenKey,
                              sinaWeiboEngine.expirationDate, ExpirationDateKey,
                              sinaWeiboEngine.userID, UserIDKey,
                              sinaWeiboEngine.refreshToken, RefreshTokenKey, nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)sinaWeiboReadAuthData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
    if ([sinaweiboInfo objectForKey:AccessTokenKey] && [sinaweiboInfo objectForKey:ExpirationDateKey] && [sinaweiboInfo objectForKey:UserIDKey])
    {
        sinaWeiboEngine.accessToken = [sinaweiboInfo objectForKey:AccessTokenKey];
        sinaWeiboEngine.expirationDate = [sinaweiboInfo objectForKey:ExpirationDateKey];
        sinaWeiboEngine.userID = [sinaweiboInfo objectForKey:UserIDKey];
    }
}

- (void)sinaWeiboPostStatus:(NSString*)status
{
    [sinaWeiboEngine requestWithURL:@"statuses/update.json"
                             params:[NSMutableDictionary dictionaryWithObjectsAndKeys:status, @"status", nil]
                         httpMethod:@"POST"
                           delegate:self];
}

- (void)sinaWeiboPostImage:(UIImage*)image WithStatus:(NSString*)status
{
    [sinaWeiboEngine requestWithURL:@"statuses/upload.json"
                             params:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     status, @"status",
                                     image, @"pic", nil]
                         httpMethod:@"POST"
                           delegate:self];
}

#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if ([request.url hasSuffix:@"statuses/update.json"])
    {
        [self weiboSendFail:error];
        NSLog(@"Post status failed with error : %@", error);
    }
    else if ([request.url hasSuffix:@"statuses/upload.json"])
    {
        [self weiboSendFail:(NSError *)error];
        NSLog(@"Post image status failed with error : %@", error);
    }
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"statuses/update.json"])
    {
        if ([result objectForKey:@"error_code"])
        {
            [self weiboSendFail:nil];
        }
        else
        {
            [self weiboSendSuccess];
        }
    }
    else if ([request.url hasSuffix:@"statuses/upload.json"])
    {
        [self weiboSendSuccess];
    }
}


#pragma mark - wechat delegate
- (void)weChatPostStatus:(NSString*)message
{
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = YES;
    req.text = message;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
}

- (void)weChatFriendPostStatus:(NSString*)message
{
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = YES;
    req.text = message;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
}

- (void)sendAppContentWithMessage:(NSString*)appMessage WithUrl:(NSString*)appUrl image:(UIImage *)image WithScene:(int)scene
{
    // 发送内容给微信
    
    WXMediaMessage *message = [WXMediaMessage message];
    if (WXSceneTimeline == scene)
    {
        message.title = appMessage;
    }
    else
    {
        message.title = @"太火鸟商城";
    }
    message.description = appMessage;
//    [message setThumbImage:image];
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    UIImage *teleImage = [image TelescopicImageToSize:CGSizeMake(kTHNSharedPicWidth, kTHNSharedPicWidth*height/width)];
    [message setThumbData:UIImageJPEGRepresentation(teleImage, 0.6)];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = appUrl;
//    WXAppExtendObject *ext = [WXAppExtendObject object];
    
//    ext.extInfo = appUrl;
//    ext.fileData = UIImageJPEGRepresentation(image, 0.8);
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

-(void) onSentTextMessage:(BOOL) bSent
{
    // 通过微信发送消息后， 返回本App
    //    NSString *strTitle = [NSString stringWithFormat:@"发送结果"];
    //    NSString *strMsg = [NSString stringWithFormat:@"发送文本消息结果:%u", bSent];
    //
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //    [alert show];
    //    [alert release];
    if (YES == bSent)
    {
        [self weiboSendSuccess];
    }
    else
    {
        [self weiboSendFail:nil];
    }
}

-(void) onSentMediaMessage:(BOOL) bSent
{
    // 通过微信发送消息后， 返回本App
    NSString *strTitle = [NSString stringWithFormat:@"发送结果"];
    NSString *strMsg = [NSString stringWithFormat:@"发送媒体消息结果:%u", bSent];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

-(void) onSentAuthRequest:(NSString *) userName accessToken:(NSString *) token expireDate:(NSDate *) expireDate errorMsg:(NSString *) errMsg
{
    
}

-(void) onShowMediaMessage:(WXMediaMessage *) message
{
    // 微信启动， 有消息内容。
    //    WXAppExtendObject *obj = message.mediaObject;
    
    //    shopDetailViewController *sv = [[shopDetailViewController alloc] initWithNibName:@"shopDetailViewController" bundle:nil];
    //    sv.m_sShopID = obj.extInfo;
    //    [self.navigationController pushViewController:sv animated:YES];
    //    [sv release];
    
    //    NSString *strTitle = [NSString stringWithFormat:@"消息来自微信"];
    //    NSString *strMsg = [NSString stringWithFormat:@"标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%u bytes\n\n", message.title, message.description, obj.extInfo, message.thumbData.length];
    //
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //    [alert show];
    //    [alert release];
}

-(void) onRequestAppMessage
{
    // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
}

-(void) onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        [self onRequestAppMessage];
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        [self onShowMediaMessage:temp.message];
    }
    
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if (0 == resp.errCode)
        {
            [self weiboSendSuccess];
        }
        else
        {
            [self weiboSendFail:nil];
        }
        //        NSString *strTitle = [NSString stringWithFormat:@"发送结果"];
        //        NSString *strMsg = [NSString stringWithFormat:@"发送媒体消息结果:%d", resp.errCode];
        //
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //        [alert show];
        //        [alert release];
    }
    //    else if([resp isKindOfClass:[SendAuthResp class]])
    //    {
    //        NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
    //        NSString *strMsg = [NSString stringWithFormat:@"Auth结果:%d", resp.errCode];
    //
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //        [alert show];
    //        [alert release];
    //    }
}
//登录失败回调
- (void)onFailureLogin:(NSError *)error
{
    [self loginFail];
}
- (void)onSuccessGetUserInfoWhenLogin:(id)ret
{
    JYLog(@"%@",ret)
    [self loginSuccess:tcWeibo];
}
- (void)onFailureGetUserInfoWhenLogin:(id)ret
{
    JYLog(@"%@",ret)
}

- (void)onAccessTokenExpired
{
    [self tcWeiboRemoveAuthData];
    
    [self loginFail];
}

- (void)onLoginOut
{
    [self tcWeiboRemoveAuthData];
    
    [self logOutSuccess:tcWeibo];
}

- (void)createSuccess:(NSDictionary *)dict {
    NSLog(@"%s %@", __FUNCTION__,dict);
    if ([[dict objectForKey:@"ret"] intValue] == 0)
    {
        [self weiboSendSuccess];
        NSLog(@"发送成功！");
    }
    else
    {
        [self weiboSendFail:nil];
        NSLog(@"发送失败！");
    }
}

- (void)createFail:(NSError *)error
{
    [self weiboSendFail:nil];
    NSLog(@"发送失败!error is %@",error);
}

@end
