//Created by DCode on 2017-04-05 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface Ordersinfo: NSObject
@property (nonatomic,copy) NSString *ordersinfo_id; //编号
@property (nonatomic,copy) NSString *ordersinfo_cn; //单号
@property (nonatomic,copy) NSString *orders_id; //订单
@property (nonatomic,copy) NSString *orders_cn;
@property (nonatomic,copy) NSString *ordersinfo_udate; //使用时间
@property (nonatomic,copy) NSString *ordersinfost_id; //状态
@property (nonatomic,copy) NSString *ordersinfost_cn;
@property (nonatomic,copy) NSString *customer_id; //用户
@property (nonatomic,copy) NSString *customer_cn;

@property (nonatomic,copy) NSString *qrcode;//二维码全路径
-(id)initWithDic:(NSDictionary *) infoDict;
@end