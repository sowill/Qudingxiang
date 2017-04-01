//Created by DCode on 2017-03-20 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Customer.h"

@implementation  Customer

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_customer_id = infoDict[@"customer_id"];
			_customer_cn = infoDict[@"customer_cn"];
			_customer_code = infoDict[@"customer_code"];
			_customer_pwd = infoDict[@"customer_pwd"];
			_customer_token = infoDict[@"customer_token"];
			_customer_qid = infoDict[@"customer_qid"];
			_customer_wxid = infoDict[@"customer_wxid"];
			_customer_headurl = infoDict[@"customer_headurl"];
			_customer_signature = infoDict[@"customer_signature"];
			_customer_cdate = infoDict[@"customer_cdate"];
			_customer_ldate = infoDict[@"customer_ldate"];
			_customer_Ipaddress = infoDict[@"customer_Ipaddress"];
			_customer_vcode = infoDict[@"customer_vcode"];
			_customer_address = infoDict[@"customer_address"];
			_customer_level = infoDict[@"customer_level"];
			_area_id = infoDict[@"area_id"];
 
		}
		return self;
}
@end