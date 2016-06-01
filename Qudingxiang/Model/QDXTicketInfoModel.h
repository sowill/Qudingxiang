//
//  QDXTicketInfoModel.h
//  趣定向
//
//  Created by Air on 16/1/20.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDXTicketInfoModel : NSObject
/*  订单编号*/
@property (nonatomic,assign) int Orders_id;
/*  门票名称*/
@property (nonatomic,copy) NSString *ticketinfo_name;
/*  门票id*/
@property (nonatomic,copy) NSString *ticket_id;
/*  门票状态*/
@property (nonatomic,assign) int tstatus_id;
/**
 *  门票状态
 */
@property (nonatomic,copy) NSString *tstatus_name;
/**
 *  活动名称
 */
@property (nonatomic,copy) NSString *goods_name;
/**
 *  活动价格
 */
@property (nonatomic,copy) NSString *goods_price;

+(instancetype)TicketInfoWithDict:(NSDictionary *)dict;
-(instancetype)initWithDict:(NSDictionary *)dict;
@end
