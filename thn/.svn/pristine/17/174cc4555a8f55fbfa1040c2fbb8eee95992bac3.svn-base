//
//  JYShareViewController.m
//  HaojyClient
//
//  Created by byj on 14-5-9.
//  Copyright (c) 2014年 JYHD. All rights reserved.
//

#import "JYShareViewController.h"
#import "ShareEngine.h"
#import "WXApiObject.h"
#import "XYAlertView.h"
#import "LXActionSheet.h"
#import "JDStatusBarNotification.h"


#define SINASHEET_TAG 1000
#define TCSHEET_TAG 1001

@interface JYShareViewController ()<ShareEngineDelegate,LXActionSheetDelegate>
{
    UITextView *shareTextView;
    BOOL _statusBarHiden;
}
@end

@implementation JYShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"分享";
    }
    return self;
}

- (CGFloat)addShareAppView:(UIView *)bgView{
    CGRect iconImageFrame;
    CGRect shareTextFrame;
    iconImageFrame = CGRectMake(10, 10, self.shareImage.size.width/2,self.shareImage.size.height/2);
    CGFloat shareTextX = iconImageFrame.origin.x+iconImageFrame.size.width+10;
    
    shareTextFrame = CGRectMake(shareTextX, iconImageFrame.origin.y, bgView.frame.size.width-10-shareTextX, 87);
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:iconImageFrame];
    iconImageView.image = self.shareImage;
    iconImageView.layer.cornerRadius = 8;
    iconImageView.layer.masksToBounds = YES;
    [bgView addSubview:iconImageView];
    
    shareTextView = [[UITextView alloc] initWithFrame:shareTextFrame];
    shareTextView.backgroundColor = [UIColor clearColor];
    shareTextView.textColor = [UIColor colorWithRed:87/255.f green:87/255.f blue:87/255.f alpha:1.0];
    shareTextView.text = [NSString stringWithFormat:@"%@ %@",self.shareContent,self.shareUrl];
    [bgView addSubview:shareTextView];
    
    CGFloat frameHight = (iconImageView.frame.size.height>shareTextView.frame.size.height)?iconImageView.frame.size.height:shareTextView.frame.size.height;
    
    CGFloat basicHight = 10 + frameHight + 10;
    return basicHight;
}

- (CGFloat)addShareContentView:(UIView *)bgView{
    CGRect iconImageFrame;
    CGRect shareTextFrame;
    iconImageFrame = CGRectZero;
    shareTextFrame = CGRectMake(10, 10, bgView.frame.size.width - 10*2,100);
    
    shareTextView = [[UITextView alloc] initWithFrame:shareTextFrame];
    shareTextView.backgroundColor = [UIColor clearColor];
    shareTextView.textColor = [UIColor colorWithRed:87/255.f green:87/255.f blue:87/255.f alpha:1.0];
    shareTextView.text = [NSString stringWithFormat:@"%@ %@",self.shareContent,self.shareUrl];
    [bgView addSubview:shareTextView];
    CGFloat basicHight = shareTextView.frame.origin.y + shareTextView.frame.size.height+10;
    return basicHight;
}

- (CGFloat)addShareOtherView:(UIView *)bgView{
    //默认尺寸58*45
    CGFloat scaleX = self.shareImage.size.width/58;
    CGFloat scaleY = self.shareImage.size.height/45;
    CGFloat scale = MAX(scaleX, scaleY);
    scale = (scale<1)?1:scale;
    CGFloat width = self.shareImage.size.width/scale;
    CGFloat height = self.shareImage.size.height/scale;
    CGRect iconImageFrame;
    CGRect shareTextFrame;
    iconImageFrame = CGRectMake(300-width-10, 10,width,height);
    shareTextFrame = CGRectMake(10, 10, bgView.frame.size.width - 10 -10 -10 - iconImageFrame.size.width, (height<57)?57:height);
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:iconImageFrame];
    iconImageView.image = self.shareImage;
    [bgView addSubview:iconImageView];
    
    shareTextView = [[UITextView alloc] initWithFrame:shareTextFrame];
    shareTextView.backgroundColor = [UIColor clearColor];
    shareTextView.textColor = [UIColor colorWithRed:87/255.f green:87/255.f blue:87/255.f alpha:1.0];
    shareTextView.text = [NSString stringWithFormat:@"%@ %@",self.shareContent,self.shareUrl];
    [bgView addSubview:shareTextView];
    
    CGFloat frameheight = (iconImageView.frame.size.height>shareTextView.frame.size.height)?iconImageView.frame.size.height:shareTextView.frame.size.height;
    
    CGFloat basicHight = 10 + frameheight + 10;
    return basicHight;
}

- (void)loadView{
    [super loadView];
    _statusBarHiden = [UIApplication sharedApplication].statusBarHidden;
    if (!IOS7_OR_LATER) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1.0];
    CGRect shareFrame = CGRectMake(10, 10+[self baseY], 300, 130);
    
    UIScrollView *bgScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    bgScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgScrollView];
    
    UIView *shareView = [[UIView alloc] initWithFrame:shareFrame];
    shareView.layer.cornerRadius = 6;
    shareView.layer.masksToBounds = YES;
    shareView.layer.borderColor = [UIColor colorWithRed:203/255.f green:203/255.f blue:203/255.f alpha:1.0].CGColor;
    shareView.backgroundColor = [UIColor whiteColor];
    [bgScrollView addSubview:shareView];
    
    CGFloat shareIconBgY = 0;
    if (shareTypeApp == self.shareType) {
        shareIconBgY = [self addShareAppView:shareView];
    }else if (shareTypeContent == self.shareType){
        shareIconBgY = [self addShareContentView:shareView];
    }else if (shareTypeOther == self.shareType){
        shareIconBgY = [self addShareOtherView:shareView];
    }
    
    UIView *shareIconBgView = [[UIView alloc] initWithFrame:CGRectMake(0, shareIconBgY, shareView.frame.size.width, 55)];
    shareIconBgView.backgroundColor = [UIColor colorWithRed:234/255.f green:234/255.f blue:234/255.f alpha:1.0];
    [shareView addSubview:shareIconBgView];
    
    UILabel *shareSinglabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 75, 55)];
    shareSinglabel.textColor = [UIColor colorWithRed:37/255.f green:37/255.f blue:37/255.f alpha:1.0];
    shareSinglabel.backgroundColor = [UIColor clearColor];
    shareSinglabel.textAlignment = NSTextAlignmentCenter;
    shareSinglabel.text = [NSString stringWithFormat:@"分享到"];
    [shareIconBgView addSubview:shareSinglabel];
    
    NSArray *sharIconImageNaems = [NSArray arrayWithObjects:@"share_sina.png", @"share_weixin.png", @"wechat_timeline.png",nil];
    
    CGRect frame = CGRectMake(75, 10, 35, 35);
    for (int i = 0; i < 3; i++) {
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareBtn setFrame:CGRectOffset(frame, 55*i, 0)];
        [shareBtn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        shareBtn.tag = 1000 * (i+1);
//        shareBtn.backgroundColor = [UIColor RandomColor];
        [shareBtn setBackgroundImage:[UIImage imageNamed:[sharIconImageNaems objectAtIndex:i]] forState:UIControlStateNormal];
        shareBtn.layer.cornerRadius = 4;
        shareBtn.layer.masksToBounds = YES;
        [shareIconBgView addSubview:shareBtn];
    }
    
    shareFrame.size.height = shareIconBgView.frame.origin.y + shareIconBgView.frame.size.height;
    shareView.frame = shareFrame;
    bgScrollView.contentSize = CGSizeMake(0, shareView.frame.origin.y+shareView.frame.size.height);
    
    [self.view bringSubviewToFront:self.navigationBarView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
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

- (void)closeShare{
    [UIApplication sharedApplication].statusBarHidden = _statusBarHiden;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)share:(UIButton *)sender{
    [shareTextView resignFirstResponder];
    [ShareEngine sharedInstance].delegate = self;
    switch (sender.tag) {
        case 1000:
        {
            if (NO == [[ShareEngine sharedInstance] isLogin:sinaWeibo])
            {
                [[ShareEngine sharedInstance] loginWithType:sinaWeibo];
            }
            else
            {
                LXActionSheet *sendSheet = [[LXActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"发送到新浪微博" otherButtonTitles:@[@"取消授权"]];
                sendSheet.tag = SINASHEET_TAG;
                [sendSheet showInView:self.view];
            }
        }
            break;
        case 2000:
        {
            [[ShareEngine sharedInstance] sendWeChatMessage:self.shareContent WithUrl:self.shareUrl image:self.shareImage WithType:weChat];
        }
            break;
        case 3000:
        {
            [[ShareEngine sharedInstance] sendWeChatMessage:self.shareContent WithUrl:self.shareUrl image:self.shareImage WithType:weChatFriend];
        }
            break;
        default:
            break;
    }
}
#pragma mark - aciontSheetDelegate
- (void)actionSheet:(LXActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (SINASHEET_TAG == actionSheet.tag)
    {
        if (0 == buttonIndex)
        {
            [[ShareEngine sharedInstance] sendShareMessage:shareTextView.text andImage:self.shareImage WithType:sinaWeibo];
        }
        else if (1 == buttonIndex)
        {
            [[ShareEngine sharedInstance] logOutWithType:sinaWeibo];
        }
    }
}

#pragma mark - shareEngineDelegate
- (void)shareEngineDidLogIn:(WeiboType)weibotype
{
    if (weibotype == sinaWeibo) {
        LXActionSheet *sendSheet = [[LXActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"发送到新浪微博" otherButtonTitles:@[@"取消授权"]];
        sendSheet.tag = SINASHEET_TAG;
        [sendSheet showInView:self.view];
    }
}

- (void)shareEngineDidLogOut:(WeiboType)weibotype
{
    XYAlertView *alertView = [XYAlertView alertViewWithTitle:@"提示!"
                                                     message:@"取消授权成功！"
                                                     buttons:[NSArray arrayWithObjects:@"确定", nil]
                                                afterDismiss:^(int buttonIndex) {
                                                }];
    [alertView setButtonStyle:XYButtonStyleGray atIndex:1];
    [alertView show];
}

- (void)shareEngineSendSuccess
{
    [JDStatusBarNotification showWithStatus:@"信息分享成功"
                               dismissAfter:2.0
                                  styleName:JDStatusBarStyleMatrix];
    return;
}

- (void)shareEngineSendFail:(NSError *)error
{
    NSString *failDescription = @"请重试！";
    if (20019 == error.code)
    {
        failDescription = @"重复发送了相同的内容！";
    }
    
    [JDStatusBarNotification showWithStatus:failDescription
                               dismissAfter:2.0
                                  styleName:JDStatusBarStyleMatrix];
    return;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
