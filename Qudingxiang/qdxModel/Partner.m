//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Partner.h"

@implementation  Partner

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_partner_id = infoDict[@"partner_id"];
			_partner_cn = infoDict[@"partner_cn"];
			_partner_logo = infoDict[@"partner_logo"];
		}
		return self;
}
@end