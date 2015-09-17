//
//  THNCategory.h
//  store
//
//  Created by XiaobinJia on 14-11-11.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THNCategory : NSObject
//分类ID
@property (nonatomic, copy) NSString *cateID;
//分类名称
@property (nonatomic, copy) NSString *cateName;
//分类中文名
@property (nonatomic, copy) NSString *cateTitle;
//分类描述
@property (nonatomic, copy) NSString *cateSummary;
//分类图片
@property (nonatomic, copy) NSString *cateImage;
//分类商品数量
@property (nonatomic, assign) int cateCount;
@end
