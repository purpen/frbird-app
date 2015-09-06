//
//  THNHomeViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-7.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNHomeViewController.h"
#import "THNLoginViewController.h"
#import "THNRegistViewController.h"
#import "ShareEngine.h"
#import "THNUserManager.h"

@interface THNHomeViewController ()<ShareEngineDelegate>
{
    
}

@end

@implementation THNHomeViewController

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
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home_bg"]];
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            [v.layer setMasksToBounds:YES];
            [v.layer setCornerRadius:4.0];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
#pragma mark - Button Clicked
- (IBAction)sina:(UIButton *)sender
{
    [ShareEngine sharedInstance].delegate = self;
    [[ShareEngine sharedInstance] loginWithType:sinaWeibo];
}
- (IBAction)qq:(UIButton *)sender
{
    [ShareEngine sharedInstance].delegate = self;
    [[ShareEngine sharedInstance] loginWithType:tcWeibo];
}
- (IBAction)mail:(UIButton *)sender
{
    THNLoginViewController *loginPage = [[THNLoginViewController alloc] init];
    [self.navigationController pushViewController:loginPage animated:YES];
}
- (IBAction)regist:(UIButton *)sender
{
    THNRegistViewController *registPage = [[THNRegistViewController alloc] init];
    [self.navigationController pushViewController:registPage animated:YES];
}

#pragma mark - 第三方授权成功
- (void)shareEngineDidLogIn:(WeiboType)weibotype
{
    [[THNUserManager sharedTHNUserManager] thirdLoginWithType:weibotype];
}

@end
