//
//  TaskLocationModel.m
//  趣定向
//
//  Created by Air on 2017/3/27.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "TaskLocationModel.h"

@implementation TaskLocationModel
-(id)initWithDic:(NSDictionary *) infoDict{
    if(self=[super init]){
        _line_botlat = infoDict[@"line_botlat"];
        _line_botlon = infoDict[@"line_botlon"];
        _line_id = infoDict[@"line_id"];
        _line_map = infoDict[@"line_map"];
        _line_mapon = infoDict[@"line_mapon"];
        _line_toplat = infoDict[@"line_toplat"];
        _line_toplon = infoDict[@"line_toplon"];
        NSDictionary *dicData = infoDict[@"pointmap"];
        if([dicData isEqual:[NSNull null]]){
            NSLog(@" dicData data is null!");
        }else{
            _pointmapArray = [[NSMutableArray alloc] init];
            for(NSDictionary *dict in dicData){
                PointmapModel *info= [[PointmapModel alloc]initWithDic:dict];
                [_pointmapArray addObject:info];
            }
        }
    }
    return self;
}
@end
