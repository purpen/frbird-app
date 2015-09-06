//
//  THNTopicCategory.m
//  store
//
//  Created by XiaobinJia on 14-12-1.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNTopicCategory.h"

@implementation THNTopicCategory
- (BOOL)isMainCate
{
    return self.catePID==0?YES:NO;
}
@end
