//
//  THNTopicCategory.h
//  store
//
//  Created by XiaobinJia on 14-12-1.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THNTopicCategory : NSObject
- (BOOL)isMainCate;
//主题分类ID
@property (nonatomic, assign) long cateID;
//主题分类名称
@property (nonatomic, retain) NSString *cateName;
//主题分类中文名
@property (nonatomic, retain) NSString *cateTitle;
//主题分类描述
@property (nonatomic, retain) NSString *cateSummary;
//主题分类描述
@property (nonatomic, assign) long catePID;
//该分类下的主题数量
@property (nonatomic, retain) NSString *cateTopicCount;
//该分类的Icon
@property (nonatomic, retain) NSString *cateIcon;
//子分类数组
@property (nonatomic, retain) NSMutableArray *cateSubCates;
@end
