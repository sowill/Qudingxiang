//Created by DCode on 2017-04-05 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface Orders: NSObject
@property (nonatomic,copy) NSString *orders_id; //编号
@property (nonatomic,copy) NSString *orders_cn; //订单号
@property (nonatomic,copy) NSString *customer_id; //用户
@property (nonatomic,copy) NSString *customer_cn;
@property (nonatomic,copy) NSString *goods_id; //产品
@property (nonatomic,copy) NSString *goods_cn;
@property (nonatomic,copy) NSString *orders_cdate; //时间
@property (nonatomic,copy) NSString *orders_quantity; //数量
@property (nonatomic,copy) NSString *orders_am; //应付
@property (nonatomic,copy) NSString *orders_account; //实付
@property (nonatomic,copy) NSString *ordersst_id; //状态
@property (nonatomic,copy) NSString *ordersst_cn;
@property (nonatomic,copy) NSString *orderspay_id; //支付类型
@property (nonatomic,copy) NSString *orderspay_cn;
@property (nonatomic,copy) NSString *goods_url;
-(id)initWithDic:(NSDictionary *) infoDict;
@end
