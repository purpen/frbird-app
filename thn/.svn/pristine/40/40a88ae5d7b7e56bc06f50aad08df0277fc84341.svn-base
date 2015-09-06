//
//  THNBaseNavController.m
//  store
//
//  Created by XiaobinJia on 14-11-7.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNBaseNavController.h"
#import "THNUserManager.h"

#define JYComNavBarImageTag 1053133

@interface THNBaseNavController ()

@end

@implementation THNBaseNavController

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
    //[self.navigationBar setBackgroundColor:[UIColor MainColor]];
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor SecondColor], UITextAttributeTextColor,
                                                                     [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1], UITextAttributeTextShadowColor,
                                                                     [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                                                     [UIFont fontWithName:@"Arial-Bold" size:0.0], UITextAttributeFont,
                                                                     nil]];
    
    //去掉导航条下边阴影
    //[[UINavigationBar appearance] setShadowImage:[UIImage new]];
    
    
    // 设置导航背景颜色
    UIImage *bgImage = [UIImage imageNamed:@"main_nav_bg"];
    if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    }else{
        UIImageView *imageView = (UIImageView *)[self.navigationBar viewWithTag:JYComNavBarImageTag];
        if (imageView==nil) {
            imageView = [[UIImageView alloc] initWithImage:bgImage];
            [self.navigationBar insertSubview:imageView aboveSubview:0];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*这里重写是为了加上当导航退出一个页面就确保该页面坐标是从导航条之下开始的*/
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_OR_LATER) {
        //        viewController.edgesForExtendedLayout = UIRectEdgeNone;
        //        viewController.extendedLayoutIncludesOpaqueBars = NO;
        //        viewController.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationBar.translucent = NO;
    }
#endif
    [super pushViewController:viewController animated:animated];
    self.navigationBarHidden = NO;
}
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    //进行返回页面前处理
    return [super popViewControllerAnimated:animated];
}
- (void)backToBackground
{

}
@end
