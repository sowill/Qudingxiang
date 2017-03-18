

#import "CityList.h"

@implementation  CityList

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
				 _cityArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 City *info= [[City alloc]initWithDic:dict];
					 [_cityArray addObject:info];
				}
			}
		}
		return self;
}
@end