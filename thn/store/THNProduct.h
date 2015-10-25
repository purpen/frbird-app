//
//  THNProduct.h
//  store
//
//  Created by XiaobinJia on 14-11-11.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THNProductBrief.h"
#import "THNDesigner.h"

@interface THNProduct : NSObject

@property (nonatomic, retain) THNProductBrief *brief;
@property (nonatomic, retain) THNDesigner *designer;
//产品描述
@property (nonatomic, copy) NSString *productSummary;
//轮播图数组
@property (nonatomic, retain) NSArray *productAdImages;
//内容介绍页
@property (nonatomic, copy) NSString *productContentURL;
/*评论*/
//数量
@property (nonatomic, copy) NSString *productCommentNum;
/*SKU*/
@property (nonatomic, retain) NSArray *skus;
/*SKU count*/
@property (nonatomic, assign) int skusCount;
/*当前用户是否收藏*/
@property (nonatomic, assign) BOOL userStore;
/*当前用户是否点赞*/
@property (nonatomic, assign) BOOL userZan;
//tag标签
@property (nonatomic, copy) NSString *productTags;
@end
