//
//  THNAddTopicViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-25.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNAddTopicViewController.h"
#import "THNTextView.h"
#import "JYComCustomTextField.h"
#import "THNTopicCategory.h"
#import "JYComHttpRequest.h"
#import "NSMutableDictionary+AddSign.h"
#import "THNUserManager.h"
#import "JDStatusBarNotification.h"

@interface THNAddTopicViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, JYComHttpRequestDelegate>

@end

@implementation THNAddTopicViewController
{
    UIImagePickerController     *_imagePicker;
    NSMutableArray              *_picArr;
    THNTopicCategory            *_mainCate;
    int                         _selectMainCateIndex;
    JYComHttpRequest            *_request;
}

- (id)initWithMainCate:(THNTopicCategory *)mainCate
{
    if (self = [super init]) {
        _mainCate = mainCate;
        _picArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"发表话题";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setTitleColor:[UIColor SecondColor] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(0, 0, 60, 44);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(pageBack) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:backButton];
    
    UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [uploadButton setTitleColor:[UIColor SecondColor] forState:UIControlStateNormal];
    uploadButton.frame = CGRectMake(SCREEN_WIDTH-60, 0, 60, 44);
    uploadButton.backgroundColor = [UIColor clearColor];
    [uploadButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [uploadButton setTitle:@"发布" forState:UIControlStateNormal];
    [self.navigationController.navigationBar addSubview:uploadButton];
    
    ((UIScrollView *)self.view).contentSize = CGSizeMake(SCREEN_WIDTH, 588);
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 130, 15)];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.text = @"选择类别";
    tipLabel.textColor = UIColorFromRGB(0x6e6e6e);
    tipLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:tipLabel];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
    for (THNTopicCategory *cate in _mainCate.cateSubCates) {
        NSString *str = cate.cateTitle;
        [arr addObject:str];
    }
    CGFloat baseHeight = 0;
    if ([arr count]<4) {
        UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:arr];
        segment.tintColor = [UIColor SecondColor];
        segment.tag = 39011;
        segment.selectedSegmentIndex = 0;
        [segment addTarget:self action:@selector(valueChange:)
          forControlEvents:UIControlEventValueChanged];
        segment.frame = CGRectMake(15, 12+15+10, SCREEN_WIDTH-15*2, 30);
        [self.view addSubview:segment];
        baseHeight = segment.frame.origin.y+segment.frame.size.height+15;
    }else{
        NSArray *titleArray1 = [NSArray arrayWithObjects:[arr objectAtIndex:0], [arr objectAtIndex:1], [arr objectAtIndex:2], nil];
        NSMutableArray *titleArray2 = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i=3;i<[arr count];i++) {
            [titleArray2 addObject:[arr objectAtIndex:i]];
        }
        UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:titleArray1];
        segment.tintColor = [UIColor SecondColor];
        segment.tag = 39011;
        segment.selectedSegmentIndex = 0;
        [segment addTarget:self action:@selector(valueChange:)
          forControlEvents:UIControlEventValueChanged];
        segment.frame = CGRectMake(15, 12+15+10, SCREEN_WIDTH-15*2, 30);
        [self.view addSubview:segment];
        baseHeight = segment.frame.origin.y+segment.frame.size.height+5;
        
        UISegmentedControl *segment2 = [[UISegmentedControl alloc] initWithItems:titleArray2];
        segment2.tintColor = [UIColor SecondColor];
        segment2.tag = 39012;
        segment2.selectedSegmentIndex = UISegmentedControlNoSegment;
        [segment2 addTarget:self action:@selector(valueChange:)
          forControlEvents:UIControlEventValueChanged];
        segment2.frame = CGRectMake(15, baseHeight, SCREEN_WIDTH-15*2, 30);
        [self.view addSubview:segment2];
        baseHeight = segment2.frame.origin.y+segment2.frame.size.height+15;
    }
    
    
    
    JYComCustomTextField *titleTF = [[JYComCustomTextField alloc] initWithFrame:CGRectMake(15, baseHeight, SCREEN_WIDTH-15*2, 44)];
    titleTF.tag = 13201;
    titleTF.placeholder = @"标题";
    titleTF.delegate = self;
    titleTF.textColor = UIColorFromRGB(0x656565);
    titleTF.backgroundColor = [UIColor whiteColor];
    titleTF.layer.borderWidth = .5;
    titleTF.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    titleTF.font = [UIFont systemFontOfSize:15];
    titleTF.placeholdOffSet = CGPointMake(10, .01);
    titleTF.textOffSet = CGPointMake(10, .01);
    [self.view addSubview:titleTF];
    
    THNTextView *contentBg = [[THNTextView alloc] initWithFrame:CGRectMake(15, titleTF.frame.origin.y+titleTF.frame.size.height-1, SCREEN_WIDTH-15*2, 84)];
    contentBg.backgroundColor = [UIColor whiteColor];
    contentBg.placeholder = @"内容";
    contentBg.tag = 13202;
    contentBg.textColor = UIColorFromRGB(0x656565);
    contentBg.font = [UIFont systemFontOfSize:15];
    contentBg.layer.borderWidth = .5;
    contentBg.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    [contentBg addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addSubview:contentBg];
    /*
     UILabel *contentTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 30, 15)];
     contentTipLabel.backgroundColor = [UIColor clearColor];
     contentTipLabel.text = @"内容";
     contentTipLabel.textColor = UIColorFromRGB(0x6e6e6e);
     contentTipLabel.font = [UIFont systemFontOfSize:15];
     [contentBg addSubview:contentTipLabel];
     */
    JYComCustomTextField *tagTF = [[JYComCustomTextField alloc] initWithFrame:CGRectMake(15, contentBg.frame.origin.y+contentBg.frame.size.height-1, SCREEN_WIDTH-15*2, 45)];
    tagTF.textColor = UIColorFromRGB(0x656565);
    tagTF.placeholder = @"标签";
    tagTF.delegate = self;
    tagTF.tag = 13203;
    tagTF.backgroundColor = [UIColor whiteColor];
    tagTF.layer.borderWidth = .5;
    tagTF.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    tagTF.font = [UIFont systemFontOfSize:15];
    tagTF.placeholdOffSet = CGPointMake(10, .01);
    tagTF.textOffSet = CGPointMake(10, .01);
    [self.view addSubview:tagTF];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(15, tagTF.frame.origin.y+tagTF.frame.size.height+15, SCREEN_WIDTH-15*2, 44);
    [addButton setTitleColor:UIColorFromRGB(0x858585) forState:UIControlStateNormal];
    addButton.tag = 90991;
    [addButton addTarget:self action:@selector(pickImageFromAlbum) forControlEvents:UIControlEventTouchUpInside];
    [addButton setBackgroundColor:UIColorFromRGB(0xefefef)];
    [addButton setTitle:@"立即上传" forState:UIControlStateNormal];
    [addButton.layer setMasksToBounds:YES];
    [addButton.layer setCornerRadius:4.0];
    addButton.layer.borderWidth = .5;
    addButton.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    //[self.view addSubview:addButton];
    
    //[self refreshPics];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)dealloc
{
    [_request clearDelegatesAndCancel];
    _request = nil;
    [((UIView *)[self.view viewWithTag:13202]) removeObserver:self forKeyPath:@"contentSize"];
}
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UITextView *textView = object;
    textView.contentOffset = (CGPoint){.x = -6,.y = 0};
}

- (void)pageBack
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)valueChange:(UISegmentedControl *)sender
{
    long index=-1;
    if (sender.tag==39011) {
        index = sender.selectedSegmentIndex;
        UISegmentedControl *seg = ((UISegmentedControl *)[self.view viewWithTag:39012]);
        if (seg) {
            seg.selectedSegmentIndex = UISegmentedControlNoSegment;
        }
    }else if(sender.tag==39012){
        index = 3 + sender.selectedSegmentIndex;
        UISegmentedControl *seg = ((UISegmentedControl *)[self.view viewWithTag:39011]);
        if (seg) {
            seg.selectedSegmentIndex = UISegmentedControlNoSegment;
        }
    }
    _selectMainCateIndex = (int)index;
}
#pragma mark - 刷新图片显示

- (void)refreshPics
{
    UIButton *button = ((UIButton *)[self.view viewWithTag:90991]);
    CGFloat f = button.frame.origin.y + button.frame.size.height+10;
    CGFloat width = (SCREEN_WIDTH-15-15-10-10)/3;
    CGFloat totalHeight = 0;
    for (int i=0; i<[_picArr count];i++) {
        UIImageView *iv = [[UIImageView alloc] initWithImage:[_picArr objectAtIndex:i]];
        iv.frame = CGRectMake(15+(width+10)*(i%3), f+(width+10)*(i/3), width, width);
        [self.view addSubview:iv];
        totalHeight = iv.frame.origin.y + iv.frame.size.height + 30;
    }
    //刷新scrollView的内容高度
    ((UIScrollView *)self.view).contentSize = CGSizeMake(SCREEN_WIDTH, totalHeight);
    if (totalHeight>SCREEN_HEIGHT-64) {
        [UIView animateWithDuration:.5 animations:^{
            [((UIScrollView *)self.view) setContentOffset:CGPointMake(0, totalHeight-SCREEN_HEIGHT)];
        }];
        
    }
}
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
    [self presentViewController:_imagePicker animated:YES completion:^{}];
    /*
     [self.view addSubview:_imagePicker.view];
     [UIView beginAnimations:nil context:nil];
     [UIView setAnimationDuration:0.3];
     [UIView setAnimationDelegate:self];
     
     [_imagePicker.view setFrame:CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
     self.navigationController.navigationBarHidden = YES;
     
     [UIView commitAnimations];
     */
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage=[info objectForKey:UIImagePickerControllerEditedImage];
    
    [_picArr addObject:originalImage];
    
    [self removeImagePicker];
    
    [self refreshPics];
    //刷新图片的显示
    //[self performSelector:@selector(upload)];
    
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.title = @"选取头像";
    [viewController.navigationController.navigationBar setTitleTextAttributes:@{
                                                                                UITextAttributeTextColor : [UIColor SecondColor]
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self removeImagePicker];
}
- (void)removeImagePicker
{
    [_imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
    /*
     //写成先一到左边，再移除，在调用功能函数
     [UIView beginAnimations:nil context:nil];
     [UIView setAnimationDuration:0.3];
     [UIView setAnimationDelegate:self];
     [UIView setAnimationDidStopSelector:@selector(pickerRemove)];
     
     [_imagePicker.view setFrame:CGRectMake(self.view.frame.origin.x+SCREEN_WIDTH, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
     
     [UIView commitAnimations];
     */
}

#pragma mark - ButtonClicked
- (void)rightButtonClicked:(UIButton *)sender
{

    if (_selectMainCateIndex == -1) {
        [JDStatusBarNotification showWithStatus:@"请选择类别"
                                   dismissAfter:2.0
                                      styleName:JDStatusBarStyleMatrix];
        return;
    }
    NSArray *arr = _mainCate.cateSubCates;
    if (_selectMainCateIndex>[arr count]) {
        [JDStatusBarNotification showWithStatus:@"请重新选择类别"
                                   dismissAfter:2.0
                                      styleName:JDStatusBarStyleMatrix];
        return;
    }
    THNTopicCategory *cate = [arr objectAtIndex:_selectMainCateIndex];
    NSString *title = ((JYComCustomTextField *)[self.view viewWithTag:13201]).text;
    NSString *des = ((THNTextView *)[self.view viewWithTag:13202]).text;
    NSString *tag = ((JYComCustomTextField *)[self.view viewWithTag:13203]).text;
    if (!title || [title isEqualToString:@""]) {
        [self alertWithInfo:@"请输入标题！"];
        return;
    }
    if (!des || [des isEqualToString:@""]) {
        [self alertWithInfo:@"请输入内容！"];
        return;
    }
    [self showLoadingWithAni:YES];
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     title, @"title",
                                     des,        @"description",
                                     tag,@"tags",
                                     [NSString stringWithFormat:@"%ld",cate.cateID],@"category_id",
                                     [THNUserManager sharedTHNUserManager].userid,@"current_user_id",
                                     [THNUserManager channel],                      @"channel",
                                     [THNUserManager client_id],                    @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],  @"uuid",
                                     [THNUserManager time],                         @"time",
                                     nil];
    [listPara addSign];
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiTopicUpload]];
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    [self hideLoadingWithCompletionMessage:@"提交成功！"];
    [self pageBack];
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    NSString *errorInfo = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    [self hideLoadingWithCompletionMessage:errorInfo];
}
@end
