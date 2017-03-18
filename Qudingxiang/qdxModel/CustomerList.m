

#import "CustomerList.h"

@implementation  CustomerList

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
				 _customerArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Customer *info= [[Customer alloc]initWithDic:dict];
					 [_customerArray addObject:info];
				}
			}
		}
		return self;
}
@end