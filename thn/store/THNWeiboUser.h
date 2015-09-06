//
//  THNWeiboUser.h
//  store
//
//  Created by XiaobinJia on 14-12-4.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THNWeiboUser : NSObject
@property (nonatomic, assign) WeiboType weiboType;
@property (nonatomic, copy) NSString *weiboUserID;
@property (nonatomic, copy) NSString *weiboUserAccessToken;

@property (nonatomic, copy) NSString *weiboUserExDate;
@property (nonatomic, copy) NSString *weiboUserName;
@property (nonatomic, copy) NSString *weiboUserAvatar;
@property (nonatomic, copy) NSString *weiboUserRefrehToken;
@end
