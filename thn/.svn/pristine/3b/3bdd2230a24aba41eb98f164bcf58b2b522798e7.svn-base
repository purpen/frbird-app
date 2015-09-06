//
//  THNAdModel.h
//  store
//
//  Created by XiaobinJia on 14-12-20.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THNProductBrief.h"
#import "THNTopic.h"

typedef enum : NSUInteger {
    kTHNAdTypeWeb       = 1,
    kTHNAdTypeProduct   = 2,
    kTHNAdTypeYushou    = 3,
    kTHNAdTypeTopic     = 4,
    kTHNAdTypeList      = 5
} THNAdType;

@interface THNAdModel : NSObject
@property (nonatomic, copy) NSString *adID;
@property (nonatomic, copy) NSString *adImage;
@property (nonatomic, copy) NSString *adTitle;
@property (nonatomic, copy) NSString *adSubTitle;
@property (nonatomic, copy) NSString *adWebUrl;
@property (nonatomic, assign) THNAdType adType;
@property (nonatomic, retain) THNProductBrief *product;
@property (nonatomic, retain) THNTopic *topic;
@end
