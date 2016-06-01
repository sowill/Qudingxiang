//
//  zoomImage.h
//  趣定向
//
//  Created by Air on 16/2/26.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface zoomImage : NSObject
/**
 *  @brief 点击图片放大，再次点击缩小
 *  @param oldImageView 头像所在的imageView
 */
+(void)showImage:(UIImageView *)avatarImageView;
@end
