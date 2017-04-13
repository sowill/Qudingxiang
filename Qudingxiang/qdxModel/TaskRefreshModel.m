//
//  TaskRefreshModel.m
//  趣定向
//
//  Created by Air on 2017/3/27.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "TaskRefreshModel.h"

@implementation TaskRefreshModel
-(id)initWithDic:(NSDictionary *) infoDict{
    if(self=[super init]){
        _myline_adate = infoDict[@"myline_adate"];
        _myline_id = infoDict[@"myline_id"];
        _mylinest_id = infoDict[@"mylinest_id"];
        _pointmap_cn = infoDict[@"pointmap_cn"];
        _pointmap_mac = infoDict[@"pointmap_mac"];
        _pointmap_pop = infoDict[@"pointmap_pop"];
        _pointmap_rssi = infoDict[@"pointmap_rssi"];
        _line_time = infoDict[@"line_time"];
        _linetype_id = infoDict[@"linetype_id"];
        _myline_print = infoDict[@"myline_print"];
    }
    return self;
}
@end
