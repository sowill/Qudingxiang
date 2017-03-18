

#import "LineList.h"

@implementation  LineList

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
				 _lineArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Line *info= [[Line alloc]initWithDic:dict];
					 [_lineArray addObject:info];
				}
			}
		}
		return self;
}
@end