//
//  NSMutableDictionary+AddSign.m
//  JYGameHelper
//
//  Created by Xiaobin Jia on 10/12/13.
//  Copyright (c) 2013 Jinyuan. All rights reserved.
//

#import "NSMutableDictionary+AddSign.h"
#import "NSString+JYComMD5.h"
#import "THNUserManager.h"

@implementation NSMutableDictionary (AddSign)
- (void)addSign
{
    NSArray *keys = [self allKeys];
    JYLog(@"%@",keys);
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        int tmp=0;//比到第几位
        NSNumber *key1;
        NSNumber *key2;
        do {
            if (tmp>([(NSString *)obj1 length]-1)) {
                NSAssert((tmp <= ([(NSString *)obj2 length]-1)), @"传入了两个完全相同的参数！");
                key1 = [NSNumber numberWithShort:0];
                key2 = [NSNumber numberWithShort:[(NSString *)obj2 characterAtIndex:tmp]];
                break;
            }
            if (tmp>([(NSString *)obj2 length]-1)) {
                NSAssert((tmp <= ([(NSString *)obj1 length]-1)), @"传入了两个完全相同的参数！");
                key2 = [NSNumber numberWithShort:0];
                key1 = [NSNumber numberWithShort:[(NSString *)obj1 characterAtIndex:tmp]];
                break;
            }
            key1 = [NSNumber numberWithShort:[(NSString *)obj1 characterAtIndex:tmp]];
            key2 = [NSNumber numberWithShort:[(NSString *)obj2 characterAtIndex:tmp]];
            tmp++;
        } while ([key1 intValue] == [key2 intValue]);
        
        NSComparisonResult result = [key1 compare:key2];
        return result==NSOrderedDescending;
    }];
    NSMutableString *paraStr = [NSMutableString stringWithCapacity:0];
    int i = 0;
    for (NSString *key in sortedKeys) {
        NSString *value = [self objectForKey:key];
        if (i==0) {
            [paraStr appendString:[NSString stringWithFormat:@"%@=%@", key, value]];
        }else{
            [paraStr appendString:[NSString stringWithFormat:@"&%@=%@", key, value]];
        }
        i++;
    }
    [paraStr appendString:[THNUserManager client_secret]];
    [paraStr appendString:[THNUserManager client_id]];
    JYLog(@"%@",paraStr);
    //两次MD5
    NSString *signStrTmp = [paraStr JYComMD5Hash32];
    JYLog(@"%@",signStrTmp);
    NSString *signStr = [signStrTmp JYComMD5Hash32];
    JYLog(@"%@",signStr);
    [self setObject:signStr forKey:@"sign"];
}
@end
