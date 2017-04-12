

#import "CountyList.h"

@implementation  CountyList

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_count= infoDict[@"count"];
			_allpage= infoDict[@"page"];
			_curr=infoDict[@"curr"];
			_curr=infoDict[@"curr"];
			 NSDictionary *dicData = infoDict[@"data"];
			 if([dicData isEqual:[NSNull null]]){
				 NSLog(@" dicData data is null!");
			 }else{
				 _countyArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 County *info= [[County alloc]initWithDic:dict];
					 [_countyArray addObject:info];
				}
			}
		}
		return self;
}
@end