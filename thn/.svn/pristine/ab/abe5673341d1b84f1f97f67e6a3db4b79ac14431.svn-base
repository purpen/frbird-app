//
//  THNCreativeViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-17.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNCreativeViewController.h"
#import "JYComCustomTextField.h"
#import "THNTextView.h"
#import "JYComHttpRequest.h"
#import "NSMutableDictionary+AddSign.h"
#import "THNUserManager.h"

@interface THNCreativeViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, JYComHttpRequestDelegate>

@end

@implementation THNCreativeViewController
{
    UIImagePickerController     *_imagePicker;
    NSMutableArray              *_picArr;
    JYComHttpRequest            *_request;
}

- (id)init
{
    if (self = [super init]) {
        _picArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"上传创意";
    
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
    tipLabel.text = @"发现生活中的创意。";
    tipLabel.textColor = UIColorFromRGB(0x6e6e6e);
    tipLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:tipLabel];
    
    JYComCustomTextField *titleTF = [[JYComCustomTextField alloc] initWithFrame:CGRectMake(15, 36, SCREEN_WIDTH-15*2, 44)];
    titleTF.placeholder = @"标题";
    titleTF.tag = 13201;
    titleTF.delegate = self;
    titleTF.textColor = UIColorFromRGB(0x656565);
    titleTF.backgroundColor = [UIColor whiteColor];
    titleTF.layer.borderWidth = .5;
    titleTF.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    titleTF.font = [UIFont systemFontOfSize:15];
    titleTF.placeholdOffSet = CGPointMake(10, .01);
    titleTF.textOffSet = CGPointMake(10, .01);
    [self.view addSubview:titleTF];
    
    THNTextView *contentBg = [[THNTextView alloc] initWithFrame:CGRectMake(15, titleTF.frame.origin.y+titleTF.frame.size.height-1, SCREEN_WIDTH-15*2, 124)];
    contentBg.backgroundColor = [UIColor whiteColor];
    contentBg.placeholder = @" 内容";
    contentBg.tag = 13201;
    contentBg.textColor = UIColorFromRGB(0x656565);
    contentBg.font = [UIFont systemFontOfSize:15];
    contentBg.layer.borderWidth = .5;
    contentBg.tag = 90199;
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
    tagTF.tag = 13201;
    tagTF.textColor = UIColorFromRGB(0x656565);
    tagTF.placeholder = @"标签";
    tagTF.delegate = self;
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
    [addButton setTitle:@"+添加图片" forState:UIControlStateNormal];
    [addButton.layer setMasksToBounds:YES];
    [addButton.layer setCornerRadius:4.0];
    addButton.layer.borderWidth = .5;
    addButton.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    [self.view addSubview:addButton];
    /*测试
    [_picArr addObject:[UIImage imageNamed:@"home_bg"]];
    [_picArr addObject:[UIImage imageNamed:@"home_bg"]];
    [_picArr addObject:[UIImage imageNamed:@"home_bg"]];
    [_picArr addObject:[UIImage imageNamed:@"home_bg"]];
    
    [self refreshPics];
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    [((UIView *)[self.view viewWithTag:90199]) removeObserver:self forKeyPath:@"contentSize"];
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

- (void)rightButtonClicked:(UIButton *)sender
{
    NSString *title = ((JYComCustomTextField *)[self.view viewWithTag:13201]).text;
    NSString *des = ((THNTextView *)[self.view viewWithTag:13202]).text;
    NSString *tag = ((JYComCustomTextField *)[self.view viewWithTag:13203]).text;
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     title, @"title",
                                     des,        @"description",
                                     tag,@"tags",
                                     @"",@"category_id",
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
    [_request getInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiTopicUpload]];
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
    JYLog(@"%f",totalHeight);
    JYLog(@"%f",SCREEN_HEIGHT);
    if (totalHeight>SCREEN_HEIGHT-64) {
        [UIView animateWithDuration:.5 animations:^{
            [((UIScrollView *)self.view) setContentOffset:CGPointMake(0, totalHeight-SCREEN_HEIGHT+64)];
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
    if ([_picArr count]<9) {
        [_picArr addObject:originalImage];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"最多加入9张图哦！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    
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

@end
