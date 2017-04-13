//
//  CardList.m
//  趣定向
//
//  Created by Air on 2017/4/12.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "CardList.h"

@implementation CardList
-(id)initWithDic:(NSDictionary *) infoDict{
    if(self=[super init]){
        _count= infoDict[@"count"];
        _allpage= infoDict[@"page"];
        _curr=infoDict[@"curr"];
        NSDictionary *dicData = infoDict[@"data"];
        if([dicData isEqual:[NSNull null]]){
            NSLog(@" dicData data is null!");
        }else{
            _cardArray = [[NSMutableArray alloc] init];
            for(NSDictionary *dict in dicData){
                CardModel *info= [[CardModel alloc]initWithDic:dict];
                [_cardArray addObject:info];
            }
        }
    }
    return self;
}
@end
