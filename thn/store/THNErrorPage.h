//
//  THNErrorPage.h
//  store
//
//  Created by XiaobinJia on 15/3/22.
//  Copyright (c) 2015年 TaiHuoNiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THNErrorPage : UIView
@property (nonatomic, copy) CallbackBlock callBack;

- (id)initWithFrame:(CGRect)frame CallbackBlock:(CallbackBlock)block;
@end
