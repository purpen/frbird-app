//
//  THNTopicDetailViewController.h
//  store
//
//  Created by XiaobinJia on 14-11-25.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THNTopic.h"
#import "NJKWebViewProgress.h"

@interface THNTopicDetailViewController : UIViewController<UIWebViewDelegate, NJKWebViewProgressDelegate>
- (id)initWithTopic:(THNTopic *)topic;

@end
