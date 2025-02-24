//
//  THNSetViewController.m
//  store
//
//  Created by XiaobinJia on 14-12-8.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNSetViewController.h"
#import "KLSwitch.h"
#import "JYFankuiViewController.h"
#import "XYAlertView.h"
#import <ASIHTTPRequest/ASIDownloadCache.h>
#import <SDWebImage/SDImageCache.h>
#import "JYShareViewController.h"
#import "THNAboutViewController.h"
#import "THNUserManager.h"

@interface THNSetViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableviewx;
@end

@implementation THNSetViewController
{
    BOOL                        _wantPush;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"设置";
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, -5, 10, 25)];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    view.backgroundColor = UIColorFromRGB(0xf7f7f7);
    self.tableviewx.tableHeaderView = view;
}
- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonClicked:(id)sender
{
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    self.tableviewx.delegate = nil;
    self.tableviewx.dataSource = nil;
}
#pragma mark table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int a[3] = {1, 5, 1};
    return a[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.0000001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==0) {
        return 50.01;
    }
    return 20.0000001f;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section==0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        view.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-30, 30)];
        label.text = @"请在iPhone的\"设置\"-\"通知\"功能中，找到应用程序\"太火鸟\"进行更改";
        label.font = [UIFont systemFontOfSize:12];
        label.numberOfLines = 3;
        label.textColor = [UIColor colorWithRed:130/255.0 green:130/255.0 blue:130/255.0 alpha:1.0];
        label.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
        [view addSubview:label];
        return view;
    }else{
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        view.backgroundColor = UIColorFromRGB(0xf7f7f7);
        return view;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = UIColorFromRGB(0xffffff);
    }
    NSArray *iconArray = [NSArray arrayWithObjects:@"uc_tuisong", @"uc_qingkong", @"uc_pinglun", @"uc_yijian", @"uc_guanyu", @"uc_share", nil];
    NSArray *titleArray = [NSArray arrayWithObjects: @"推送设置", @"清空缓存", @"去评价", @"意见反馈", @"关于太火鸟", @"分享给好友", @"退出当前账号", nil];
    cell.imageView.image = [UIImage imageNamed:[iconArray objectAtIndex:indexPath.row]];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = [titleArray objectAtIndex:indexPath.row+indexPath.section];
    cell.textLabel.textColor = [UIColor BlackTextColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    if (indexPath.section!=0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        /*
        KLSwitch *switcher = [[KLSwitch alloc] initWithFrame:CGRectMake(320-50-5, 9, 50, 25)];
        [switcher setTintColor:[UIColor SecondColor]];
        [switcher setOnTintColor:[UIColor SecondColor]];
        [switcher setOn:_wantPush animated:NO];
        __block typeof(self) blockSelf = self;
        [switcher setDidChangeHandler:^(BOOL isOn) {
            JYLog(@"Smallest switch changed to %d", isOn);
            blockSelf->_wantPush = isOn;
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:blockSelf->_wantPush] forKey:PushWantKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (isOn) {
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
                 UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert| UIRemoteNotificationTypeSound];
            }
            else{
                [[UIApplication sharedApplication] unregisterForRemoteNotifications];
            }
        }];
        
        [cell addSubview:switcher];
         */
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(320-50-15, 9, 50, 25)];
        label.text = (type==UIRemoteNotificationTypeNone)?@"已关闭":@"已开启";
        label.textColor = [UIColor colorWithRed:130/255.0 green:130/255.0 blue:130/255.0 alpha:1.0];
        label.font = [UIFont systemFontOfSize:15];
        label.backgroundColor = [UIColor whiteColor];
        [cell addSubview:label];
    }
    if(indexPath.row+indexPath.section == 1){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(300-30, 12, 38, 18)];
        label.text = @"清理";
        label.textColor = [UIColor colorWithRed:163/255.0 green:163/255.0 blue:163/255.0 alpha:1.0];
        label.font = [UIFont systemFontOfSize:12];
        label.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:label];
    }
    if (indexPath.section == 2) {
        cell.textLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"退出当前账号" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor SecondColor] forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [button addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
        [cell.contentView addSubview:button];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row+indexPath.section) {
        case 0://推送开关
            return ;
            break;
        case 1://清空缓存
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"确定要清空缓存数据吗？"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:@"取消", nil];
            [alert show];
        }
            break;
        case 2:
        {
            NSString *urlStr = nil;
            if (!IOS7_OR_LATER) {
                urlStr = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=946737402";
            }
            else{
                urlStr = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=879391023&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        }
            break;
        case 3://反馈
        {
            JYFankuiViewController *fankui = [[JYFankuiViewController alloc] init];
            [self presentViewController:fankui animated:YES completion:^{
            
            }];
        }
            break;
        case 4://关于
        {
            THNAboutViewController *about = [[THNAboutViewController alloc] init];
            about.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:about animated:YES];
        }
            break;
        case 5:
        {
            JYShareViewController *shareViewController = [[JYShareViewController alloc] init];
            shareViewController.shareContent = [NSString stringWithFormat:@"太火鸟商城"];
            shareViewController.shareUrl = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=946737402"];
            shareViewController.shareImage = [UIImage imageNamed:@"logo-home"];
            shareViewController.shareType = shareTypeOther;
            [self presentViewController:shareViewController animated:YES completion:^{
                
            }];
        }
        default:
            break;
    }
}

- (void)logout
{
    THNUserManager *um = [THNUserManager sharedTHNUserManager];
    if (um.loginState) {
        [um logout];
        [um login];
    }else{
        [um login];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        //清空缓存
    }
}
@end
