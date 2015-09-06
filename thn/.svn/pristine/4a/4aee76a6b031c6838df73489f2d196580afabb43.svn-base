//
//  THNUserManager.h
//  store
//
//  Created by XiaobinJia on 14-11-7.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@class THNUserInfo;
@interface THNUserManager : NSObject
{
    BOOL                *_loginState;
    NSString            *_userid;
}

+ (THNUserManager *)sharedTHNUserManager;

@property (nonatomic, assign, readonly) BOOL            loginState;//是否已经登录
@property (nonatomic, copy) NSString                    *userid;//id
@property (nonatomic, retain, readonly) THNUserInfo                 *userInfo;
/*
@property (nonatomic, copy) NSString                    *grade;
@property (nonatomic, assign) double                    jingyan;
@property (nonatomic, assign) double                    shengji;
@property (nonatomic, assign) int                       yuanbao;
@property (nonatomic, assign) int                       gold;
@property (nonatomic, assign) int                       newMessage;
@property (nonatomic, assign) int                       honor;
*/
- (NSString *)uuid;
+ (NSString *)time;
+ (NSString *)client_id;
+ (NSString *)channel;
+ (NSString *)client_secret;
+ (NSString *)standardDate;

- (NSString *)gender;
- (void)login;
- (void)loginWithAnimation:(BOOL)ani;

- (void)logout;
- (void)storeUserInfo;
- (void)backToGame;
- (void)modifyLocalAvatar:(NSString *)avatar;
- (void)pushController:(UIViewController *)con;
- (void)pushController:(UIViewController *)con animation:(BOOL)ani;

- (void)shareInfo:(NSString *)info Pic:(NSString *)pic;

- (void)thirdLoginWithType:(WeiboType)type;

- (void)loginSuccess;

- (void)refreshUserInfo;
@end
