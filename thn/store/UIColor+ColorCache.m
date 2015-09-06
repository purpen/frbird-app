//
//  UIColor+randomColor.m
//  HaojyClient
//
//  Created by Robinkey on 14-4-14.
//  Copyright (c) 2014年 JYHD. All rights reserved.
//

#import "UIColor+ColorCache.h"

@implementation UIColor (ColorCache)
//create random color
+ (UIColor *)RandomColor {
    static BOOL seeded = NO;
    if (!seeded) {
        seeded = YES;
        (time(NULL));
    }
    CGFloat red = (CGFloat)random() / (CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random() / (CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random() / (CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}
+ (UIColor *)MainColor
{
    return UIColorFromRGB(0xffffff);
}
+ (UIColor *)SecondColor
{
    return UIColorFromRGB(0xff3366);//254-51-102
}
+ (UIColor *)BlackTextColor
{
    return UIColorFromRGB(0x222222);
}
+ (UIColor *)headerViewColor
{

    return UIColorFromRGB(0xe14b651);
}

+ (UIColor *)headerViewLineColor
{

    return UIColorFromRGB(0xe13ac4d);
}
+(UIColor *)dateViewBackgroundColor
{
    return UIColorFromRGB(0xe13ac4d);
}
+(UIColor *)weekDayNumberColor
{
    return UIColorFromRGB(0xeffc926);
}

+ (UIColor *)headerCellBGColor
{

    return UIColorFromRGB(0xefefef);
}
+ (UIColor *)slideWordNightColor
{
    return UIColorFromRGB(0xebfcfff);
}
+ (UIColor *)slideWordDayColor
{
    return UIColorFromRGB(0xeffffff);
}
+ (UIColor *)slideTotalWordColor
{
    return UIColorFromRGB(0xef42e2f);
}
+ (UIColor *)slideWorkWordColor
{
    return UIColorFromRGB(0xe508ff9);
}
+ (UIColor *)slideLifeWordColor
{
    return UIColorFromRGB(0xe14b651);
}
+ (UIColor *)slideShoppingWordColor
{
    return UIColorFromRGB(0xeff7d00);
}
+ (UIColor *)slideTemporaryWordColor
{
    return UIColorFromRGB(0xef63274);
}
+ (UIColor *)slideLineColor
{
    return UIColorFromRGB(0xeBFCFFF);
}

/**
 * 主界面颜色
 */

+ (UIColor *)contentCellLineViewColor
{

    return UIColorFromRGB(0xe7e7e7);
}

+ (UIColor *)contentCellHorizonLineViewColor
{

    return UIColorFromRGB(0xdddddd);
}

+ (UIColor *)contentCellDetailLabelTextColor
{
    return UIColorFromRGB(0x373737);

}

+ (UIColor *)contentCellComFromTextColor
{

    return UIColorFromRGB(0x646464);
}
+ (UIColor *)calendarWeekdayColor
{
    return UIColorFromRGB(0xeffc926);
}


+ (UIColor *)contentcellActionButton1Color
{


    return UIColorFromRGB(0x14b651);
}

+ (UIColor *)contentcellActionButton2Color
{
    
    return UIColorFromRGB(0xffc926);
}

+ (UIColor *)contentcellActionButton3Color
{
    
    return UIColorFromRGB(0xe84c3d);
}

@end
