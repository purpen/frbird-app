//
//  THNPayViewController.m
//  store
//
//  Created by XiaobinJia on 14-12-21.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNPayViewController.h"
#import "Order.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"
#import <UIViewController+MBProgressHUD.h>
#import "THNAppDelegate.h"
#import "THNUserManager.h"
#import "NSMutableDictionary+AddSign.h"
#import "JYComHttpRequest.h"

typedef enum : NSUInteger {
    kTHNPayWayAlipay,
    kTHNPayWayWX,
} THNPayway;

@interface THNPayViewController ()<UITableViewDataSource, UITableViewDelegate, JYComHttpRequestDelegate>
@property (nonatomic, retain) IBOutlet UITableView *tableview;
@end

@implementation THNPayViewController
{
    BOOL                    _nibsRegistered;
    IBOutlet UIButton       *_payButton;
    
    UIButton                *_alipayButton;
    UIButton                *_wxButton;
    
    THNPayway               _payway;
    
    IBOutlet UILabel        *_orderNumLabel;
    IBOutlet UILabel        *_moneyLabel;
    IBOutlet UILabel        *_paywayLabel;
    
    JYComHttpRequest        *_request;
}
@synthesize totalMoney = _totalMoney, orderID = _orderID;

- (void)dealloc
{
    [self.tableview setDelegate:nil];
    [self.tableview setDataSource:nil];
    [_request clearDelegatesAndCancel];
    _request = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"支付订单";
    _nibsRegistered = NO;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, -5, 10, 25)];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    _payway = kTHNPayWayAlipay;
    
    _payButton.layer.borderWidth = .5;
    _payButton.layer.borderColor = [[UIColor colorWithRed:255/255.0 green:74/255.0 blue:133/255.0 alpha:1.0] CGColor];
    [_payButton.layer setMasksToBounds:YES];
    [_payButton.layer setCornerRadius:4.0];
    
    _paywayLabel.text = @"在线支付";
    _orderNumLabel.text = self.orderID;
    _moneyLabel.text = [NSString stringWithFormat:@"%.2f",self.totalMoney];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Back
- (void)doBack:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - button style
- (void)buttonChangeColor:(UIButton *)button state:(BOOL)state
{
    if (state) {
        //YES为红
        [button setTitleColor:UIColorFromRGB(0xff2952) forState:UIControlStateNormal];
        button.layer.borderWidth = .5;
        button.layer.borderColor = [[UIColor colorWithRed:255/255.0 green:41/255.0 blue:82/255.0 alpha:1.0] CGColor];
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:4.0];
    }else{
        //NO为黑
        [button setTitleColor:UIColorFromRGB(0x393939) forState:UIControlStateNormal];
        button.layer.borderWidth = .5;
        button.layer.borderColor = [[UIColor colorWithRed:57/255.0 green:57/255.0 blue:57/255.0 alpha:1.0] CGColor];
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:4.0];
    }
    
}
#pragma mark - tableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.text = indexPath.row==0?@"支付宝客户端支付":@"微信支付";
    cell.textLabel.textColor = [UIColor BlackTextColor];
    UIImageView *selected = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-25-10, 10, 25, 25)];
    selected.image = [UIImage imageNamed:@"selected"];
    selected.tag = 28010;
    [cell.contentView addSubview:selected];
    selected.hidden = YES;
    if (_payway == kTHNPayWayAlipay && indexPath.row==0) {
        selected.hidden = NO;
        cell.textLabel.textColor = [UIColor SecondColor];
    }
    if (_payway == kTHNPayWayWX && indexPath.row==1) {
        selected.hidden = NO;
        cell.textLabel.textColor = [UIColor SecondColor];
    }
    cell.imageView.image = [UIImage imageNamed:indexPath.row==0?@"pay_alipay":@"pay_wx"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor SecondColor];
    ((UIView *)[cell.contentView viewWithTag:28010]).hidden = NO;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:(1-indexPath.row) inSection:0];
    UITableViewCell *cellTmp = [tableView cellForRowAtIndexPath:ip];
    ((UIView *)[cellTmp.contentView viewWithTag:28010]).hidden = YES;
    cellTmp.textLabel.textColor = [UIColor BlackTextColor];
    if (indexPath.row==0) {
        _payway = kTHNPayWayAlipay;
    }else{
        _payway = kTHNPayWayWX;
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
#pragma mark - alipay
- (IBAction)thn_pay
{
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[THNUserManager sharedTHNUserManager] userid], @"current_user_id",
                                     self.orderID,                                  @"rid",
                                     @"alipay",                                     @"payaway",
                                     [THNUserManager channel],                      @"channel",
                                     [THNUserManager client_id],                    @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],  @"uuid",
                                     [THNUserManager time],                                     @"time",
                                     nil];
    [listPara addSign];
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiProductPay]];
    [self showHUD];
}
#pragma mark - ASI Delegate
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    [self hideHUD];
    JYLog(@"接口数据返回成功：%@",result);
    if ([jyRequest.requestUrl hasSuffix:kTHNApiProductPay]) {
            NSString *appScheme = @"alipay.thnstore";
            [self showHUDWithMessage:@"正在支付..."];
            SharedApp.payViewController = self;
            [[AlipaySDK defaultService] payOrder:result fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                [self hideHUD];
                SharedApp.payViewController = nil;
                NSInteger code = [resultDic[@"resultStatus"] integerValue];
                if (code == 9000 ) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }else
                {
                    UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"支付失败请重试！" delegate:nil
                                                               cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [alertView show];
                }
            }];
        
    }
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    [self hideHUDWithCompletionMessage:[[error userInfo] objectForKey:NSLocalizedDescriptionKey]];
    JYLog(@"接口数据返回成功：%@",error);
}


@end
