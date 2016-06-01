//
//  line_pointModel.m
//  趣定向
//
//  Created by Air on 16/3/22.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "line_pointModel.h"

@implementation line_pointModel
-(instancetype)initWithL_id:(NSString *)line_id P_id:(NSString *)point_id P_mapid:(NSString *)pointmap_id P_mapdes:(NSString *)pointmap_des P_index:(NSString *)pindex
{
    if (self = [super init]) {
        _line_id = line_id;
        _point_id = point_id;
        _pointmap_id = pointmap_id;
        _pointmap_des = pointmap_des;
        _pindex = pindex;
    }
    return self;
}
@end
