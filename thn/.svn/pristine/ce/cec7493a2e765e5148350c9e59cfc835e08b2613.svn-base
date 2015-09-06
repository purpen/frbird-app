//
//  JYComFunction.h
//  xiuxiuNote
//
//  Created by XiaobinJia on 14-10-27.
//  Copyright (c) 2014年 金源互动. All rights reserved.
//

#ifndef xiuxiuNote_JYComFunction_h
#define xiuxiuNote_JYComFunction_h

/*****************
 *
 * 功能配置项
 *
 *****************/

//客户端版本
#define ClientVersion                   @"1.2.1"

//Error Domain
#define kJYComDomain                    @"JYComDomain"
#define kJYComErrorServerError          60001
#define kJYComErrorParseError           60002
#define kJYComErrorNetError             60003

//路径
#define kTHNUserInfoPath    @"THNStoreUInfo__"
#define kTHNDetailUserInfoPath    @"THNStoreDetailUInfo__"
#define kTHNWeiboInfoPath   @"THNStoreWInfo__"

//用户设备系统版本
#define IOS7_OR_LATER                   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
#define IOS8_OR_LATER                   ( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending )

//判断是否是4寸屏
#define IS_IPHONE5                      (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

//屏幕宽高
#define SCREEN_HEIGHT                    [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH                     [[UIScreen mainScreen] bounds].size.width

//无参数的Block回调
typedef void (^CallbackBlock)(void);
//带一个参数的block回调
typedef void (^CallbackBlockWithPara)(id para);

//RGB值读取颜色
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#endif
