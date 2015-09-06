//
//  JYSexPicker.m
//  HaojyClient
//
//  Created by Robinkey on 14-5-9.
//  Copyright (c) 2014年 JYHD. All rights reserved.
//

#import "JYSexPicker.h"

@interface JYSexPicker ()
@property (nonatomic, strong) UIColor *maColor;
@property (nonatomic, strong) UIColor *woColor;
@property (nonatomic, strong) UIColor *bgColor;

@end

@implementation JYSexPicker
{
    JYSexType   _sex;
    UIView      *_mansel;
    UIView      *_womansel;
    
    UIButton    *_man1;
    UIButton    *_woman1;
}
@synthesize maColor = _maColor, woColor = _woColor, bgColor = _bgColor;
@dynamic sex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 100, 20)];
    if (self) {
        self.maColor = UIColorFromRGB(0x00c5dd);
        self.woColor = UIColorFromRGB(0xf33465);
        self.bgColor = UIColorFromRGB(0xf0f0f0);
        self.backgroundColor = self.bgColor;
        self.userInteractionEnabled = YES;
        [self configurePicker];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame ManColor:(UIColor *)mc WomanColor:(UIColor *)woc andBGColor:(UIColor *)bgc
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 100, 20)];
    if (self) {
        self.maColor = mc;
        self.woColor = woc;
        self.bgColor = bgc;
        
        [self configurePicker];
    }
    return self;
}
- (void)configurePicker
{
    _man1 = [UIButton buttonWithType:UIButtonTypeCustom];
    _man1.frame = CGRectMake(0, 0, 20, 20);
    [_man1 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _man1.backgroundColor = self.maColor;
    [[_man1 layer] setMasksToBounds:YES];
    [[_man1 layer]setCornerRadius:_man1.frame.size.width/2.0];
    [self addSubview:_man1];
    
    UIView *man2 = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 16, 16)];
    man2.backgroundColor = self.bgColor;
    man2.userInteractionEnabled = NO;
    [[man2 layer] setMasksToBounds:YES];
    [[man2 layer]setCornerRadius:man2.frame.size.width/2.0];
    [_man1 addSubview:man2];
    
    _mansel = [[UIView alloc] initWithFrame:CGRectMake(4, 4, 12, 12)];
    _mansel.backgroundColor = self.maColor;
    [[_mansel layer] setMasksToBounds:YES];
    [[_mansel layer]setCornerRadius:_mansel.frame.size.width/2.0];
    [_man1 addSubview:_mansel];
    
    UILabel *manLabel = [[UILabel alloc] initWithFrame:CGRectMake(22+3, 0, 30, 20)];
    manLabel.text = @"男";
    manLabel.textColor = UIColorFromRGB(0x848484);
    manLabel.backgroundColor = [UIColor clearColor];
    manLabel.font = [UIFont boldSystemFontOfSize:16];
    [self addSubview:manLabel];
    
    _woman1 = [UIButton buttonWithType:UIButtonTypeCustom];
    _woman1.frame = CGRectMake(50, 0, 20, 20);
    _woman1.backgroundColor = self.woColor;
    [_woman1 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [[_woman1 layer] setMasksToBounds:YES];
    [[_woman1 layer]setCornerRadius:_woman1.frame.size.width/2.0];
    [self addSubview:_woman1];
    
    UIView *woman2 = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 16, 16)];
    woman2.backgroundColor = self.bgColor;
    woman2.userInteractionEnabled = NO;
    [[woman2 layer] setMasksToBounds:YES];
    [[woman2 layer]setCornerRadius:woman2.frame.size.width/2.0];
    [_woman1 addSubview:woman2];
    
    _womansel = [[UIView alloc] initWithFrame:CGRectMake(4, 4, 12, 12)];
    _womansel.backgroundColor = self.woColor;
    [[_womansel layer] setMasksToBounds:YES];
    [[_womansel layer]setCornerRadius:_womansel.frame.size.width/2.0];
    [_woman1 addSubview:_womansel];
    
    UILabel *womanLabel = [[UILabel alloc] initWithFrame:CGRectMake(72+3, 0, 30, 20)];
    womanLabel.text = @"女";
    womanLabel.textColor = UIColorFromRGB(0x848484);
    womanLabel.backgroundColor = [UIColor clearColor];
    womanLabel.font = [UIFont boldSystemFontOfSize:16];
    [self addSubview:womanLabel];
}

- (JYSexType)sex
{
    return _sex;
}
- (void)setSex:(JYSexType)sex
{
    _sex = sex;
    if (_sex==kJYSexMan) {
        _mansel.hidden = NO;
        _womansel.hidden = YES;
    }else if(_sex==kJYSexWoman){
        _womansel.hidden = NO;
        _mansel.hidden = YES;
    }else{
        _womansel.hidden = YES;
        _mansel.hidden = YES;
    }
}
- (void)buttonClicked:(UIButton *)sender
{
    if (sender == _man1) {
        self.sex = kJYSexMan;
        self.selectedBlock([NSNumber numberWithInt:kJYSexMan]);
    }else if(sender == _woman1){
        self.sex = kJYSexWoman;
        self.selectedBlock([NSNumber numberWithInt:kJYSexWoman]);
    }
}
@end
