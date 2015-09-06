//
//  THNSku.h
//  store
//
//  Created by XiaobinJia on 14-12-6.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum : NSUInteger {
    kTHNSkuStageSelling,
    kTHNSkuStagePre
} THNSkuStage;

@interface THNSku : NSObject
@property (nonatomic, assign) int skuID;
@property (nonatomic, copy) NSString *skuName;
@property (nonatomic, copy) NSString *skuMode;
@property (nonatomic, copy) NSString *skuPrice;
@property (nonatomic, copy) NSString *skuSummary;
@property (nonatomic, assign) int skuLimmitedCount;//限量个数
@property (nonatomic, assign) int skuSyncCount;//已购买个数
@property (nonatomic, assign) THNSkuStage skuStage;
@end
