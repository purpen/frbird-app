//
//  UIButton+THNButtonImageAndLabel.m
//  store
//
//  Created by XiaobinJia on 14-11-18.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "UIButton+THNButtonImageAndLabel.h"

@implementation UIButton (THNButtonImageAndLabel)
- (void) setImage:(UIImage *)image withTitle:(NSString *)title andTitleColor:(UIColor *)color forState:(UIControlState)stateType {
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:12]];
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self setImageEdgeInsets:UIEdgeInsetsMake(-15.0,
                                              0.0,
                                              0.0,
                                              -titleSize.width)];
    [self setImage:image forState:stateType];
    
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.titleLabel setTextColor:[UIColor blackColor]];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(30.0,
                                              -image.size.width,
                                              0.0,
                                              0.0)];
    [self setTitle:title forState:stateType];
    
    [self setTitleColor:color forState:stateType];
}
@end
