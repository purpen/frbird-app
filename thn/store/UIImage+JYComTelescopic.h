//
//  UIImage+JYComTelescopic.h
//  zyhz_ios_sdk_demo
//
//  Created by Xiaobin Jia on 7/2/13.
//  Copyright (c) 2013 Xiaobin Jia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (JYComTelescopic)
/*
 * @fun 按比例伸缩图片大小
 * @para size要伸缩的尺寸
 */
- (UIImage *)TelescopicImageToSize:(CGSize) size;
/*
 * @fun 旋转图片
 * @para aImage:旋转的UIImage对象
 */
+(UIImage *)rotateImage:(UIImage *)aImage;
/*
 * @fun 按尺寸裁剪图片
 * @para size:要裁减的尺寸
 */
- (UIImage *)CutImageToSize:(CGSize) size;
@end
