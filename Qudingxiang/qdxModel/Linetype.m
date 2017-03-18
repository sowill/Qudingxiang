//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Linetype.h"

@implementation  Linetype

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_linetype_id = infoDict[@"linetype_id"];
			_linetype_cn = infoDict[@"linetype_cn"];
		}
		return self;
}
@end