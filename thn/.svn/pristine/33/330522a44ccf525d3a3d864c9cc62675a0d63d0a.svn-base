//
//  THNUserInfosTableViewController.m
//  store
//
//  Created by XiaobinJia on 15/2/11.
//  Copyright (c) 2015年 TaiHuoNiao. All rights reserved.
//

#import "THNUserInfosTableViewController.h"
#import "JYComHttpRequest.h"
#import "JYComCustomTextField.h"
#import "JYSexPicker.h"
#import "THNUserManager.h"
#import "THNAddressManagerViewController.h"
#import <IBActionSheet/IBActionSheet.h>
#import <UIImageView+WebCache.h>
#import "THNUserInfo.h"
#import "NSMutableDictionary+AddSign.h"
#import <UIViewController+AMThumblrHud.h>
#import "THNUserManager.h"
#import "NSData+JYComBase64.h"

@interface THNUserInfosTableViewController ()<IBActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, JYComHttpRequestDelegate, UITextFieldDelegate>
@property (nonatomic, retain) THNUserInfo *tmpUserInfo;
@end

@implementation THNUserInfosTableViewController
{
    UIImagePickerController     *_imagePicker;
    UIImage                     *_headImage;
    JYSexPicker                 *_picker;
    
    JYComHttpRequest            *_request;
    THNUserInfo                 *_tmpUserInfo;
}
@synthesize tmpUserInfo = _tmpUserInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人资料";
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, -5, 10, 25)];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rightButton setTitleColor:[UIColor SecondColor] forState:UIControlStateNormal];
    [rightButton setTitle:@"提交" forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(0, 0, 44, 44);
    [rightButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.tableView.tableFooterView = view;
    
    _tmpUserInfo = [[THNUserInfo alloc] init];//[[THNUserManager sharedTHNUserManager] userInfo];
    _tmpUserInfo.userNickName = [[THNUserManager sharedTHNUserManager] userInfo].userNickName;
    _tmpUserInfo.userCity = [[THNUserManager sharedTHNUserManager] userInfo].userCity;
    _tmpUserInfo.userJob = [[THNUserManager sharedTHNUserManager] userInfo].userJob;
    _tmpUserInfo.userPhone = [[THNUserManager sharedTHNUserManager] userInfo].userPhone;
    _tmpUserInfo.userMail = [[THNUserManager sharedTHNUserManager] userInfo].userMail;
    _tmpUserInfo.userRealname = [[THNUserManager sharedTHNUserManager] userInfo].userRealname;
    _tmpUserInfo.userAddress = [[THNUserManager sharedTHNUserManager] userInfo].userAddress;
    _tmpUserInfo.userSummery = [[THNUserManager sharedTHNUserManager] userInfo].userSummery;
    _tmpUserInfo.userSex = [[THNUserManager sharedTHNUserManager] userInfo].userSex;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(headChange)
                                                 name:@"UserInfoStored"
                                               object:nil];
}

- (void)headChange
{
    if (self.tableView) {
        [self.tableView reloadData];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField respondsToSelector:@selector(resignFirstResponder)]) {
        
        [textField resignFirstResponder];
    }
    return YES;
}
- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    [_request clearDelegatesAndCancel];
    _request = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UserInfoStored" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideKeyboard];
    switch (indexPath.row) {
        case 0:
        {
            IBActionSheet *actionSheet = [[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil];
            actionSheet.delegate = self;
            [actionSheet setButtonTextColor:[UIColor SecondColor]];
            [actionSheet setFont:[UIFont systemFontOfSize:20]];
            [actionSheet showInView:self.view];
        }
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.0000001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
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
    NSArray* array = @[@"头像",@"昵称",@"性别",@"城市",@"职业",@"电话",@"邮箱",@"真实姓名",@"详细地址",@"个人简介"];
    static NSString *CellIdentifier = @"MineCell";
    static NSString *CellIdentifierHead = @"MineCellHead";
    static NSString *CellIdentifierSex = @"MineCellSex";
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierHead];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierHead];
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.frame.size.width-40-50, 15, 50, 50)];
            imageView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
            imageView.tag = 1101;
            [cell.contentView addSubview:imageView];
            imageView.layer.masksToBounds=YES;
            imageView.layer.cornerRadius = 25;
        }
    }else if (indexPath.row == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSex];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierSex];
            _picker = [[JYSexPicker alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100-10, 12, 0, 0)];
            _picker.backgroundColor = [UIColor clearColor];
            __weak typeof(self) weakSelf = self;
            [_picker setSelectedBlock:^(NSNumber *number){
                weakSelf.tmpUserInfo.userSex = [number intValue];
            }];
            [cell addSubview:_picker];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            JYComCustomTextField *tf = [[JYComCustomTextField alloc] initWithFrame:CGRectMake(tableView.frame.size.width-17-200, 0, 200, 43)];
            [tf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            tf.tag = 1102;
            tf.delegate = self;
            tf.backgroundColor = [UIColor clearColor];
            tf.placeholdOffSet = CGPointMake(1, 8);
            tf.textOffSet = CGPointMake(1, 8);
            tf.textColor = UIColorFromRGB(0x6e6e6e);
            tf.font = [UIFont systemFontOfSize:17];
            tf.textAlignment = NSTextAlignmentRight;
            [cell addSubview:tf];
        }
    }
    
    cell.backgroundColor = UIColorFromRGB(0xF8F8F8);
    [cell setSeparatorInset:UIEdgeInsetsZero];
    if (indexPath.row == 0)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    cell.textLabel.textColor = [UIColor BlackTextColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //五行都需要赋值
    cell.textLabel.text = array[indexPath.row];
    switch (indexPath.row) {
        case 0:
        {
            [((UIImageView *)[cell viewWithTag:1101]) sd_setImageWithURL:[NSURL URLWithString:[THNUserManager sharedTHNUserManager].userInfo.userAvata]];
        }
            break;
        case 1:
        {
            ((JYComCustomTextField *)[cell viewWithTag:1102]).placeholder = self.tmpUserInfo.userNickName;
        }
            break;
        case 2:
        {
            _picker.sex = self.tmpUserInfo.userSex;
        }
            break;
        case 3:
        {
            ((JYComCustomTextField *)[cell viewWithTag:1102]).placeholder = self.tmpUserInfo.userCity;
        }
            break;
        case 4:
        {
            ((JYComCustomTextField *)[cell viewWithTag:1102]).placeholder = self.tmpUserInfo.userJob;
        }
            break;
        case 5:
        {
            ((JYComCustomTextField *)[cell viewWithTag:1102]).placeholder = self.tmpUserInfo.userPhone;
        }
            break;
        case 6:
        {
            ((JYComCustomTextField *)[cell viewWithTag:1102]).placeholder = self.tmpUserInfo.userMail;
        }
            break;
        case 7:
        {
            ((JYComCustomTextField *)[cell viewWithTag:1102]).placeholder = self.tmpUserInfo.userRealname;
        }
            break;
        case 8:
        {
            ((JYComCustomTextField *)[cell viewWithTag:1102]).placeholder = self.tmpUserInfo.userAddress;
        }
            break;
        case 9:
        {
            ((JYComCustomTextField *)[cell viewWithTag:1102]).placeholder = self.tmpUserInfo.userSummery;
        }
            break;
        default:
            break;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
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

#pragma mark - Back
- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonClicked:(id)sender
{
    [self hideKeyboard];
    //修改个人资料
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[THNUserManager sharedTHNUserManager] userid],    @"current_user_id",
                                     self.tmpUserInfo.userNickName,                                          @"nickname",
                                     [NSString stringWithFormat:@"%d",_tmpUserInfo.userSex],             @"sex",
                                     self.tmpUserInfo.userCity,                                              @"city",
                                     self.tmpUserInfo.userJob,                                               @"job",
                                     self.tmpUserInfo.userPhone,                                             @"phone",
                                     self.tmpUserInfo.userMail,                                             @"email",
                                     self.tmpUserInfo.userRealname,                                          @"realname",
                                     self.tmpUserInfo.userAddress,                                           @"address",
                                     self.tmpUserInfo.userSummery,                                              @"summary",
                                     [THNUserManager channel],                          @"channel",
                                     [THNUserManager client_id],                        @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],      @"uuid",
                                     [THNUserManager time],                             @"time",
                                     nil];
    [listPara addSign];
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request getInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiAccountEditUserInfo]];
    [self showLoadingWithAni:YES];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideKeyboard];
}
- (void)hideKeyboard
{
    NSArray *arr = [self.tableView visibleCells];
    for (UITableViewCell *cell in arr) {
        UIView *view = [cell viewWithTag:1102];
        if (view && [view isKindOfClass:[JYComCustomTextField class]]) {
            [(JYComCustomTextField *)view resignFirstResponder];
        }
    }
}
#pragma mark -
#pragma mark - Picker获取图片
- (void)pickImageFromAlbum
{
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.delegate = self;
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    _imagePicker.allowsEditing = YES;
    
    [_imagePicker viewWillAppear:YES];
    [_imagePicker viewDidAppear:YES];
    _imagePicker.view.frame = CGRectMake(SCREEN_WIDTH, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    [self presentViewController:_imagePicker animated:YES completion:^{
        
    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage=[info objectForKey:UIImagePickerControllerEditedImage];
    _headImage = [originalImage TelescopicImageToSize:CGSizeMake(THNUserHeadWidth, THNUserHeadHeight)];
    
    [self removeImagePicker];
    
    NSData *data = UIImageJPEGRepresentation(_headImage, .6);
    NSString *avatarString = [data jyBase64Encoding];
    
    //修改个人资料
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[THNUserManager sharedTHNUserManager] userid],    @"current_user_id",
                                     @"3",                                            @"type",
                                     [THNUserManager channel],                          @"channel",
                                     [THNUserManager client_id],                        @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],      @"uuid",
                                     [THNUserManager time],                             @"time",
                                     nil];
    [listPara addSign];
    [listPara setObject:avatarString forKey:@"tmp"];
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiAccountAvatar]];
    [self showLoadingWithAni:YES];
    
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.title = @"选取头像";
    [viewController.navigationController.navigationBar setTitleTextAttributes:@{
                                                                                NSForegroundColorAttributeName: [UIColor SecondColor]
                                                                                }];
    if (IOS7_OR_LATER) {
        viewController.navigationItem.rightBarButtonItem.tintColor = [UIColor SecondColor];
        viewController.navigationController.navigationBar.barTintColor = [UIColor MainColor];
        viewController.navigationController.navigationBar.tintColor = [UIColor SecondColor];
        [[_imagePicker navigationBar] setTranslucent:NO];
    }
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType ==     UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
}

- (void)upload
{
    //上传
    
}
- (void)showHead
{
    //[self.headImageView setImage:_headImage forState:UIControlStateNormal];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self removeImagePicker];
}
- (void)removeImagePicker
{
    [_imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark - JYComHttp delegate
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error{
    JYLog(@"request error:%@",error);
    [self hideLoading];
    NSString *errorInfo = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    if (errorInfo) {
        [self alertWithInfo:errorInfo];
    }
}

- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result{
    JYLog(@"receive result:%@",result);
    if ([jyRequest.requestUrl hasSuffix:kTHNApiAccountEditUserInfo]) {
        
        if ([result isKindOfClass:[NSDictionary class]]) {
            [THNUserManager sharedTHNUserManager].userInfo.userNickName =     [result stringValueForKey:@"nickname"];
            [THNUserManager sharedTHNUserManager].userInfo.userCity =         [result stringValueForKey:@"city"];
            [THNUserManager sharedTHNUserManager].userInfo.userJob =          [[result objectForKey:@"profile"] stringValueForKey:@"job"];
            [THNUserManager sharedTHNUserManager].userInfo.userPhone =        [[result objectForKey:@"profile"] stringValueForKey:@"phone"];
            [THNUserManager sharedTHNUserManager].userInfo.userSex =          [result intValueForKey:@"sex"];
            [THNUserManager sharedTHNUserManager].userInfo.userMail = [result stringValueForKey:@"email"];
            [THNUserManager sharedTHNUserManager].userInfo.userAddress = [[result objectForKey:@"profile"] stringValueForKey:@"address"];
            [THNUserManager sharedTHNUserManager].userInfo.userRealname = [[result objectForKey:@"profile"] stringValueForKey:@"realname"];
            [THNUserManager sharedTHNUserManager].userInfo.userSummery = [result stringValueForKey:@"summary"];
            
        }
        //刷新界面
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .3 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self hideLoadingWithCompletionMessage:@"信息修改成功！"];
        });
    }else if([jyRequest.requestUrl hasSuffix:kTHNApiAccountAvatar]){
        NSString *url = nil;
        if ([result isKindOfClass:[NSDictionary class]]) {
            id asset = [result objectForKey:@"asset"];
            if ([asset isKindOfClass:[NSDictionary class]]) {
                url = [(NSDictionary *)asset stringValueForKey:@"file_url"];
            }
        }
        //更新显示
        [((UIImageView *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:1101]) sd_setImageWithURL:[NSURL URLWithString:url]];
        //更新个人信息
        [[THNUserManager sharedTHNUserManager] modifyLocalAvatar:url];
        
        [self hideLoadingWithCompletionMessage:@"头像上传成功！"];
    }
}

#pragma mark - delegete
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self pickImageFromAlbum];
    }
    
}

- (void)textFieldDidChange:(UITextField *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    NSIndexPath *ip = [self.tableView indexPathForCell:cell];
    switch (ip.row) {
        case 1:
        {
            self.tmpUserInfo.userNickName = sender.text;
            if ([self.tmpUserInfo.userNickName isEqualToString:@""]) {
                self.tmpUserInfo.userNickName = [THNUserManager sharedTHNUserManager].userInfo.userNickName;
            }
        }
            break;
        case 3:
        {
            self.tmpUserInfo.userCity = sender.text;
            if ([self.tmpUserInfo.userCity isEqualToString:@""]) {
                self.tmpUserInfo.userCity = [THNUserManager sharedTHNUserManager].userInfo.userCity;
            }
        }
            break;
        case 4:
        {
            self.tmpUserInfo.userJob = sender.text;
            if ([self.tmpUserInfo.userJob isEqualToString:@""]) {
                self.tmpUserInfo.userJob = [THNUserManager sharedTHNUserManager].userInfo.userJob;
            }
        }
            break;
        case 5:
        {
            self.tmpUserInfo.userPhone = sender.text;
            if ([self.tmpUserInfo.userPhone isEqualToString:@""]) {
                self.tmpUserInfo.userPhone = [THNUserManager sharedTHNUserManager].userInfo.userPhone;
            }
        }
            break;
        case 6:
        {
            self.tmpUserInfo.userMail = sender.text;
            if ([self.tmpUserInfo.userMail isEqualToString:@""]) {
                self.tmpUserInfo.userMail = [THNUserManager sharedTHNUserManager].userInfo.userMail;
            }
        }
            break;
        case 7:
        {
            self.tmpUserInfo.userRealname = sender.text;
            if ([self.tmpUserInfo.userRealname isEqualToString:@""]) {
                self.tmpUserInfo.userRealname = [THNUserManager sharedTHNUserManager].userInfo.userRealname;
            }
        }
            break;
        case 8:
        {
            self.tmpUserInfo.userAddress = sender.text;
            if ([self.tmpUserInfo.userAddress isEqualToString:@""]) {
                self.tmpUserInfo.userAddress = [THNUserManager sharedTHNUserManager].userInfo.userAddress;
            }
        }
            break;
        case 9:
        {
            self.tmpUserInfo.userSummery = sender.text;
            if ([self.tmpUserInfo.userSummery isEqualToString:@""]) {
                self.tmpUserInfo.userSummery = [THNUserManager sharedTHNUserManager].userInfo.userSummery;
            }
        }
            break;
            
        default:
            break;
    }
}

@end
