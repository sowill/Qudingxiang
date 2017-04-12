//Created by DCode on 2017-04-05 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Orders.h"

@implementation  Orders

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_orders_id = infoDict[@"orders_id"];
			_orders_cn = infoDict[@"orders_cn"];
			_customer_id = infoDict[@"customer_id"];
			_customer_cn = infoDict[@"customer"][@"customer_cn"];
			_goods_id = infoDict[@"goods_id"];
			_goods_cn = infoDict[@"goods"][@"goods_cn"];
            _goods_url = infoDict[@"goods"][@"goods_url"];
			_orders_cdate = infoDict[@"orders_cdate"];
			_orders_quantity = infoDict[@"orders_quantity"];
			_orders_am = infoDict[@"orders_am"];
			_orders_account = infoDict[@"orders_account"];
			_ordersst_id = infoDict[@"ordersst_id"];
			_ordersst_cn = infoDict[@"ordersst"][@"ordersst_cn"];
			_orderspay_id = infoDict[@"orderspay_id"];
			_orderspay_cn = infoDict[@"orderspay"][@"orderspay_cn"];
		}
		return self;
}
@end
