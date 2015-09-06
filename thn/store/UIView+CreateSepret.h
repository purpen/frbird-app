//
//  UIView+CreateSepret.h
//  JYGameHelper
//
//  Created by Xiaobin Jia on 9/24/13.
//  Copyright (c) 2013 Jinyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CreateSepret)
/*
 * @fun 在两点之间画线
 * @para 点1和点2 (CGPoint)
 */
- (void)createGapWithPointOne:(CGPoint)p1 pointTwo:(CGPoint)p2;
/*
 * @fun 在两点之间画线
 * @para 点1和点2 (CGPoint) RGB值 和线宽度
 */
- (void)createGapWithPointOne:(CGPoint)p1 pointTwo:(CGPoint)p2 andR:(float)r G:(float)g B:(float)b andWidth:(float)wi;
/*
 * @fun 在两点之间画线并返回线的UIImage对象
 * @para 点1和点2 (CGPoint) RGB值 和线宽度
 */
- (UIImageView *)getGapImageViewWithPointOne:(CGPoint)p1 pointTwo:(CGPoint)p2 andR:(float)r G:(float)g B:(float)b andWidth:(float)wi;

@end
