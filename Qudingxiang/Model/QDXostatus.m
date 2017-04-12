//
//  QDXostatus.m
//  趣定向
//
//  Created by Air on 16/1/21.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXostatus.h"

@implementation QDXostatus
+(instancetype)ostatusWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

-(instancetype)initWithDict:(NSDictionary *)dict
{
    
    if (self = [super init]) {
        self.ostatus_name = dict[@"ostatus_name"];
    }
    return self;
}
@end
