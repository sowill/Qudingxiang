//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Goodstatus.h"

@implementation  Goodstatus

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_goodstatus_id = infoDict[@"goodstatus_id"];
			_goodstatus_cn = infoDict[@"goodstatus_cn"];
		}
		return self;
}
@end