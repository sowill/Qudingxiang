//
//  QDXGameModel.m
//  Qudingxiang
//
//  Created by Air on 15/9/29.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "QDXGameModel.h"

@implementation QDXGameModel
//- (void)setValue:(id)value forUndefinedKey:(NSString *)key
//{}
+(NSDictionary *)mj_objectClassInArray
{
    return @{
            @"teams":@"QDXTeamsModel",
            @"history":@"QDXHIstoryModel"
            };
}

-(instancetype)initWithL_id:(NSString *)line_id ML_id:(NSString *)myline_id MS_id:(NSString *)mstatus_id Sdate:(NSString *)sdate Score:(NSString *)score Isleader:(NSString *)isLeader P_mid:(NSString *)pointmap_id
{
    if (self = [super init]) {
        _line_id = line_id;
        _myline_id = myline_id;
        _mstatus_id = mstatus_id;
        _sdate = sdate;
        _score = score;
        _isLeader = isLeader;
        _pointmap_id = pointmap_id;
    }
    return self;
}

@end
