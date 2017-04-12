//
//  QDXAreaModel.h
//  趣定向
//
//  Created by Air on 16/3/15.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDXAreaModel : NSObject
/**
 *  场地ID
 */
@property (copy,nonatomic) NSString *area_id;
/**
 *  场地名称
 */
@property (copy,nonatomic) NSString *area_name;
/**
 *  场地缩略图
 */
@property (copy,nonatomic) NSString *url;
/**
 *  场地地图
 */
@property (copy,nonatomic) NSString *map;
/**
 *  举办/开始时间
 */
@property (copy,nonatomic) NSString *cdate;
@end
