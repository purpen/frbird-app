//
//  THNErrorPage.m
//  store
//
//  Created by XiaobinJia on 15/3/22.
//  Copyright (c) 2015年 TaiHuoNiao. All rights reserved.
//

#import "THNErrorPage.h"

@implementation THNErrorPage
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
        
        UIImageView *errorIcon = [[UIImageView alloc] initWithFrame:CGRectMake(125, 100, 70, 70)];
        errorIcon.image = [UIImage imageNamed:@"error_icon"];
        [self addSubview:errorIcon];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 190, SCREEN_WIDTH, 30)];
        label.textAlignment = NSTextAlignmentCenter;
        [label setText:@"网络不太稳定哦，点击重新加载"];
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor grayColor];
        [self addSubview:label];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicked)];
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame CallbackBlock:(CallbackBlock)block
{
    self = [super initWithFrame:frame];
    if (self) {
        self.callBack = block;
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *errorIcon = [[UIImageView alloc] initWithFrame:CGRectMake(125, 100, 70, 70)];
        errorIcon.image = [UIImage imageNamed:@"error_icon"];
        [self addSubview:errorIcon];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 190, SCREEN_WIDTH, 30)];
        label.textAlignment = NSTextAlignmentCenter;
        [label setText:@"网络不太稳定哦，点击重新加载"];
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor grayColor];
        [self addSubview:label];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicked)];
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)clicked
{
    self.callBack();
}
@end
