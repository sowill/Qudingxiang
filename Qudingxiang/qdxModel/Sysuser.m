//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Sysuser.h"

@implementation  Sysuser

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_sysuser_id = infoDict[@"sysuser_id"];
			_sysuser_cn = infoDict[@"sysuser_cn"];
			_sysuser_code = infoDict[@"sysuser_code"];
			_sysuser_pwd = infoDict[@"sysuser_pwd"];
			_permission_id = infoDict[@"permission_id"];
			_permission_cn = infoDict[@"permission"][@"permission_cn"];
			_cdate = infoDict[@"cdate"];
			_ldate = infoDict[@"ldate"];
		}
		return self;
}
@end