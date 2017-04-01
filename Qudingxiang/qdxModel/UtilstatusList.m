

#import "UtilstatusList.h"

@implementation  UtilstatusList

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_count= infoDict[@"count"];
			_allpage= infoDict[@"page"];
			_curr=infoDict[@"curr"];
			 NSDictionary *dicData = infoDict[@"data"];
			 if([dicData isEqual:[NSNull null]]){
				 NSLog(@" dicData data is null!");
			 }else{
				 _utilstatusArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Utilstatus *info= [[Utilstatus alloc]initWithDic:dict];
					 [_utilstatusArray addObject:info];
				}
			}
		}
		return self;
}
@end
