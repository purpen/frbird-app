//
//  THNTopicsViewController.h
//  store
//
//  Created by XiaobinJia on 14-11-25.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THNTopicCategory;

@interface THNTopicsViewController : UIViewController

- (id)initWithCategory:(THNTopicCategory *)cate andMainCate:(THNTopicCategory *)mainCate;
@end
