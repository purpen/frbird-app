//
//  THNWebViewController.h
//  store
//
//  Created by XiaobinJia on 14/12/31.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"

@interface THNWebViewController : UIViewController<UIWebViewDelegate, NJKWebViewProgressDelegate>
@property (nonatomic, retain) NSString *requestUrl;
@property (nonatomic, assign) BOOL isPush;

- (id)initWithUrl:(NSString *)url;

@end
