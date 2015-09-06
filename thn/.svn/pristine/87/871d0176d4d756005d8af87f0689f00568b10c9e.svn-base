//
//  THNUMNavController.m
//  store
//
//  Created by XiaobinJia on 14-11-7.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNUMNavController.h"
#import "THNUserManager.h"

@interface THNUMNavController ()

@end

@implementation THNUMNavController
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    //进行处理
    if ([self.viewControllers count]<=2) {
        [[THNUserManager sharedTHNUserManager] backToGame];
        return nil;
    }
    else{
        return [super popViewControllerAnimated:animated];
    }
}

- (UIViewController *)popLast
{
    //将上面的函数本来功能移动到这里
    return [super popViewControllerAnimated:NO];
}

@end
