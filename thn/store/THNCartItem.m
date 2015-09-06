//
//  THNCartItem.m
//  store
//
//  Created by XiaobinJia on 14-12-5.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNCartItem.h"

@implementation THNCartItem
@synthesize itemProduct = _itemProduct;
- (id)init
{
    if (self = [super init]) {
        _itemProduct = [[THNProduct alloc] init];
    }
    return self;
}
@end
