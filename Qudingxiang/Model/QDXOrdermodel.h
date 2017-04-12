//
//  QDXOrdermodel.h
//  趣定向
//
//  Created by Air on 16/1/20.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QDXostatus;
@class QDXpaytype;
@interface QDXOrdermodel : NSObject
/*  订单金额*/
@property (nonatomic,copy) NSString *Orders_am;
/*  订单时间*/
@property (nonatomic,copy) NSString *Orders_ct;
/*  订单编号*/
@property (nonatomic,assign) int Orders_id;
/*  订单名称*/
@property (nonatomic,copy) NSString *Orders_name;
/*  订单状态*/
@property (nonatomic,assign) int Orders_st;
/*  支付状态*/
@property (nonatomic,strong) QDXostatus *ostatus;
/*  支付类型*/
@property (nonatomic,strong) QDXpaytype *paytype;
/*  门票信息*/
@property (nonatomic,strong) NSMutableArray *TicketInfo;
/*  订单图片*/
@property (nonatomic,copy) NSString *img;
/*  订单数量*/
@property (nonatomic,assign) int quantity;
/*  活动名称*/
@property (nonatomic,copy) NSString *name;

+(instancetype)OrderWithDict:(NSDictionary *)dict;
-(instancetype)initWithDict:(NSDictionary *)dict;
@end
