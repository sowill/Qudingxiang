//
//  HistoryList.m
//  趣定向
//
//  Created by Air on 2017/3/28.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HistoryList.h"

@implementation HistoryList

-(id)initWithDic:(NSDictionary *) infoDict{
    if(self=[super init]){
        _Code= infoDict[@"count"];
        NSDictionary *dicData = infoDict[@"Msg"];
        if([dicData isEqual:[NSNull null]]){
            NSLog(@" dicData data is null!");
        }else{
            _historyArray = [[NSMutableArray alloc] init];
            for(NSDictionary *dict in dicData){
                HistoryModel *info= [[HistoryModel alloc]initWithDic:dict];
                [_historyArray addObject:info];
            }
        }
    }
    return self;
}

@end
