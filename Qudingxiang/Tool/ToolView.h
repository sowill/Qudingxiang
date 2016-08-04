//
//  ToolView.h
//  Qudingxiang
//
//  Created by Mac on 15/9/16.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  <CommonCrypto/CommonDigest.h>
@interface ToolView : NSObject
//创建图片视图
+ (UIImageView *)createImageWithFrame:(CGRect)frame;
//创建标签
+ (UILabel *)createLabelWithFrame:(CGRect)frame text:(NSString *)text font:(CGFloat)fontSize superView:(UIView *)superView;
//创建按钮
+ (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title backGroundImage:(NSString *)image Target:(id)target action:(SEL)action superView:(UIView *)superView;
+ (UIButton *)createNavitonButtonWith:(UIView *)superView Target:(id)target action:(SEL)action image:(NSString *)imageName;
//UICOLOR转UIIMAGE
+ (UIImage *)createImageWithColor:(UIColor *)color;
//设置图片透明度
+ (UIImage *)imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*)image;
//秒数转时间
+ (NSString *)scoreTransfer:(NSString *)score;
//图片拉伸
+(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size;
//MD5
+ (NSString *)md5:(NSString *)str;
@end
