//
//  UIColor+randomColor.h
//  HaojyClient
//
//  Created by Robinkey on 14-4-14.
//  Copyright (c) 2014年 JYHD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorCache)
/*
 * @fun 返回随机颜色
 * @para none
 */
+ (UIColor *)RandomColor;
/*
 * @fun 返回主色调颜色
 * @para none
 */
+ (UIColor *)MainColor;
/*
 * 返回第二点缀颜色
 */
+ (UIColor *)SecondColor;
/*
 * 黑色柔和字体
 */
+ (UIColor *)BlackTextColor;


+ (UIColor *)headerViewLineColor;
+ (UIColor *)weekDayNumberColor;
/**
 * 主界面颜色
 */
+ (UIColor *)headerViewColor;
+ (UIColor *)headerCellBGColor;
+ (UIColor *)contentCellLineViewColor;
+ (UIColor *)contentCellHorizonLineViewColor;
+ (UIColor *)contentCellDetailLabelTextColor;
+ (UIColor *)contentCellComFromTextColor;
+ (UIColor *)contentcellActionButton1Color;
+ (UIColor *)contentcellActionButton2Color;
+ (UIColor *)contentcellActionButton3Color;



/*
 *返回侧滑界面的字体颜色
 */
+ (UIColor *)slideWordNightColor;
+ (UIColor *)slideWordDayColor;
+ (UIColor *)slideTotalWordColor;
+ (UIColor *)slideWorkWordColor;
+ (UIColor *)slideLifeWordColor;
+ (UIColor *)slideShoppingWordColor;
+ (UIColor *)slideTemporaryWordColor;
+ (UIColor *)slideLineColor;
/*
 * 返回 日历颜色
 */
+ (UIColor *)dateViewBackgroundColor;
+ (UIColor *)calendarWeekdayColor;
@end
