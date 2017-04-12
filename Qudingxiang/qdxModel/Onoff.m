//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Onoff.h"

@implementation  Onoff

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_onoff_id = infoDict[@"onoff_id"];
			_onoff_cn = infoDict[@"onoff_cn"];
		}
		return self;
}
@end