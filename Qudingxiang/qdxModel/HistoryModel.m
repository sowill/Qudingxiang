//
//  HistoryModel.m
//  趣定向
//
//  Created by Air on 2017/3/28.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HistoryModel.h"

@implementation HistoryModel

-(id)initWithDic:(NSDictionary *) infoDict{
    if(self=[super init]){
        _mylineinfo_cdate= infoDict[@"mylineinfo_cdate"];
        _mylineinfo_score= infoDict[@"mylineinfo_score"];
        _pointmap_cn = infoDict[@"pointmap_cn"];
        _pointmap_id = infoDict[@"pointmap_id"];
    }
    return self;
}

@end
