

#import "GoodstypeList.h"

@implementation  GoodstypeList

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
				 _goodstypeArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Goodstype *info= [[Goodstype alloc]initWithDic:dict];
					 [_goodstypeArray addObject:info];
				}
			}
		}
		return self;
}
@end