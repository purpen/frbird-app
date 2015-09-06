//
//  THNAddressManagerViewController.h
//  store
//
//  Created by XiaobinJia on 14-11-20.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kTHNAddressPageTypeManager,
    kTHNAddressPageTypeSelect
} THNAddressPageType;

@class THNOrderViewController;

@interface THNAddressManagerViewController : UIViewController
@property (nonatomic, assign) THNAddressPageType type;
@property (nonatomic, assign) THNOrderViewController *delegate;
@end
