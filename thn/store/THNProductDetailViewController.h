//
//  THNProductDetailViewController.h
//  store
//
//  Created by XiaobinJia on 14-12-3.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THNProduct.h"

@interface THNProductDetailViewController : UIViewController
@property (nonatomic, retain) UIImage *coverImage;
@property (nonatomic, retain) THNProduct         *product;
@end
