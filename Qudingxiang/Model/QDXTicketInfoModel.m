//
//  QDXTicketInfoModel.m
//  趣定向
//
//  Created by Air on 16/1/20.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXTicketInfoModel.h"

@implementation QDXTicketInfoModel
+(instancetype)TicketInfoWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

-(instancetype)initWithDict:(NSDictionary *)dict
{
    
    if (self = [super init]) {
        self.Orders_id = [dict[@"Orders_id"] intValue];
        self.ticketinfo_name = dict[@"ticketinfo_name"];
        self.ticket_id = dict[@"ticket_id"];
        self.goods_name = dict[@"goods_name"];
        self.goods_price = dict[@"goods_price"];
        self.tstatus_id = [dict[@"tstatus_id"] intValue];
        self.tstatus_name = dict[@"tstatus_name"];
        self.act_address = dict[@"act_address"];
        self.act_time = dict[@"act_time"];
    }
    return self;
}
@end
