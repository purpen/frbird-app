//
//  THNProduct.m
//  store
//
//  Created by XiaobinJia on 14-11-11.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNProduct.h"

@implementation THNProduct
@synthesize brief = _brief, skus = _skus, designer = _designer;
- (id)init
{
    if (self = [super init]) {
        _brief = [[THNProductBrief alloc] init];
        _designer = [[THNDesigner alloc] init];
        _designer.designerName = @"太火鸟";
        _designer.designerID = @"10";
        _designer.designerAddress = @"北京";
        _designer.designerDes = @"孵化器";
        _designer.designerAvatar = @"http://frbird.qiniudn.com/avatar/140731/53da1b9d989a6a5d598b6076-avb.jpg";
        
        _productAdImages = [[NSArray alloc] init];
        _skusCount = 0;
    }
    return self;
}
@end
