//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "County.h"

@implementation  County

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_county_id = infoDict[@"county_id"];
			_county_cn = infoDict[@"county_cn"];
			_city_id = infoDict[@"city_id"];
			_city_cn = infoDict[@"city"][@"city_cn"];
			_utilstatus_id = infoDict[@"utilstatus_id"];
			_utilstatus_cn = infoDict[@"utilstatus"][@"utilstatus_cn"];
		}
		return self;
}
@end