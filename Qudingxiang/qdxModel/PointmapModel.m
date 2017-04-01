//
//  PointmapModel.m
//  趣定向
//
//  Created by Air on 2017/3/27.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "PointmapModel.h"

@implementation PointmapModel
-(id)initWithDic:(NSDictionary *) infoDict{
    if(self=[super init]){
        _point_lat = infoDict[@"point_lat"];
        _point_lon = infoDict[@"point_lon"];
        _pointmap_cn = infoDict[@"pointmap_cn"];
    }
    return self;
}
@end
