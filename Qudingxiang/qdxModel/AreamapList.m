

#import "AreamapList.h"

@implementation  AreamapList

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
				 _areamapArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Areamap *info= [[Areamap alloc]initWithDic:dict];
					 [_areamapArray addObject:info];
				}
			}
		}
		return self;
}
@end