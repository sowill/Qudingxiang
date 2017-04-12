//Created by DCode on 2017-03-20 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "Myline.h"

@implementation  Myline

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_myline_id = infoDict[@"myline_id"];
			_line_id = infoDict[@"line_id"];
			_line_cn = infoDict[@"line"][@"line_cn"];
			_customer_id = infoDict[@"customer_id"];
			_customer_cn = infoDict[@"customer"][@"customer_cn"];
			_mylinest_id = infoDict[@"mylinest_id"];
			_mylinest_cn = infoDict[@"mylinest"][@"mylinest_cn"];
			_myline_adate = infoDict[@"myline_adate"];
			_myline_score = infoDict[@"myline_score"];
			_myline_ms = infoDict[@"myline_ms"];
			_myline_team = infoDict[@"myline_team"];
			_myline_group = infoDict[@"myline_group"];
			_myline_preview = infoDict[@"myline_preview"];
			_myline_print = infoDict[@"myline_print"];
		}
		return self;
}
@end