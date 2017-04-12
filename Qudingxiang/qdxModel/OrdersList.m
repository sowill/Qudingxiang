

#import "OrdersList.h"

@implementation  OrdersList

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
				 _ordersArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Orders *info= [[Orders alloc]initWithDic:dict];
					 [_ordersArray addObject:info];
				}
			}
		}
		return self;
}
@end