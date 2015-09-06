//
//  JYComLogManager.h
//  xiuxiuNote
//
//  Created by XiaobinJia on 14-10-27.
//  Copyright (c) 2014年 金源互动. All rights reserved.
//

#ifndef xiuxiuNote_JYComLogManager_h
#define xiuxiuNote_JYComLogManager_h

/*****************
 *
 * 调试期间Log的统一管理，尽量少用NSLog
 *
 *****************/

#define kAppDebug 0

#if kAppDebug
#define JYLog(fmt, ...)                             NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define JYLog(...)

#endif

#endif
