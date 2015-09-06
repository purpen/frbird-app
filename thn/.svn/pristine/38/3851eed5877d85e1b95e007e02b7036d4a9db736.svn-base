//
//  THNTagView.m
//  store
//
//  Created by XiaobinJia on 14-11-24.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNTagView.h"

@implementation THNTagView
{
    int _lineNum;
}

- (id)initWithFrame:(CGRect)frame andLines:(int)num
{
    if (self = [super initWithFrame:frame]) {
        _lineNum = num;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, UIColorFromRGB(0xcccccc).CGColor);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, .5);
    for(int i = 0; i < _lineNum; i++)
    {
        CGContextMoveToPoint(context, 0, 35*i+35);
        CGContextAddLineToPoint(context, SCREEN_WIDTH, 35*i+35);
    }
    CGContextStrokePath(context);
}

@end
