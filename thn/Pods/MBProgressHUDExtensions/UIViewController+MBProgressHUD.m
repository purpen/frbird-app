/*
 *  UIViewController+MBProgressHUD.m
 *
 *  Created by Adam Duke on 10/20/11.
 *  Copyright 2011 appRenaissance, LLC. All rights reserved.
 *
 */

#import "MBProgressHUD.h"
#import "UIViewController+MBProgressHUD.h"
#import <objc/runtime.h>

/* This key is used to dynamically create an instance variable
 * within the MBProgressHUD category using objc_setAssociatedObject
 */
const char *progressHUDKey = "progressHUDKey";

/* This key is used to dynamically create an instance variable
 * within the MBProgressHUD category using objc_setAssociatedObject
 */
const char *finishedHandlerKey = "finishedHandlerKey";

@interface UIViewController (MBProgressHUD_Private)

@property (nonatomic, retain) MBProgressHUD *progressHUD;
@property (nonatomic, copy) HUDFinishedHandler finishedHandler;

@end

@implementation UIViewController (MBProgressHUD)

- (MBProgressHUD *)progressHUD
{
    MBProgressHUD *hud = objc_getAssociatedObject(self, progressHUDKey);
    if(!hud)
    {
        UIView *hudSuperView = self.view;
        hud = [[[MBProgressHUD alloc] initWithView:hudSuperView] autorelease];
        hud.dimBackground = YES;
        hud.removeFromSuperViewOnHide = YES;
        [hudSuperView addSubview:hud];
        self.progressHUD = hud;
    }
    return hud;
}

- (void)setProgressHUD:(MBProgressHUD *)progressHUD
{
    objc_setAssociatedObject(self, progressHUDKey, progressHUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HUDFinishedHandler)finishedHandler
{
    HUDFinishedHandler block = objc_getAssociatedObject(self, finishedHandlerKey);
    return block;
}

- (void)setFinishedHandler:(HUDFinishedHandler)completionBlock
{
    objc_setAssociatedObject(self, finishedHandlerKey, completionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)_showHUDWithMessage:(NSString *)message
{
    self.progressHUD.labelText = message;
    if(self.progressHUD.taskInProgress)
    {
        return;
    }
    self.progressHUD.taskInProgress = YES;
    [self.progressHUD show:YES];
}

- (void)showHUD
{
    [self _showHUDWithMessage:nil];
}

- (void)showHUDWithMessage:(NSString *)message
{
    [self _showHUDWithMessage:message];
}

- (void)hideHUD
{
    if(!self.progressHUD.taskInProgress)
    {
        return;
    }
    self.progressHUD.taskInProgress = NO;
    [self.progressHUD hide:YES];
    self.progressHUD = nil;
}

- (void)hideHUDWithCompletionMessage:(NSString *)message
{
    self.progressHUD.labelText = message;
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:1];
}

- (void)hideHUDWithCompletionMessage:(NSString *)message finishedHandler:(HUDFinishedHandler)finishedHandler
{
    self.progressHUD.delegate = self;
    self.finishedHandler = finishedHandler;
    [self hideHUDWithCompletionMessage:message];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if(self.finishedHandler)
    {
        self.finishedHandler();
        self.finishedHandler = nil;
    }
    self.progressHUD.delegate = nil;
}

- (void)alertWithInfo:(NSString *)info
{
    UIView *view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    if (!view) {
        return;
    }
    __block MBProgressHUD *alert = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:alert];
    
    //如果设置此属性则当前的view置于后台
    alert.dimBackground = NO;
    alert.mode = MBProgressHUDModeText;
    //设置对话框文字
    alert.labelText = info;
    //显示对话框
    [alert showAnimated:YES whileExecutingBlock:^{
        //对话框显示时需要执行的操作
        sleep(2.5);
    } completionBlock:^{
        //操作执行完后取消对话框
        [alert removeFromSuperview];
#if !__has_feature(objc_arc)
        [alert release];alert = nil;
#endif
        
    }];
    return;
}
@end
