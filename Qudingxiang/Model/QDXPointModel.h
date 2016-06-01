//
//  QDXPointModel.h
//  趣定向
//
//  Created by Air on 16/3/15.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QDXAreaModel;

@interface QDXPointModel : NSObject
/**
 *  纬度
 */
@property (copy,nonatomic) NSString *LAT;
/**
 *  经度
 */
@property (copy,nonatomic) NSString *LON;
/**
 *  场地ID
 */
@property (copy,nonatomic) NSString *area_id;
/**
 *  点标的二维码，蓝牙
 */
@property (copy,nonatomic) NSString *label;
/**
 *  点标ID
 */
@property (copy,nonatomic) NSString *point_id;
/**
 *  点标名称
 */
@property (copy,nonatomic) NSString *point_name;
/**
 *  当前点标信号强度
 */
@property (copy,nonatomic) NSString *rssi;
/**
 *  线路
 */
@property (strong,nonatomic) QDXAreaModel *area;

-(instancetype)initWithP_id:(NSString *)point_id
                       A_id:(NSString *)area_id
                       LAT:(NSString *)LAT
                       LON:(NSString *)LON
                       Label:(NSString *)label
                       P_name:(NSString *)point_name
                       Rssi:(NSString *)rssi;
@end
