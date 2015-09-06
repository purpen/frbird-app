//
//  THNTabBarViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-16.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNTabBarViewController.h"
//首页5个Tab
#import "THNMineViewController.h"
#import "THNMainViewController.h"
#import "THNStoreViewController.h"
#import "THNPartyViewController.h"
#import "THNBaseNavController.h"
#import "THNCreativeViewController.h"
#import "UIButton+THNButtonImageAndLabel.h"

@interface THNTabBarViewController ()

@end

@implementation THNTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //[self.tabBar setHidden:YES];//将原来的UITabBarController中的UITabBar隐藏起来；
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[[UITabBar appearance] setTintColor:[UIColor redColor]];
    //去掉tabbar的上边阴影
    //[[UITabBar appearance] setShadowImage:[UIImage new]];
    //[[UITabBar appearance] setBackgroundImage:[[UIImage alloc]init]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor clearColor],
                                                       NSForegroundColorAttributeName,
                                                       nil] forState:UIControlStateNormal];
    
    [self pri_initViewController];
    [self pri_initTabbarView];
    
    int tag = 2010;
    UIButton *button = (UIButton *)[_tabbarView viewWithTag:tag];
    NSString *title = button.titleLabel.text;
    [button setImage:[UIImage imageNamed:@"tab_items_1n"] withTitle:title andTitleColor:[UIColor SecondColor] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//初始化子控制器
- (void)pri_initViewController {
    
    //配置Tab
    THNMainViewController *c1 = [[THNMainViewController alloc] init];
    THNBaseNavController *nav1 = [[THNBaseNavController alloc] initWithRootViewController:c1];
    
    THNStoreViewController *c2 = [[THNStoreViewController alloc] init];
    THNBaseNavController *nav2 = [[THNBaseNavController alloc] initWithRootViewController:c2];
    
    THNPartyViewController *c3 = [[THNPartyViewController alloc] init];
    THNBaseNavController *nav3 = [[THNBaseNavController alloc] initWithRootViewController:c3];
    
    THNMineViewController *c4 = [[THNMineViewController alloc] init];
    THNBaseNavController *nav4 = [[THNBaseNavController alloc] initWithRootViewController:c4];

    [self setViewControllers:@[nav1, nav2, nav3, nav4] animated:NO];
}

//等比例缩放
-(UIImage*)scaleToSize:(CGSize)size image:(UIImage *)image
{
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    
    float verticalRadio = size.height*1.0/height;
    float horizontalRadio = size.width*1.0/width;
    
    float radio = 1;
    if(verticalRadio>1 && horizontalRadio>1)
    {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    }
    else
    {
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    
    width = width*radio;
    height = height*radio;
    
    int xPos = (size.width - width)/2;
    int yPos = (size.height-height)/2;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(xPos, yPos, width, height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}
//创建自定义tabBar
- (void)pri_initTabbarView {
    _tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 49)];//49为tabBar的高度
    _tabbarView.backgroundColor = [UIColor whiteColor];//设置tabBar的背景颜色
    [self.tabBar addSubview:_tabbarView];
    /*
    NSArray *titles = @[@"首页",@"商店",@"",@"社区",@"账户"];
    NSArray *backgroud = @[@"tab_items_1h",@"tab_items_2h",@"tab_items_centerh",@"tab_items_3h",@"tab_items_4h"];//tabBarItem中的按钮
    NSArray *highlightBackground = @[@"tab_items_1n",@"tab_items_2n",@"tab_items_centern",@"tab_items_3n",@"tab_items_4n"];//tabBarItem中高亮时候的按钮
    */
    NSArray *titles = @[@"首页",@"商店",@"社区",@"账户"];
    NSArray *backgroud = @[@"tab_items_1h",@"tab_items_2h",@"tab_items_3h",@"tab_items_4h"];//tabBarItem中的按钮
    NSArray *highlightBackground = @[@"tab_items_1n",@"tab_items_2n",@"tab_items_3n",@"tab_items_4n"];//tabBarItem中高亮时候的按钮
    //将按钮添加到自定义的_tabbarView中，并为按钮设置tag（tag从0开始）
    for (int i=0; i<backgroud.count; i++) {
        NSString *backImage = backgroud[i];
        NSString *heightImage = highlightBackground[i];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.backgroundColor = [UIColor blackColor];
        button.frame = CGRectMake(20+((SCREEN_WIDTH-240)/3*i)+50*i, (49-49)/2, 50, 49);
        [button setImage:[UIImage imageNamed:backImage]
               withTitle:titles[i]
           andTitleColor:[UIColor BlackTextColor]
                forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:heightImage]
               withTitle:titles[i]
           andTitleColor:[UIColor SecondColor]
                forState:UIControlStateHighlighted];
        
//        [button setImageEdgeInsets:UIEdgeInsetsMake(10, 15, 0, 15)];
        button.tag = 2010+i;
        [button addTarget:self action:@selector(selectedTab:) forControlEvents:UIControlEventTouchUpInside];
        [_tabbarView addSubview:button];
    }
}

//点击按钮后显示哪个控制器界面
- (void)selectedTab:(UIButton *)button {
    NSArray *backgroud = @[@"tab_items_1h",@"tab_items_2h",@"tab_items_3h",@"tab_items_4h"];
    NSArray *highlightBackground = @[@"tab_items_1n",@"tab_items_2n",@"tab_items_3n",@"tab_items_4n"];
    for (int j=0; j<4; j++) {
        int tag = 2010+j;
        UIButton *b = (UIButton *)[_tabbarView viewWithTag:tag];
        NSString *title = b.titleLabel.text;
        [b setImage:[UIImage imageNamed:backgroud[j]] withTitle:title andTitleColor:[UIColor BlackTextColor] forState:UIControlStateNormal];
    }
    self.selectedIndex = button.tag-2010;
    NSString *title = button.titleLabel.text;
    [button setImage:[UIImage imageNamed:highlightBackground[button.tag-2010]] withTitle:title andTitleColor:[UIColor SecondColor] forState:UIControlStateNormal];
    
    [self.tabBar bringSubviewToFront:_tabbarView];
}

@end
