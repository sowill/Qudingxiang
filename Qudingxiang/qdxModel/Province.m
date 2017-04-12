//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Province.h"

@implementation  Province

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_province_id = infoDict[@"province_id"];
			_province_cn = infoDict[@"province_cn"];
			_utilstatus_id = infoDict[@"utilstatus_id"];
			_utilstatus_cn = infoDict[@"utilstatus"][@"utilstatus_cn"];
		}
		return self;
}
@end