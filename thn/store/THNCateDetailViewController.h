//
//  THNCateDetailViewController.h
//  store
//
//  Created by XiaobinJia on 15/9/17.
//  Copyright (c) 2015年 TaiHuoNiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THNCategory.h"

@interface THNCateDetailViewController : UIViewController
@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;
- (id)initWithCateModel:(THNCategory *)cate;
@end
