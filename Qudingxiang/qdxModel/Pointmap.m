//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Pointmap.h"

@implementation  Pointmap

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_pointmap_id = infoDict[@"pointmap_id"];
			_point_id = infoDict[@"point_id"];
			_point_cn = infoDict[@"point"][@"point_cn"];
			_pointmap_cn = infoDict[@"pointmap_cn"];
			_line_id = infoDict[@"line_id"];
			_line_cn = infoDict[@"line"][@"line_cn"];
			_pointmap_index = infoDict[@"pointmap_index"];
			_pointmap_team = infoDict[@"pointmap_team"];
			_onoff_cn = infoDict[@"onoff"][@"onoff_cn"];
			_pointmap_task = infoDict[@"pointmap_task"];
			_pointmap_key = infoDict[@"pointmap_key"];
			_pointmap_des = infoDict[@"pointmap_des"];
			_pointmap_pop = infoDict[@"pointmap_pop"];
			_pointmap_show = infoDict[@"pointmap_show"];
			_pointmap_score = infoDict[@"pointmap_score"];
			_pointmap_time = infoDict[@"pointmap_time"];
			_pointmap_group = infoDict[@"pointmap_group"];
			_pointmap_hascoupon = infoDict[@"pointmap_hascoupon"];
			_onoff_cn = infoDict[@"onoff"][@"onoff_cn"];
			_pointmap_coupon = infoDict[@"pointmap_coupon"];
			_pointmap_coupontime = infoDict[@"pointmap_coupontime"];
			_pointmap_istask = infoDict[@"pointmap_istask"];
			_onoff_cn = infoDict[@"onoff"][@"onoff_cn"];
		}
		return self;
}
@end