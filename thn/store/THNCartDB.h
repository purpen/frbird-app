//
//  THNCartDB.h
//  store
//
//  Created by XiaobinJia on 14-11-12.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "THNCartItem.h"

@interface THNCartDB : NSObject
{
    
}

+ (THNCartDB *)sharedTHNCartDB;

- (NSArray *)allItem;
- (void)deleteItem:(THNCartItem *)item;
- (int)addItem:(THNCartItem *)aItem;
- (void)deleteAll;
- (int)allCount;
@end
