//
//  JYFankuiViewController.m
//  HaojyClient
//
//  Created by Robinkey on 14-4-25.
//  Copyright (c) 2014年 JYHD. All rights reserved.
//

#import "JYFankuiViewController.h"
#import "JYComHttpRequest.h"
#import "THNUserManager.h"
#import "NSMutableDictionary+AddSign.h"
#import "JDStatusBarNotification.h"

@interface JYFankuiViewController () <JYComHttpRequestDelegate, UITextViewDelegate>
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) UITextView *contentView;
@property (nonatomic, strong) UITextView *contactView;
@property (nonatomic, strong) JYComHttpRequest *request;
@end

@implementation JYFankuiViewController
{
    JYComHttpRequest                    *_request;
}
@synthesize content, contentView, contactView, request = _request;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"意见反馈";
        self.request = [[JYComHttpRequest alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self.request clearDelegatesAndCancel];
    self.request = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0xf0f0f0);
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, [self baseY]+12, 300, 16)];
    label1.font = [UIFont systemFontOfSize:15];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = @"你的意见:";
    [self.view addSubview:label1];
    
    self.contentView = [[UITextView alloc] initWithFrame:CGRectMake(10, label1.frame.origin.y+label1.frame.size.height+6, 300, 100)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.font = [UIFont systemFontOfSize:13];
    self.contentView.delegate = self;
    self.contentView.textColor = [UIColor colorWithWhite:.6 alpha:1];
    self.contentView.text = @"";
    [self.view addSubview:self.contentView];
    
    UILabel *tvlabel = [[UILabel alloc] init];
    tvlabel.frame =CGRectMake(6, 5, 250, 20);
    tvlabel.text = @"您的每一个意见，我们都会认真倾听。";
    tvlabel.enabled = NO;//lable必须设置为不可用
    tvlabel.tag = 332890;
    tvlabel.font = [UIFont systemFontOfSize:13];
    tvlabel.textColor = [UIColor colorWithWhite:.6 alpha:1.0];
    tvlabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:tvlabel];
    
    self.contentView.layer.borderWidth = .5;
    self.contentView.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    self.contentView.layer.cornerRadius = 5;
    self.contentView.layer.masksToBounds = YES;
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, self.contentView.frame.origin.y+self.contentView.frame.size.height+6, 300, 16)];
    label2.font = [UIFont systemFontOfSize:15];
    label2.text = @"联系方式:";
    label2.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label2];
    
    self.contactView = [[UITextView alloc] initWithFrame:CGRectMake(10, label2.frame.origin.y+label2.frame.size.height+6, 300, 30)];
    self.contactView.font = [UIFont systemFontOfSize:14];
    self.contactView.delegate = self;
    self.contactView.backgroundColor = [UIColor whiteColor];
    self.contactView.textAlignment = NSTextAlignmentLeft;
    self.contactView.text = @"";
    self.contactView.textColor = [UIColor colorWithWhite:.6 alpha:1];
    [self.view addSubview:self.contactView];
    
    UILabel * tvlabel2 = [[UILabel alloc] init];
    tvlabel2.frame =CGRectMake(6, 6, 200, 20);
    tvlabel2.text = @"手机号/QQ/邮箱";
    tvlabel2.tag = 332890;
    tvlabel2.enabled = NO;//lable必须设置为不可用
    tvlabel2.font = [UIFont systemFontOfSize:13];
    tvlabel2.textColor = [UIColor colorWithWhite:.6 alpha:1.0];
    tvlabel2.backgroundColor = [UIColor clearColor];
    [self.contactView addSubview:tvlabel2];
    
    self.contactView.layer.borderWidth = .5;
    self.contactView.layer.borderColor = [[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0] CGColor];
    self.contactView.layer.cornerRadius = 5;
    self.contactView.layer.masksToBounds = YES;
    
    UILabel *qunLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,self.contactView.frame.origin.y+self.contactView.frame.size.height+12, 320, 20)];
    qunLabel.font = [UIFont systemFontOfSize:13];
    qunLabel.textColor = [UIColor colorWithWhite:.6 alpha:1.0];
    qunLabel.textAlignment = NSTextAlignmentCenter;
    qunLabel.text = @"加入太火鸟交流群：226541167";
    qunLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:qunLabel];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    sendButton.backgroundColor = [UIColor colorWithRed:1/255.f green:196/255.f blue:226/255.f alpha:1.0];
    sendButton.backgroundColor = [UIColor SecondColor];
    [sendButton setFrame:CGRectMake(160-44, qunLabel.frame.origin.y+qunLabel.frame.size.height+6, 88, 30)];
    sendButton.layer.cornerRadius = 2;
    sendButton.layer.masksToBounds = YES;
    [sendButton setTitle:@"马上提交" forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendButton];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)customBackButton
{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, [self navBaseY], 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [backBtn setTitle:@"" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(closeShare) forControlEvents:UIControlEventTouchUpInside];
    return backBtn;
}

- (void)closeShare
{
    [self dismissViewControllerAnimated:YES completion:^{
    
    }];
}

- (void)sendButtonClicked:(UIButton *)sender
{
    [self.contactView resignFirstResponder];
    [self.contentView resignFirstResponder];
    if (!self.contentView.text || [self.contentView.text isEqualToString:@""]) {
        [JDStatusBarNotification showWithStatus:@"请填写您的意见内容哦！"
                                   dismissAfter:2.0
                                      styleName:JDStatusBarStyleMatrix];
        
        return;
    }
    if (!self.contactView.text || [self.contactView.text isEqualToString:@""]) {
        [JDStatusBarNotification showWithStatus:@"请填写您的联系方式哦！"
                                   dismissAfter:2.0
                                      styleName:JDStatusBarStyleMatrix];
        
        return;
    }
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[THNUserManager sharedTHNUserManager] userid], @"current_user_id",
                                     self.contentView.text,                                  @"content",
                                     self.contactView.text,                             @"contact",
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
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiSetFeedback]];
}

#pragma mark-
#pragma mark- HttpRequest
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"%@",result);
    [JDStatusBarNotification showWithStatus:@"成功上传，客服人员会尽快联系您！"
                               dismissAfter:2.0
                                  styleName:JDStatusBarStyleMatrix];
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    JYLog(@"%@",error);
    [JDStatusBarNotification showWithStatus:@"上传失败，请检查您的网络！"
                               dismissAfter:2.0
                                  styleName:JDStatusBarStyleMatrix];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length==0) {
        if (textView == self.contentView) {
            ((UILabel *)[textView viewWithTag:332890]).text = @"  您的每一个意见，我们都会认真倾听。";
        }else{
            ((UILabel *)[textView viewWithTag:332890]).text = @"  QQ或邮箱";
        }
        
    }else{
        ((UILabel *)[textView viewWithTag:332890]).text = @"";
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView == self.contactView) {
        if ([text isEqualToString:@"\n"]) {
            [textView resignFirstResponder];
            return NO;
        }
    }
    return YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.contentView resignFirstResponder];
    [self.contactView resignFirstResponder];
}
@end
