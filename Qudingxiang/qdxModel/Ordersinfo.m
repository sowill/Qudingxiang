//Created by DCode on 2017-04-05 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Ordersinfo.h"

@implementation  Ordersinfo

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_ordersinfo_id = infoDict[@"ordersinfo_id"];
			_ordersinfo_cn = infoDict[@"ordersinfo_cn"];
			_qrcode = infoDict[@"qrcode"];
			_orders_id = infoDict[@"orders_id"];
			_orders_cn = infoDict[@"orders"][@"orders_cn"];
			_ordersinfo_udate = infoDict[@"ordersinfo_udate"];
			_ordersinfost_id = infoDict[@"ordersinfost_id"];
			_ordersinfost_cn = infoDict[@"ordersinfost"][@"ordersinfost_cn"];
			_customer_id = infoDict[@"customer_id"];
			_customer_cn = infoDict[@"customer"][@"customer_cn"];
		}
		return self;
}
@end