//
//  UIView+CreateSepret.m
//  JYGameHelper
//
//  Created by Xiaobin Jia on 9/24/13.
//  Copyright (c) 2013 Jinyuan. All rights reserved.
//

#import "UIView+CreateSepret.h"

@implementation UIView (CreateSepret)

- (void)createGapWithPointOne:(CGPoint)p1 pointTwo:(CGPoint)p2
{
    [self createGapWithPointOne:p1 pointTwo:p2 andR:0.89 G:0.89 B:0.89 andWidth:1.0];
}
//用一个像素的颜色值加个间隔线
- (void)createGapWithPointOne:(CGPoint)p1 pointTwo:(CGPoint)p2 andR:(float)r G:(float)g B:(float)b andWidth:(float)wi
{
    [self addSubview:[self getGapImageViewWithPointOne:p1 pointTwo:p2 andR:r G:g B:b andWidth:wi]];
}

- (UIImageView *)getGapImageViewWithPointOne:(CGPoint)p1 pointTwo:(CGPoint)p2 andR:(float)r G:(float)g B:(float)b andWidth:(float)wi{
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:frame];
    
    UIGraphicsBeginImageContext(imageView.frame.size);
    [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), NO);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), wi);  //线宽
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), YES);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), r, g, b, 1.0);  //颜色
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), p1.x+.5f, p1.y+.5f);  //起点坐标
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), p2.x+.5f, p2.y+.5f);   //终点坐标
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    imageView.image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [imageView autorelease];
}

@end
