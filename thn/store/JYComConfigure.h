//
//  JYComConfigure.h
//  xiuxiuNote
//
//  Created by XiaobinJia on 14-10-27.
//  Copyright (c) 2014年 金源互动. All rights reserved.
//

#ifndef xiuxiuNote_JYComConfigure_h
#define xiuxiuNote_JYComConfigure_h
/*
 *下列库只在shareSDK中使用
 SystemConfiguration.framework ，
 QuartzCore.framework ，
 CoreTelephony.framework ，
 libicucore.dylib ，
 libz.1.2.5.dylib ，
 Security.framework
 ibstdc++.dylib
 libsqlite3.dylib
 */
/*****************
 *
 * 所有配置项，如下载路径、缓存路径
 *
 *****************/
#define kTHNAdBannerHeight 202.00001f

//Version 1.0
//#define kTHNMainTableCellHeightPre 376
//#define kTHNMainTableCellHeightSelling 309

#define kTHNMainTableCellHeightPre 266
#define kTHNMainTableCellHeightSelling 266

#define THNUserHeadWidth        360
#define THNUserHeadHeight       360

#define PushWantKey        @"__USERDSFDSPUSH__"


//Crashlystics
#define kAppCrashReport @"671d4f7d050bcc438152a00ad0ddeb4a6144656a"
/**
 
 **/
//轮播图个数
#define kTHNBigImageCount   3


//固定time参数
#define kParaTime @"2014-12-6"

#endif
