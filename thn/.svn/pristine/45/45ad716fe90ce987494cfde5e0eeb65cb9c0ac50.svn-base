//
//  JYBaseViewController.m
//  HaojyClient
//
//  Created by Robinkey on 14-4-29.
//  Copyright (c) 2014年 JYHD. All rights reserved.
//

#import "JYBaseViewController.h"

@interface JYBaseViewController ()

@end

@implementation JYBaseViewController
@dynamic customBackButton, customRightButton, customTitleView;
@synthesize navigationBarView = _navigationBarView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    UIView *navBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
    if (!IOS7_OR_LATER) {
        navBg.frame = CGRectMake(0, 0, 320, 44);
    }
    navBg.backgroundColor = [UIColor MainColor];
    [self.view addSubview:navBg];
    _navigationBarView = navBg;
    
    [navBg addSubview:self.customRightButton];
    [navBg addSubview:self.customTitleView];
    [navBg addSubview:self.customBackButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)baseY
{
    return IOS7_OR_LATER?64:44;
}
- (CGFloat)navBaseY
{
    return IOS7_OR_LATER?20:0;
}

- (UIView *)customTitleView
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(44, [self navBaseY], 320-88, 44)];
    label.text = self.title;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor SecondColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (UIView *)customBackButton
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, [self navBaseY], 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [backBtn setTitle:@"" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    return backBtn;
}

- (UIView *)customRightButton
{
//    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    searchButton.frame = CGRectMake(320-44, [self navBaseY], 44, 44);
//    searchButton.backgroundColor = [UIColor clearColor];
//    [searchButton addTarget:self action:@selector(searchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [searchButton setImage:[UIImage imageNamed:@"nav_search"] forState:UIControlStateNormal];
    return nil;
}
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
