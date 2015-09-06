//
//  THNYuShouViewController.h
//  store
//
//  Created by XiaobinJia on 14-12-15.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THNProduct;
@class THNProductBrief;

@interface THNYuShouViewController : UIViewController
@property (nonatomic, retain) UIImage *coverImage;
@property (nonatomic, assign) BOOL isPush;
@property (nonatomic, retain) IBOutlet UIButton *FavButton;
@property (nonatomic, retain) IBOutlet UIButton *likeButton;

- (id)initWithProduct:(THNProductBrief *)product coverImage:(UIImage *)ci;

- (IBAction)zan:(id)sender;
- (IBAction)store:(id)sender;
@end
