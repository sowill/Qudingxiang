

#import "GoodstatusList.h"

@implementation  GoodstatusList

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
				 _goodstatusArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Goodstatus *info= [[Goodstatus alloc]initWithDic:dict];
					 [_goodstatusArray addObject:info];
				}
			}
		}
		return self;
}
@end