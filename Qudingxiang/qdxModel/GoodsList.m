

#import "GoodsList.h"

@implementation  GoodsList

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
				 _goodsArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Goods *info= [[Goods alloc]initWithDic:dict];
					 [_goodsArray addObject:info];
				}
			}
		}
		return self;
}
@end