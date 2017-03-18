

#import "OnoffList.h"

@implementation  OnoffList

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
				 _onoffArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Onoff *info= [[Onoff alloc]initWithDic:dict];
					 [_onoffArray addObject:info];
				}
			}
		}
		return self;
}
@end