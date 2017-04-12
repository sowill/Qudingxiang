

#import "MylineList.h"

@implementation  MylineList

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
            
            _count= infoDict[@"count"];
			_allpage= infoDict[@"page"];
			_curr=infoDict[@"curr"];

			 NSDictionary *dicData = infoDict[@"data"];
			 if([dicData isEqual:[NSNull null]]){
				 NSLog(@" dicData data is null!");
			 }else{
				 _mylineArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Myline *info= [[Myline alloc]initWithDic:dict];
					 [_mylineArray addObject:info];
				}
			}
		}
		return self;
}
@end
