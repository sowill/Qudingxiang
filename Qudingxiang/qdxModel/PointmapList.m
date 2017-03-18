

#import "PointmapList.h"

@implementation  PointmapList

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
				 _pointmapArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Pointmap *info= [[Pointmap alloc]initWithDic:dict];
					 [_pointmapArray addObject:info];
				}
			}
		}
		return self;
}
@end