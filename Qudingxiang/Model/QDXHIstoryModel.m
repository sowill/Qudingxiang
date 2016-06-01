//
//  QDXHIstoryModel.m
//  趣定向
//
//  Created by Air on 16/3/15.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXHIstoryModel.h"

@implementation QDXHIstoryModel
-(instancetype) initWithEdate:(NSString *)edate Myline_id:(NSString *)myline_id Point_id:(NSString *)point_id Score:(NSString *)score
{
    if (self = [super init]) {
        _edate = edate;
        _myline_id = myline_id;
        _point_id = point_id;
        _score = score;
    }
    return self;
}
@end
