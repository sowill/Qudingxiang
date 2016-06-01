//
//  QDXPointModel.m
//  趣定向
//
//  Created by Air on 16/3/15.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXPointModel.h"

@implementation QDXPointModel
-(instancetype)initWithP_id:(NSString *)point_id A_id:(NSString *)area_id LAT:(NSString *)LAT LON:(NSString *)LON Label:(NSString *)label P_name:(NSString *)point_name Rssi:(NSString *)rssi
{
    if (self = [super init]) {
        _point_id = point_id;
        _area_id = area_id;
        _LAT = LAT;
        _LON = LON;
        _label = label;
        _point_name = point_name;
        _rssi = rssi;
    }
    return self;
}
@end
