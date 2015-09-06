//
//  THNAddressManagerViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-20.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNAddressManagerViewController.h"
#import "THNAddressAddViewController.h"
#import "THNUserManager.h"
#import "JYComHttpRequest.h"
#import <UIViewController+AMThumblrHud.h>
#import "THNAdress.h"
#import "NSDictionary+ModelParse.h"
#import "THNOrderViewController.h"
#import "NSMutableDictionary+AddSign.h"
#import "THNErrorPage.h"

@interface THNAddressManagerViewController ()<JYComHttpRequestDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@end

@implementation THNAddressManagerViewController
{
    BOOL                _nibsRegistered;
    BOOL                _tableVeiwEditState;
    UIButton            *_rightButton;
    
    JYComHttpRequest    *_request;
    NSMutableArray      *_addressArray;
    
    BOOL                _afterRequest;
    int                 _selectedAddressOrder;
}

- (void)dealloc
{
    self.tableview.delegate = nil;
    self.tableview.dataSource = nil;
    [_request clearDelegatesAndCancel];
    _request = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"收货地址";
    _afterRequest = NO;
    _addressArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, -5, 10, 25)];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    
    if (self.type == kTHNAddressPageTypeManager) {
        [_rightButton setTitle:@"编辑" forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(editButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        _rightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_rightButton setTitle:@"确定" forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(sureButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.frame = CGRectMake(0, 0, 44, 44);
        
        [_rightButton setTitleColor:[UIColor SecondColor] forState:UIControlStateNormal];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    
    
    _nibsRegistered = NO;
    
    _tableVeiwEditState = NO;
    
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestForAddressList];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 请求
- (void)requestForAddressList
{
    [_addressArray removeAllObjects];
    _addressArray = [[NSMutableArray alloc] initWithCapacity:0];
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

#pragma mark - ButtonClicked
- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)sureButtonClicked:(UIButton *)sender
{
    //调用代理，回传用户选择值
    THNAdress *address = [_addressArray objectAtIndex:_selectedAddressOrder];
    self.delegate.currentAddress = address;
    [self.delegate.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)editButtonClicked:(UIButton *)sender
{
    [self.tableview setEditing:!_tableVeiwEditState animated:YES];
    _tableVeiwEditState = !_tableVeiwEditState;
    if (_tableVeiwEditState) {
        [_rightButton setTitle:@"完成" forState:UIControlStateNormal];
        
        for (UITableViewCell *cell in self.tableview.visibleCells) {
            ((UIView *)[cell viewWithTag:1004]).hidden = YES;
        }
    }else{
        [_rightButton setTitle:@"编辑" forState:UIControlStateNormal];
        int i = 0;
        for (UITableViewCell *cell in self.tableview.visibleCells) {
            THNAdress *address = [_addressArray objectAtIndex:i];
            ((UIView *)[cell viewWithTag:1004]).hidden = !address.addressIsDefault;
            i++;
        }
    }
    
}
- (void)addNewAddress
{
    THNAddressAddViewController *addressAdd = [[THNAddressAddViewController alloc] init];
    addressAdd.isEdit = NO;
    [self.navigationController pushViewController:addressAdd animated:YES];
}
#pragma mark table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!(indexPath.row<[_addressArray count])) {
        return;
    }
    if (_type==kTHNAddressPageTypeManager) {
        THNAddressAddViewController *addressAdd = [[THNAddressAddViewController alloc] init];
        THNAdress *address = [_addressArray objectAtIndex:indexPath.row];
        addressAdd.address = address;
        addressAdd.isEdit = YES;
        addressAdd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:addressAdd animated:YES];
    }else{
        for (int i=0; i<[_addressArray count]; i++) {
            UITableViewCell *cellTmp = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            ((UIImageView *)[cellTmp viewWithTag:1004]).hidden = YES;
        }
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        ((UIImageView *)[cell viewWithTag:1004]).hidden = NO;
        _selectedAddressOrder = (int)indexPath.row;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.00001f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return _afterRequest?126.00001f:0.0f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _afterRequest?126.0f:0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.row<[_addressArray count]) {
        static NSString *CellIdentifier = @"AddressCell";
        if (!_nibsRegistered) {
            UINib *mainNib = [UINib nibWithNibName:@"AddressCell" bundle:nil];
            [tableView registerNib:mainNib forCellReuseIdentifier:CellIdentifier];
            _nibsRegistered = YES;
        }
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        THNAdress *address = [_addressArray objectAtIndex:indexPath.row];
        ((UILabel *)[cell viewWithTag:1001]).text = [NSString stringWithFormat:@"收货人：%@",address.addressUserName];
        ((UILabel *)[cell viewWithTag:1002]).text = address.addressDetail;
        ((UILabel *)[cell viewWithTag:1003]).text = address.addressPhone;
        ((UILabel *)[cell viewWithTag:1005]).text = [NSString stringWithFormat:@"%@ %@",address.addressProvinceName, address.addressCityName];
        ((UIImageView *)[cell viewWithTag:1004]).hidden = !address.addressIsDefault;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return _afterRequest?[_addressArray count]:0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *foot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 126)];
    [foot setBackgroundColor:UIColorFromRGB(0xf8f8f8)];
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(15, 15, SCREEN_WIDTH-30, 44);
    [addButton setBackgroundColor:[UIColor clearColor]];
    [addButton setTitle:@"添加收货地址" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor SecondColor] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addNewAddress) forControlEvents:UIControlEventTouchUpInside];
    [addButton.layer setMasksToBounds:YES];
    [addButton.layer setCornerRadius:4.0];
    [addButton.layer setBorderWidth:.5]; //边框宽度
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 254/255.0, 52/255.0, 102/255.0, 1 });
    [addButton.layer setBorderColor:colorref];//边框颜色
    [foot addSubview:addButton];
    
    return foot;
}

#pragma mark - tableview 编辑
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath

{
    //这里进行插入，删除，编辑操作
    THNAdress *address = [_addressArray objectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 开始请求列表，页面进入正在加载状态
        NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         address.addressID,                                 @"id",
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
        [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiAccountDeleteAddress]];
        [self showLoadingWithAni:YES];
    }
    
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
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

#pragma mark - ASI Delegate
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    if ([jyRequest.requestUrl hasSuffix:kTHNApiAccountUserAddress]) {
        // 解析数据
        _afterRequest = YES;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSArray *rows = [result objectForKey:@"rows"];
            for (NSDictionary *dict in rows) {
                THNAdress *address = [[THNAdress alloc] init];
                address.addressID = [dict stringValueForKey:@"_id"];
                address.addressUserName = [dict stringValueForKey:@"name"];
                address.addressPhone = [dict stringValueForKey:@"phone"];
                address.addressEmail = [dict stringValueForKey:@"email"];
                address.addressCreateOn = [dict stringValueForKey:@"created_on"];
                address.addressUpdateOn = [dict stringValueForKey:@"updated_on"];
                address.addressIsDefault = [dict boolValueForKey:@"is_default"];
                address.addressProvinceName = [dict stringValueForKey:@"province_name"];
                address.addressCityName = [dict stringValueForKey:@"city_name"];
                address.addressProvinceID = [[dict stringValueForKey:@"province"] intValue];
                address.addressCityID = [[dict stringValueForKey:@"city"] intValue];
                address.addressDetail = [dict stringValueForKey:@"address"];
                address.addressZip = [dict stringValueForKey:@"zip"];
                
                [_addressArray addObject:address];
            }
        }
        //刷新界面
        [self.tableview reloadData];
        [self hideLoading];
    }else if ([jyRequest.requestUrl hasSuffix:kTHNApiAccountDeleteAddress]){
        // 解析数据
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSString *addressDeleteID = [result stringValueForKey:@"id"];
            THNAdress *deleteTmp = nil;
            for (THNAdress *address in _addressArray) {
                if ([address.addressID isEqualToString:addressDeleteID]) {
                    deleteTmp = address;
                }
            }
            if (deleteTmp) {
                [_addressArray removeObject:deleteTmp];
            }
        }
        //刷新界面
        [self.tableview reloadData];
        [self hideLoading];
    }
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    NSString *errorInfo = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    [self hideLoadingWithCompletionMessage:errorInfo];
    THNErrorPage *errorPage = [[THNErrorPage alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-20-44-50)];
    __block THNErrorPage *weakError = errorPage;
    errorPage.callBack = ^{
        JYLog(@"XXXXXXXXX");
        [weakError removeFromSuperview];
        [self requestForAddressList];
    };
    errorPage.tag = 9328301;
    if (![self.view viewWithTag:9328301]) {
        [self.view addSubview:errorPage];
    }
}
@end
