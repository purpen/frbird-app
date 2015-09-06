//
//  THNProductViewController.h
//  store
//
//  Created by XiaobinJia on 14-11-14.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THNProduct;
@class THNProductBrief;

@interface THNProductViewController : UIViewController
@property (nonatomic, retain) UIImage *coverImage;
@property (nonatomic, retain) IBOutlet UIButton *FavButton;
@property (nonatomic, retain) IBOutlet UIButton *likeButton;
@property (nonatomic, retain) IBOutlet UIButton *buyButton;
@property (nonatomic, retain) IBOutlet UIButton *cartButton;
@property (nonatomic, assign) BOOL isPush;
- (id)initWithProduct:(THNProductBrief *)product coverImage:(UIImage *)ci;

- (IBAction)zan:(id)sender;
- (IBAction)store:(id)sender;
- (IBAction)putInCart:(id)sender;
@end
