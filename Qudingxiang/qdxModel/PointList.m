

#import "PointList.h"

@implementation  PointList

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
				 _pointArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 qdxPoint *info= [[qdxPoint alloc]initWithDic:dict];
					 [_pointArray addObject:info];
				}
			}
		}
		return self;
}
@end
