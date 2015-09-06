//
//  THNAppDelegate.h
//  store
//
//  Created by XiaobinJia on 14-11-7.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THNPayViewController;

#define SharedApp ((THNAppDelegate *)[[UIApplication sharedApplication] delegate])

@interface THNAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) THNPayViewController *payViewController;
- (void)tabCUserInteractable:(BOOL)can;
- (void)resetTabC;
@end
