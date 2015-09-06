//
//  JYComCustomTextField.m
//  xiuxiuNote
//
//  Created by XiaobinJia on 14-11-19.
//  Copyright (c) 2014年 金源互动. All rights reserved.
//

#import "JYComCustomTextField.h"

@implementation JYComCustomTextField

//控制placeHolder的颜色、字体
- (void)drawPlaceholderInRect:(CGRect)rect
{
    UIColor *placeholderColor = UIColorFromRGB(0x6e6e6e);//设置颜色
    [placeholderColor setFill];
    
    CGRect placeholderRect = CGRectMake(rect.origin.x, (rect.size.height- self.font.pointSize)/2, rect.size.width, rect.size.height);//设置距离
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.alignment = self.textAlignment;
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:
                          style, NSParagraphStyleAttributeName,
                          self.font, NSFontAttributeName,
                          placeholderColor, NSForegroundColorAttributeName, nil];
    
    [self.placeholder drawInRect:placeholderRect withAttributes:attr];
}
@end
