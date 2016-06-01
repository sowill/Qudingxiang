//
//  QDXpaytype.m
//  趣定向
//
//  Created by Air on 16/1/21.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXpaytype.h"

@implementation QDXpaytype
+(instancetype)paytypeWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

-(instancetype)initWithDict:(NSDictionary *)dict
{
    
    if (self = [super init]) {
        self.paytype_id = [dict[@"paytype_id"] intValue];
        self.paytype_name = dict[@"paytype_name"];
    }
    return self;
}
@end
