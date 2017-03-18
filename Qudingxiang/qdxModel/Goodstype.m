//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Goodstype.h"

@implementation  Goodstype

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_goodstype_id = infoDict[@"goodstype_id"];
			_goodstype_cn = infoDict[@"goodstype_cn"];
		}
		return self;
}
@end