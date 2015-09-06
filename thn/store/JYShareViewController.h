//
//  JYShareViewController.h
//  HaojyClient
//
//  Created by byj on 14-5-9.
//  Copyright (c) 2014年 JYHD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JYBaseViewController.h"

typedef enum{
    shareTypeApp,
    shareTypeContent,
    shareTypeOther
}shareType;

@interface JYShareViewController : JYBaseViewController

@property (strong, nonatomic) UIImage *shareImage;
@property (strong, nonatomic) NSString *shareUrl;
@property (strong, nonatomic) NSString *shareContent;

@property (assign, nonatomic) shareType shareType;
@end
