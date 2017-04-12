

#import "SysuserList.h"

@implementation  SysuserList

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
				 _sysuserArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Sysuser *info= [[Sysuser alloc]initWithDic:dict];
					 [_sysuserArray addObject:info];
				}
			}
		}
		return self;
}
@end
