//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Goods.h"

@implementation  Goods

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_goods_id = infoDict[@"goods_id"];
			_goods_cn = infoDict[@"goods_cn"];
			_goods_index = infoDict[@"goods_index"];
			_goods_topshow = infoDict[@"goods_topshow"];
			_onoff_cn = infoDict[@"onoff"][@"onoff_cn"];
			_goodstatus_id = infoDict[@"goodstatus_id"];
			_goodstatus_cn = infoDict[@"goodstatus"][@"goodstatus_cn"];
			_goods_price = infoDict[@"goods_price"];
			_goods_url = infoDict[@"goods_url"];
			_goods_flag = infoDict[@"goods_flag"];
			_onoff_cn = infoDict[@"onoff"][@"onoff_cn"];
			_goods_des = infoDict[@"goods_des"];
			_goods_notice = infoDict[@"goods_notice"];
			_goods_prompt = infoDict[@"goods_prompt"];
			_goods_time = infoDict[@"goods_time"];
			_goods_address = infoDict[@"goods_address"];
			_line_id = infoDict[@"line_id"];
			_line_cn = infoDict[@"line"][@"line_cn"];
			_goods_preview = infoDict[@"goods_preview"];
			_goods_cdate = infoDict[@"goods_cdate"];
			_goodstype_id = infoDict[@"goodstype_id"];
			_goodstype_cn = infoDict[@"goodstype"][@"goodstype_cn"];
		}
		return self;
}
@end