//
//  NSDictionary+JYComModel.m
//  JYGameHelper
//
//  Created by Xiaobin Jia on 9/13/13.
//  Copyright (c) 2013 Jinyuan. All rights reserved.
//

#import "NSDictionary+ModelParse.h"

@implementation NSDictionary (ModelParse)
- (NSString *)stringValueForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }else{
        if ([obj isKindOfClass:[NSNull class]]) {
            return @"";
        }
        NSString *des = [NSString stringWithFormat:@"在解析服务端数据时候，某个字符串内容为:%@",[obj class]];
        JYLog(@"%@",des);
        return [NSString stringWithFormat:@"%@",obj];
    }
}
- (int)longValueForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNull class]]) {
        return 0;
    }
    if (obj) {
        return [obj longValue];
    }else{
        JYLog(@"在解析服务端数据时候，某个整形内容为(null)");
        return 0;
    }
}
- (int)intValueForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNull class]]) {
        return 0;
    }
    if (obj) {
        return [obj intValue];
    }else{
        JYLog(@"在解析服务端数据时候，某个整形内容为(null)");
        return 0;
    }
}
- (float)floatValueForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNull class]]) {
        return 0.0f;
    }
    if (obj) {
        return [obj floatValue];
    }else{
        JYLog(@"在解析服务端数据时候，某个浮点型内容为(null)");
        return 0.0;
    }
}
- (double)doubleValueForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNull class]]) {
        return 0.0;
    }
    if (obj) {
        return [obj doubleValue];
    }else{
        JYLog(@"在解析服务端数据时候，某个浮点型内容为(null)");
        return 0.0;
    }
}
- (BOOL)boolValueForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNull class]]) {
#warning 当服务端返回值为空时候默认置为NO
        return NO;
    }
    if (obj) {
        return [obj boolValue];
    }else{
        JYLog(@"在解析服务端数据时候，某个布尔内容为(null)");
        return NO;
    }
}

@end
