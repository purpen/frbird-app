//
//  JYBaseViewController.h
//  HaojyClient
//
//  Created by Robinkey on 14-4-29.
//  Copyright (c) 2014年 JYHD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JYBaseViewController : UIViewController
@property (nonatomic, retain) UIView *customBackButton;
@property (nonatomic, retain) UIView *customTitleView;
@property (nonatomic, retain) UIView *customRightButton;

@property (nonatomic, readonly) UIView *navigationBarView;

- (CGFloat)baseY;
- (CGFloat)navBaseY;
- (void)back;
@end
