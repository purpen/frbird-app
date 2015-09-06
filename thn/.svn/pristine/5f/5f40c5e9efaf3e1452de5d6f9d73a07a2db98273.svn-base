//
//  THNMineViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-10.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNMineViewController.h"
#import "THNUserManager.h"
#import "THNUserInfosTableViewController.h"
#import "THNMyOrderViewController.h"
#import "THNMyStoreViewController.h"
#import "THNMyTopicViewController.h"
#import "THNSetViewController.h"
#import "THNAddressManagerViewController.h"
#import <UIImageView+WebCache.h>
#import "THNUserInfo.h"
#import "THNCartViewController.h"

@interface THNMineViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@end

@implementation THNMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的账户";
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setImage:[UIImage imageNamed:@"tools"] forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(0, 0, 44, 44);
    [rightButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableview reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.tableview setDelegate:nil];
    [self.tableview setDataSource:nil];
}

#pragma mark table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.0000001;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    
//    return 0.0000001;
//}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0)
    {
        return 75;
    }
    else
    {
        return 43;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* array = @[@"",@"我的订单",@"我的话题",@"我的收藏",@"收货地址",@"购物车"];
    static NSString *CellIdentifier = @"MineCell";
       UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setSeparatorInset:UIEdgeInsetsZero];
        cell.backgroundColor = UIColorFromRGB(0xF8F8F8);
        if (indexPath.row == 0)
        {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 15, 50, 50)];
            imageView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
            imageView.tag = 1101;
            [cell.contentView addSubview:imageView];
            imageView.layer.masksToBounds=YES;
            imageView.layer.cornerRadius = 25;
            //9 18
            UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 18, 200, 20)];
            titleLabel.tag = 1102;
            titleLabel.textColor = [UIColor BlackTextColor];
            titleLabel.font = [UIFont systemFontOfSize:17];
            [cell.contentView addSubview:titleLabel];
            UILabel* detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(80 ,42, 200, 17)];
            detailLabel.tag = 1103;
            detailLabel.textColor = [UIColor BlackTextColor];
            detailLabel.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:detailLabel];
            
        }
        else
        {
            cell.textLabel.textColor = [UIColor BlackTextColor];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    if (indexPath.row == 0) {
        [((UIImageView *)[cell viewWithTag:1101]) sd_setImageWithURL:[NSURL URLWithString:[THNUserManager sharedTHNUserManager].userInfo.userAvata ]];
        
        ((UILabel *)[cell viewWithTag:1102]).text = [THNUserManager sharedTHNUserManager].userInfo.userNickName;
        ((UILabel *)[cell viewWithTag:1103]).text = [NSString stringWithFormat:@"%@  %@", [THNUserManager sharedTHNUserManager].userInfo.userCity, [THNUserManager sharedTHNUserManager].userInfo.userJob];
        if (![THNUserManager sharedTHNUserManager].userInfo.userNickName) {
            ((UILabel *)[cell viewWithTag:1102]).text = [NSString stringWithFormat:@"用户%@",[THNUserManager sharedTHNUserManager].userid];
        }
        if (![THNUserManager sharedTHNUserManager].userInfo.userCity) {
            ((UILabel *)[cell viewWithTag:1103]).text = @"";
        }
    }else{
        cell.textLabel.text = array[indexPath.row];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableview setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableview setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            //个人资料
            THNUserInfosTableViewController *user = [[THNUserInfosTableViewController alloc] init];
            user.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:user animated:YES];
        }
            break;
        case 1:
        {
            //我的订单
            THNMyOrderViewController *order = [[THNMyOrderViewController alloc] init];
            order.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:order animated:YES];
        }
            break;
        case 2:
        {
            //我的话题
            THNMyTopicViewController *topic = [[THNMyTopicViewController alloc] init];
            topic.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:topic animated:YES];
        }
            break;
        case 3:
        {
            //我的收藏
            THNMyStoreViewController *store = [[THNMyStoreViewController alloc] init];
            store.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:store animated:YES];
        }
            break;
        case 4:
        {
            THNAddressManagerViewController *addressManager = [[THNAddressManagerViewController alloc] init];
            addressManager.type = kTHNAddressPageTypeManager;
            addressManager.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:addressManager animated:YES];
        }
            break;
        case 5:
        {
            THNCartViewController *cart = [[THNCartViewController alloc] init];
            cart.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:cart animated:YES];
        }
            break;
        default:
            break;
    }
}
#pragma mark - 设置按钮点击
- (void)rightButtonClicked:(UIButton *)sender
{
    THNSetViewController *setViewController = [[THNSetViewController alloc] init];
    setViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:setViewController animated:YES];
}

@end
