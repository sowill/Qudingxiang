//
//  QDXOrdermodel.m
//  趣定向
//  Created by Air on 16/1/20.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXOrdermodel.h"
#import "QDXTicketInfoModel.h"
#import "QDXostatus.h"
#import "QDXpaytype.h"
@implementation QDXOrdermodel
+(instancetype)OrderWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

-(instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.Orders_am = dict[@"Orders_am"];
        self.Orders_ct = dict[@"Orders_ct"];
        self.Orders_id = [dict[@"Orders_id"] intValue];
        self.Orders_name = dict[@"Orders_name"];
        self.Orders_st = [dict[@"Orders_st"] intValue];
        self.img = dict[@"img"];
        self.quantity = [dict[@"quantity"] intValue];
        self.name = dict[@"name"];
        
        if (dict[@"TicketInfo"]) {
            self.TicketInfo = [[NSMutableArray alloc] init];
            for(NSDictionary *dic in dict[@"TicketInfo"]){
                [self.TicketInfo addObject:[QDXTicketInfoModel TicketInfoWithDict:dic]];
            }
        }
        self.ostatus = [QDXostatus ostatusWithDict:dict[@"ostatus"]];
        self.paytype = [QDXpaytype paytypeWithDict:dict[@"paytype"]];
    }
    return self;
}
@end
