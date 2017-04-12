//
//  TeamList.m
//  趣定向
//
//  Created by Air on 2017/3/29.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "TeamList.h"

@implementation TeamList

-(id)initWithDic:(NSDictionary *) infoDict{
    if(self=[super init]){
        _Code= infoDict[@"Code"];
        _myline_team = infoDict[@"myline_team"];
        NSDictionary *dicData = infoDict[@"Msg"];
        NSLog(@"%@",dicData);
        if([dicData isEqual:[NSNull null]]){
            NSLog(@" dicData data is null!");
        }else{
            _teamArray = [[NSMutableArray alloc] init];
            for(NSDictionary *dict in dicData){
                TeamModel *info= [[TeamModel alloc]initWithDic:dict];
                [_teamArray addObject:info];
            }
        }
    }
    return self;
}

@end
