

#import "LinetypeList.h"

@implementation  LinetypeList

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
				 _linetypeArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Linetype *info= [[Linetype alloc]initWithDic:dict];
					 [_linetypeArray addObject:info];
				}
			}
		}
		return self;
}
@end