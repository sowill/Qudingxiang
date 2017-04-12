//
//  point_questionModel.m
//  趣定向
//
//  Created by Air on 16/3/16.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "point_questionModel.h"

@implementation point_questionModel
-(instancetype)initWithQ_id:(NSString *)q_id P_mapid:(NSString *)p_mapid
{
    if (self = [super init]) {
        _question_id = q_id;
        _pointmap_id = p_mapid;
    }
    return self;
}
@end
