//
//  THNProductBrief.h
//  store
//
//  Created by XiaobinJia on 14-11-30.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kTHNProductStageSelling,
    kTHNProductStagePre
} THNProductStage;

@interface THNProductBrief : NSObject
//本地数据库中的主键顺序
@property (nonatomic, assign) int *productKey;
//商品状态
@property (nonatomic, assign) THNProductStage productStage;
//是否是试用商品
@property (nonatomic, assign) BOOL productIsTry;
//抢购
@property (nonatomic, assign) BOOL productIsSnatched;
//产品封面图
@property (nonatomic, copy) NSString *productImage;
//产品ID
@property (nonatomic, copy) NSString *productID;
//产品标题
@property (nonatomic, copy) NSString *productTitle;
//产品优势
@property (nonatomic, copy) NSString *productAdvantage;
//产品售价
@property (nonatomic, copy) NSString *productSalePrice;
//预售金额
@property (nonatomic, copy) NSString *productPreSaleMoney;
//产品市场价
@property (nonatomic, copy) NSString *productMarketPrice;
//支持人数
@property (nonatomic, copy) NSString *productPresagePeople;
//开始时间
@property (nonatomic, copy) NSString *productPresageStartTime;
//结束时间
@property (nonatomic, copy) NSString *productPresageFinishedTime;
//进度
@property (nonatomic, copy) NSString *productPresagePercent;
//话题数量
@property (nonatomic, copy) NSString *productTopicCount;
//是否已售完
@property (nonatomic, assign) BOOL productCanSaled;

/*暂不使用
//评论总结
@property (nonatomic, retain) NSString *productSummary;
//价格
@property (nonatomic, retain) NSString *productPrice;
// 数量
@property (nonatomic, retain) NSString *productCount;
//评论数量
@property (nonatomic, retain) NSString *productCommentCount;
//评论星级
@property (nonatomic, retain) NSString *productCommentStar;
 */
@end
