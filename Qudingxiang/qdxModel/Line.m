//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Line.h"

@implementation  Line

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_line_id = infoDict[@"line_id"];
			_line_cn = infoDict[@"line_cn"];
			_linetype_id = infoDict[@"linetype_id"];
			_linetype_cn = infoDict[@"linetype"][@"linetype_cn"];
			_line_number = infoDict[@"line_number"];
			_line_pass = infoDict[@"line_pass"];
			_onoff_cn = infoDict[@"onoff"][@"onoff_cn"];
			_line_qrcode = infoDict[@"line_qrcode"];
			_onoff_cn = infoDict[@"onoff"][@"onoff_cn"];
			_line_bind = infoDict[@"line_bind"];
			_onoff_cn = infoDict[@"onoff"][@"onoff_cn"];
			_line_mapon = infoDict[@"line_mapon"];
			_onoff_cn = infoDict[@"onoff"][@"onoff_cn"];
			_line_map = infoDict[@"line_map"];
			_line_toplon = infoDict[@"line_toplon"];
			_line_toplat = infoDict[@"line_toplat"];
			_line_botlon = infoDict[@"line_botlon"];
			_line_botlat = infoDict[@"line_botlat"];
			_line_page = infoDict[@"line_page"];
			_utilstatus_id = infoDict[@"utilstatus_id"];
			_utilstatus_cn = infoDict[@"utilstatus"][@"utilstatus_cn"];
			_line_cdate = infoDict[@"line_cdate"];
			_area_id = infoDict[@"area_id"];
			_area_cn = infoDict[@"area"][@"area_cn"];
		}
		return self;
}
@end