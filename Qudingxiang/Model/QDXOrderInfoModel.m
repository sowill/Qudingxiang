//
//  QDXOrderInfoModel.m
//  趣定向
//
//  Created by Air on 16/1/21.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXOrderInfoModel.h"
#import "QDXOrdermodel.h"
@implementation QDXOrderInfoModel
+(instancetype)OrderInfoWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

-(instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.count = [dict[@"count"] intValue];
        self.curr = [dict[@"curr"] intValue];
        self.page = [dict[@"page"] intValue];
        if (dict[@"data"]) {
            self.data = [[NSMutableArray alloc] init];
            for(NSDictionary *dic in dict[@"data"]){
                [self.data addObject:[QDXOrdermodel OrderWithDict:dic]];
            }
        }
    }
    return self;
}
@end
