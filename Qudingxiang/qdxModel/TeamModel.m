//
//  TeamModel.m
//  趣定向
//
//  Created by Air on 2017/3/29.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "TeamModel.h"

@implementation TeamModel
-(id)initWithDic:(NSDictionary *) infoDict{
    if(self=[super init]){
        _myline_id= infoDict[@"myline_id"];
        _team_cn= infoDict[@"team_cn"];
        _team_id = infoDict[@"team_id"];
        _team_leader = infoDict[@"team_leader"];
    }
    return self;
}
@end
