//
//  NSDictionary+ModelParse.h
//  store
//
//  Created by Xiaobin Jia on 9/13/13.
//  Copyright (c) 2013 TaiHuoNiao. All rights reserved.
//

/*
 *  用于HTTP控制层解析数据，封装报错处理
 *
 *  需要在这个类中添加对服务端返回的异常数据的处理
 */
#import <Foundation/Foundation.h>

@interface NSDictionary (ModelParse)
- (NSString *)stringValueForKey:(NSString *)key;
- (int)intValueForKey:(NSString *)key;
- (float)floatValueForKey:(NSString *)key;
- (BOOL)boolValueForKey:(NSString *)key;
- (double)doubleValueForKey:(NSString *)key;
- (int)longValueForKey:(NSString *)key;
@end
