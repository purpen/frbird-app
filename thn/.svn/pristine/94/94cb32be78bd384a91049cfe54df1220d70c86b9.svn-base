//
//  THNTextField.m
//  store
//
//  Created by XiaobinJia on 14-11-7.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNTextField.h"

@implementation THNTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds{
    CGFloat insetX = (self.placeholdOffSet.x == 0)?20:self.placeholdOffSet.x;
    CGFloat insetY = (self.placeholdOffSet.y == 0)?10:self.placeholdOffSet.y;
    return CGRectInset(bounds,insetX,insetY);
}
- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGFloat insetX = (self.textOffSet.x == 0)?20:self.textOffSet.x;
    CGFloat insetY = (self.textOffSet.y == 0)?10:self.textOffSet.y;
    return CGRectInset(bounds,insetX,insetY);
}

- (CGRect)editingRectForBounds:(CGRect)bounds{
    if (!CGRectEqualToRect(CGRectZero, self.textRect)) {
        return self.textRect;
    }
    CGFloat insetX = (self.textOffSet.x == 0)?20:self.textOffSet.x;
    CGFloat insetY = (self.textOffSet.y == 0)?10:self.textOffSet.y;
    return CGRectInset(bounds,insetX,insetY);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds{
    return self.leftViewRect;
}
@end
