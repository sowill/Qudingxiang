

#import "ProvinceList.h"

@implementation  ProvinceList

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
				 _provinceArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Province *info= [[Province alloc]initWithDic:dict];
					 [_provinceArray addObject:info];
				}
			}
		}
		return self;
}
@end