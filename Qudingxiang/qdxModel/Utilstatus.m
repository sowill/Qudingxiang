//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Utilstatus.h"

@implementation  Utilstatus

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_utilstatus_id = infoDict[@"utilstatus_id"];
			_utilstatus_cn = infoDict[@"utilstatus_cn"];
		}
		return self;
}
@end