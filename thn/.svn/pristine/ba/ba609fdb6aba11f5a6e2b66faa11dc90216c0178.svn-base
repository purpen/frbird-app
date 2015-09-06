//
//  THNAddressAddViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-20.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNAddressAddViewController.h"
#import "JYComCustomTextField.h"
#import "JYComHttpRequest.h"
#import "THNUserManager.h"
#import <UIViewController+AMThumblrHud.h>
#import "HZAreaPickerView.h"
#import <UIViewController+MBProgressHUD.h>
#import "NSMutableDictionary+AddSign.h"

@interface THNAddressAddViewController ()<JYComHttpRequestDelegate, UITextFieldDelegate, HZAreaPickerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) HZAreaPickerView *locatePicker;
@property (strong, nonatomic) HZLocation *selectedLocation;
@end

@implementation THNAddressAddViewController
{
    BOOL                _nibsRegistered;
    IBOutlet UIButton   *_deleteButton;
    IBOutlet UIButton   *_defaultButton;
    JYComHttpRequest    *_request;
    HZLocation          *_selectedLocation;
}
@synthesize address = _address;
@synthesize locatePicker=_locatePicker;
@synthesize selectedLocation = _selectedLocation;

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
    self.title = @"编辑收货地址";
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, -5, 10, 25)];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rightButton setTitleColor:[UIColor SecondColor] forState:UIControlStateNormal];
    [rightButton setTitle:@"保存" forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(0, 0, 44, 44);
    [rightButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [_deleteButton.layer setMasksToBounds:YES];
    [_deleteButton.layer setCornerRadius:0.0];
    [_deleteButton.layer setBorderWidth:.5]; //边框宽度
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 203/255.0, 202/255.0, 207/255.0, 1 });
    [_deleteButton.layer setBorderColor:colorref];//边框颜色
    
    if (!self.isEdit) {
        _deleteButton.hidden = YES;
        _defaultButton.hidden = YES;
    }else{
        //初始化self.selectedLocation
        self.selectedLocation = [[HZLocation alloc] init];
        self.selectedLocation.state = _address.addressProvinceName;
        self.selectedLocation.stateID = _address.addressProvinceID;
        self.selectedLocation.city = _address.addressCityName;
        self.selectedLocation.cityID = _address.addressCityID;
    }
    
    _nibsRegistered = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ButtonClicked
- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightButtonClicked:(UIButton *)sender
{
    for (int i=0; i<5; i++) {
        [((JYComCustomTextField *)[[_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].contentView viewWithTag:1001]) resignFirstResponder];
    }
    [self cancelLocatePicker];
    //保存地址信息
    NSString *addressUsername = ((JYComCustomTextField *)[[_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].contentView viewWithTag:1001]).text;
    if (!addressUsername || [addressUsername isEqualToString:@""]) {
        [self alertWithInfo:@"请输入收货人姓名！"];
        return;
    }
    NSString *addressPhone = ((JYComCustomTextField *)[[_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].contentView viewWithTag:1001]).text;
    if (!addressPhone || [addressPhone isEqualToString:@""]) {
        [self alertWithInfo:@"请输入手机号！"];
        return;
    }
    NSString *addressZip = ((JYComCustomTextField *)[[_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]].contentView viewWithTag:1001]).text;
    if (!addressZip || [addressZip isEqualToString:@""]) {
        [self alertWithInfo:@"请输入邮编！"];
        return;
    }
    NSString *addressProvince = [NSString stringWithFormat:@"%d", self.selectedLocation.stateID];
    NSString *addressCity = [NSString stringWithFormat:@"%d", self.selectedLocation.cityID];
    if (!addressProvince || [addressProvince isEqualToString:@""]) {
        [self alertWithInfo:@"请输入省市地址！"];
        return;
    }
    if (!addressCity || [addressCity isEqualToString:@""]) {
        [self alertWithInfo:@"请输入省市地址！"];
        return;
    }
    NSString *addressDetail = ((JYComCustomTextField *)[[_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]].contentView viewWithTag:1001]).text;
    if (!addressDetail || [addressDetail isEqualToString:@""]) {
        [self alertWithInfo:@"请输入详细地址！"];
        return;
    }
    
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     addressUsername,                                   @"name",
                                     addressPhone,                                      @"phone",
                                     addressZip,                                        @"zip",
                                     addressProvince,                                   @"province",
                                     addressCity,                                       @"city",
                                     addressDetail,                                     @"address",
                                     @"0",                                              @"is_default",
                                     [[THNUserManager sharedTHNUserManager] userid],    @"current_user_id",
                                     [THNUserManager channel],                          @"channel",
                                     [THNUserManager client_id],                        @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],      @"uuid",
                                     [THNUserManager time],                             @"time",
                                     nil];
    if (self.isEdit) {
        [listPara setObject:_address.addressID forKey:@"_id"];
    }
    [listPara addSign];
    //开始请求商品详情
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiAccountAddAddress]];
    [self showLoadingWithAni:YES];
}
#pragma mark table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 0.00001f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 0.00001f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = @[@"收货人姓名:",@"手机号:",@"邮政编码:",@"省份、地区:",@"详细地址:"];
    static NSString *CellIdentifier = @"InfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor = UIColorFromRGB(0xf8f8f8);
        JYComCustomTextField *tf = [[JYComCustomTextField alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height)];
        tf.tag = 1001;
        tf.delegate = self;
        tf.textColor = UIColorFromRGB(0x6e6e6e);
        [cell.contentView addSubview:tf];
    }
    ((JYComCustomTextField *)[cell.contentView viewWithTag:1001]).placeholder = array[indexPath.row];
    if (self.isEdit) {
        NSArray *textArray = [NSArray arrayWithObjects:_address.addressUserName, _address.addressPhone, _address.addressZip, [NSString stringWithFormat:@"%@ %@", _address.addressProvinceName, _address.addressCityName], _address.addressDetail, nil];
        if ([textArray count]>4) {
            ((JYComCustomTextField *)[cell.contentView viewWithTag:1001]).text = [textArray objectAtIndex:indexPath.row];
        }
    }
    return cell;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
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
    //去除最后一行分割线
    if (indexPath.row==1) {
        cell.separatorInset = UIEdgeInsetsMake(10, 0, 0, 0);
    }
}

#pragma mark - ASI Delegate
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    if ([jyRequest.requestUrl hasSuffix:kTHNApiAccountAddAddress]) {
        // 解析数据
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = result;
            _address.addressUserName =          [dict stringValueForKey:@"name"];
            _address.addressPhone =             [dict stringValueForKey:@"phone"];
            _address.addressEmail =             [dict stringValueForKey:@"email"];
            _address.addressCreateOn =          [dict stringValueForKey:@"created_on"];
            _address.addressUpdateOn =          [dict stringValueForKey:@"updated_on"];
            _address.addressIsDefault =         [dict boolValueForKey:@"is_default"];
            _address.addressProvinceName =      [dict stringValueForKey:@"province_name"];
            _address.addressCityName =          [dict stringValueForKey:@"city_name"];
            _address.addressProvinceID =        [[dict stringValueForKey:@"province"] intValue];
            _address.addressCityID =            [[dict stringValueForKey:@"city"] intValue];
            _address.addressDetail =            [dict stringValueForKey:@"address"];
            _address.addressZip =               [dict stringValueForKey:@"zip"];
            if (self.isEdit) {
                [self alertWithInfo:@"地址已修改"];
            }else{
                
                [self alertWithInfo:@"地址已添加"];
            }
        }
        //刷新界面
        [self.tableview reloadData];
        [self hideLoading];
    }else if([jyRequest.requestUrl hasSuffix:kTHNApiAccountDeleteAddress]){
        
    }else if ([jyRequest.requestUrl hasSuffix:kTHNApiAccountDefaultAddress]){
        [self hideLoading];
        [self alertWithInfo:@"设置默认地址成功"];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    NSString *errorInfo = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    [self hideLoadingWithCompletionMessage:errorInfo];
}
#pragma mark - HZAreaPicker delegate
-(void)pickerDidChaneStatus:(HZAreaPickerView *)picker
{
    self.selectedLocation = picker.locate;
    UITableViewCell *cell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    ((JYComCustomTextField *)[cell viewWithTag:1001]).text = [NSString stringWithFormat:@"%@ %@", self.selectedLocation.state, self.selectedLocation.city];
}

-(void)cancelLocatePicker
{
    [self.locatePicker cancelPicker];
    self.locatePicker.delegate = nil;
    self.locatePicker = nil;
    UITableViewCell *cell = [self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    [((JYComCustomTextField *)[cell viewWithTag:1001]) resignFirstResponder];
}

#pragma mark - TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField.placeholder isEqualToString:@"省份、地区:"]) {
        for (int i=0; i<5; i++) {
            [((JYComCustomTextField *)[[_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].contentView viewWithTag:1001]) resignFirstResponder];
        }
        [self cancelLocatePicker];
        self.locatePicker = [[HZAreaPickerView alloc] initWithDelegate:self];
        [self.locatePicker showInView:self.view];
        return NO;
    }else{
        [self cancelLocatePicker];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    for (int i=0; i<5; i++) {
        [((JYComCustomTextField *)[[_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].contentView viewWithTag:1001]) resignFirstResponder];
    }
    return YES;
}

- (IBAction)defaultAddress:(id)sender
{
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     _address.addressID,                                @"id",
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
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiAccountDefaultAddress]];
    [self showLoadingWithAni:YES];
}
- (IBAction)deleteAddress:(id)sender
{
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     _address.addressID,                                @"id",
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
@end
