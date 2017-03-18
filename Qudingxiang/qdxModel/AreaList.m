

#import "AreaList.h"

@implementation  AreaList

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
				 _areaArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Area *info= [[Area alloc]initWithDic:dict];
					 [_areaArray addObject:info];
				}
			}
		}
		return self;
}
@end