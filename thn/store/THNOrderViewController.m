//
//  THNOrderViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-22.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNOrderViewController.h"
#import "THNAddressManagerViewController.h"
#import "Order.h"
#import "DataSigner.h"
#import "THNAdress.h"
#import <AlipaySDK/AlipaySDK.h>
#import "THNCartItem.h"
#import <UIImageView+WebCache.h>
#import "THNPayViewController.h"
#import "JYComHttpRequest.h"
#import "THNUserManager.h"
#import "THNCartDB.h"
#import "NSMutableDictionary+AddSign.h"

@interface THNOrderViewController ()<UITableViewDataSource, UITableViewDelegate, JYComHttpRequestDelegate>


@end

@implementation THNOrderViewController
{
    BOOL                    _nibsRegistered;
    IBOutlet UIButton       *_payButton;
    IBOutlet UILabel        *_totalMoney;
    
    NSArray                 *_productArray;
    THNAdress               *_currentAddress;
    
    JYComHttpRequest    *_request;
    
    BOOL                _afterRequest;
}
@synthesize productArray = _productArray, tmpOrderID = _tmpOrderID;
@synthesize currentAddress = _currentAddress;

- (void)dealloc
{
    [self.tableView setDelegate:nil];
    [self.tableView setDataSource:nil];
    [_request clearDelegatesAndCancel];
    _request = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"确认订单";
    _nibsRegistered = NO;
    _afterRequest = NO;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, -5, 10, 25)];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    _payButton.layer.borderWidth = .5;
    _payButton.layer.borderColor = [[UIColor colorWithRed:255/255.0 green:74/255.0 blue:133/255.0 alpha:1.0] CGColor];
    [_payButton.layer setMasksToBounds:YES];
    [_payButton.layer setCornerRadius:4.0];
    
    float total = 0.0f;
    for (THNCartItem *item in _productArray) {
        total += [item.itemProductPrice floatValue] * [item.itemProductCount floatValue];
    }
    _totalMoney.text = [NSString stringWithFormat:@"￥%.2f",total];
    
    [self requestForAddressList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData
{
    [self.tableView reloadData];
}
#pragma mark - Back
- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sureOrderButtonClicked:(UIButton *)sender
{
    if (!_currentAddress || !_currentAddress.addressID || [_currentAddress.addressID isEqualToString:@""]) {
//        [JDStatusBarNotification showWithStatus:@"请配置您的收件地址！"
//                                   dismissAfter:4.0
//                                      styleName:JDStatusBarStyleMatrix];
        [self alertWithInfo:@"请配置您的收件地址！"];
        return;
    }
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [THNUserManager sharedTHNUserManager].userid,  @"current_user_id",
                                     self.tmpOrderID,                               @"rrid",
                                     _currentAddress.addressID,                     @"addbook_id",
                                     [NSString stringWithFormat:@"%d",self.isNowBuy],                                           @"is_nowbuy",
                                     [NSString stringWithFormat:@"%d",self.isPresale],                                           @"is_presaled",
                                     @"a",                                          @"payment_method",
                                     @"1",                                          @"transfer_time",
                                     [THNUserManager channel],                      @"channel",
                                     [THNUserManager client_id],                    @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],  @"uuid",
                                     [THNUserManager time],                         @"time",
                                     nil];
    [listPara addSign];
    //开始请求商品详情
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiProductConfirm]];
    [self showLoadingWithAni:YES];
}
#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int height[3] = {115, 165, 100};
    if (indexPath.row<2) {
        return height[indexPath.row];
    }
    return 100;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.000001f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        THNAddressManagerViewController *addManager = [[THNAddressManagerViewController alloc] init];
        addManager.type = kTHNAddressPageTypeSelect;
        addManager.delegate = self;
        [self.navigationController pushViewController:addManager animated:YES];
    }
}
#pragma mark - tableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _afterRequest?2+[self.productArray count]:0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier0 = @"AddressCell";
    static NSString *CellIdentifier1 = @"BuyWayCell";
    static NSString *CellIdentifier2 = @"THNCartCell";
    
    if (!_nibsRegistered) {
        UINib *addressNib = [UINib nibWithNibName:@"AddressCell" bundle:nil];
        [tableView registerNib:addressNib forCellReuseIdentifier:CellIdentifier0];
        UINib *buyWayNib = [UINib nibWithNibName:@"BuyWayCell" bundle:nil];
        [tableView registerNib:buyWayNib forCellReuseIdentifier:CellIdentifier1];
        UINib *cartNib = [UINib nibWithNibName:@"THNCartCell" bundle:nil];
        [tableView registerNib:cartNib forCellReuseIdentifier:CellIdentifier2];
        _nibsRegistered = YES;
    }
    UITableViewCell *cell;
    if (indexPath.row==0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier0];
        cell.backgroundColor = UIColorFromRGB(0xf1f1f1);
        ((UIButton *)[cell viewWithTag:1004]).hidden = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (_currentAddress) {
            //配置地址数据
            ((UILabel *)[cell viewWithTag:1001]).text = [NSString stringWithFormat:@"收货人：%@",_currentAddress.addressUserName];
            ((UILabel *)[cell viewWithTag:1002]).text = _currentAddress.addressDetail;
            ((UILabel *)[cell viewWithTag:1003]).text = _currentAddress.addressPhone;
            ((UILabel *)[cell viewWithTag:1005]).text = [NSString stringWithFormat:@"%@ %@",_currentAddress.addressProvinceName, _currentAddress.addressCityName];
        }else{
            //配置待定地址数据
            ((UILabel *)[cell viewWithTag:1001]).text = [NSString stringWithFormat:@"收货人：请先添加收货地址"];
            ((UILabel *)[cell viewWithTag:1002]).text = @"";
            ((UILabel *)[cell viewWithTag:1003]).text = @"";
            ((UILabel *)[cell viewWithTag:1005]).text = @"";
        }
        
    }else if(indexPath.row==1){
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        cell.backgroundColor = UIColorFromRGB(0xf6f6f6);
        
        UIButton *button = ((UIButton *)[cell viewWithTag:1002]);
        
        [self buttonChangeColor:((UIButton *)[cell viewWithTag:1001]) state:YES];
        [self buttonChangeColor:button state:YES];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (!(indexPath.row%2)) {
            cell.backgroundColor = UIColorFromRGB(0xf1f1f1);
        }else{
            cell.backgroundColor = UIColorFromRGB(0xf6f6f6);
        }
        THNCartItem *item = [self.productArray objectAtIndex:indexPath.row-2];
        //图片
        [((UIImageView *)[cell viewWithTag:32101]) sd_setImageWithURL:[NSURL URLWithString:item.itemProduct.brief.productImage]];
        //标题
        ((UILabel *)[cell viewWithTag:32102]).text = item.itemProduct.brief.productTitle;
        //类型
        ((UILabel *)[cell viewWithTag:32103]).text = [NSString stringWithFormat:@"类型：%@",item.itemProductSKUTitle];
        //数量
        ((UILabel *)[cell viewWithTag:32104]).text = [NSString stringWithFormat:@"数量：%@",item.itemProductCount];
        //价格
        ((UILabel *)[cell viewWithTag:32105]).text = [NSString stringWithFormat:@"￥%@",item.itemProductPrice];
    }
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

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
#pragma mark - 请求
- (void)requestForAddressList
{
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[THNUserManager sharedTHNUserManager] userid],    @"current_user_id",
                                     [THNUserManager channel],                          @"channel",
                                     [THNUserManager client_id],                        @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],      @"uuid",
                                     [THNUserManager time],                             @"time",
                                     nil];
    [listPara addSign];
    //开始请求商品详情
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiAccountUserAddress]];
    [self showLoadingWithAni:YES];
}
#pragma mark - ASI Delegate
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    if ([jyRequest.requestUrl hasSuffix:kTHNApiAccountUserAddress]) {
        // 解析数据
        _afterRequest = YES;
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSArray *rows = [result objectForKey:@"rows"];
            for (NSDictionary *dict in rows) {
                THNAdress *address = [[THNAdress alloc] init];
                address.addressID =         [dict stringValueForKey:@"_id"];
                address.addressUserName =   [dict stringValueForKey:@"name"];
                address.addressPhone =      [dict stringValueForKey:@"phone"];
                address.addressEmail =      [dict stringValueForKey:@"email"];
                address.addressCreateOn =   [dict stringValueForKey:@"created_on"];
                address.addressUpdateOn =   [dict stringValueForKey:@"updated_on"];
                address.addressIsDefault =  [dict boolValueForKey:@"is_default"];
                address.addressDetail =     [dict stringValueForKey:@"address"];
                address.addressProvinceName = [dict stringValueForKey:@"province_name"];
                address.addressCityName =   [dict stringValueForKey:@"city_name"];
                address.addressProvinceID = [[dict stringValueForKey:@"province"] intValue];
                address.addressCityID =     [[dict stringValueForKey:@"city"] intValue];
                address.addressZip =        [dict stringValueForKey:@"zip"];
                
                if (address.addressIsDefault) {
                    _currentAddress = address;
                }
            }
        }
        //刷新界面
        [self.tableView reloadData];
        [self hideLoading];
    }else if([jyRequest.requestUrl hasSuffix:kTHNApiProductConfirm]){
        NSString *rid = nil;
        BOOL snatched = NO;
        float payMoney = 0;
        if ([result isKindOfClass:[NSDictionary class]]) {
            rid = [result stringValueForKey:@"rid"];
            snatched = [result boolValueForKey:@"is_snatched"];
            payMoney = [result floatValueForKey:@"pay_money"];
        }
        float localMoney = [[[_totalMoney text] substringFromIndex:1] floatValue];
        if (payMoney != localMoney) {
//            [JDStatusBarNotification showWithStatus:@"下单金额不一致" styleName:JDStatusBarStyleMatrix];
            [self alertWithInfo:@"下单金额不一致"];
            [self hideLoading];
            return;
        }
        if (snatched) {
            //显示我的订单页面
            
        }else{
            //显示支付页面
            THNPayViewController *payView = [[THNPayViewController alloc] init];
            payView.orderID = rid;
            payView.totalMoney = payMoney;
            [self.navigationController pushViewController:payView animated:YES];
            if (!self.isNowBuy) {
                [[THNCartDB sharedTHNCartDB] deleteAll];
            }
        }
        [self hideLoading];
        
    }
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    NSString *errorInfo = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    [self hideLoadingWithCompletionMessage:errorInfo];
}

@end
