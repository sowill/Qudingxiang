//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Areamap.h"

@implementation  Areamap

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_areamap_id = infoDict[@"areamap_id"];
			_area_id = infoDict[@"area_id"];
			_area_cn = infoDict[@"area"][@"area_cn"];
			_sysuser_id = infoDict[@"sysuser_id"];
			_sysuser_cn = infoDict[@"sysuser"][@"sysuser_cn"];
		}
		return self;
}
@end