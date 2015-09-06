//
//  UIButton+THNButtonImageAndLabel.h
//  store
//
//  Created by XiaobinJia on 14-11-18.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (THNButtonImageAndLabel)
- (void) setImage:(UIImage *)image withTitle:(NSString *)title andTitleColor:(UIColor *)color forState:(UIControlState)stateType;
@end
