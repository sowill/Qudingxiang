//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Area.h"

@implementation  Area

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_area_id = infoDict[@"area_id"];
			_area_cn = infoDict[@"area_cn"];
			_area_type = infoDict[@"area_type"];
			_province_id = infoDict[@"province_id"];
			_province_cn = infoDict[@"province"][@"province_cn"];
			_city_id = infoDict[@"city_id"];
			_city_cn = infoDict[@"city"][@"city_cn"];
			_county_id = infoDict[@"county_id"];
			_county_cn = infoDict[@"county"][@"county_cn"];
			_area_url = infoDict[@"area_url"];
			_area_vcode = infoDict[@"area_vcode"];
			_area_cdate = infoDict[@"area_cdate"];
			_sysuser_id = infoDict[@"sysuser_id"];
			_sysuser_cn = infoDict[@"sysuser"][@"sysuser_cn"];
		}
		return self;
}
@end