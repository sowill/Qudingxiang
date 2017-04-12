//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "qdxPoint.h"

@implementation  qdxPoint

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_point_id = infoDict[@"point_id"];
			_point_cn = infoDict[@"point_cn"];
			_point_sn = infoDict[@"point_sn"];
			_area_id = infoDict[@"area_id"];
			_area_cn = infoDict[@"area"][@"area_cn"];
			_point_lon = infoDict[@"point_lon"];
			_point_lat = infoDict[@"point_lat"];
			_point_mac = infoDict[@"point_mac"];
			_point_qr = infoDict[@"point_qr"];
			_point_rssi = infoDict[@"point_rssi"];
			_onoff_id = infoDict[@"onoff_id"];
			_onoff_cn = infoDict[@"onoff"][@"onoff_cn"];
			_point_power = infoDict[@"point_power"];
			_point_rdate = infoDict[@"point_rdate"];
		}
		return self;
}
@end
