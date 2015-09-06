//
//  JYSexPicker.h
//  HaojyClient
//
//  Created by Robinkey on 14-5-9.
//  Copyright (c) 2014年 JYHD. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kJYSexNone = 0,
    kJYSexMan = 1,
    kJYSexWoman = 2
}JYSexType;

@interface JYSexPicker : UIView
@property (nonatomic, assign) JYSexType sex;
@property (nonatomic, copy) CallbackBlockWithPara selectedBlock;
@end
