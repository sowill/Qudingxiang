

#import "PartnerList.h"

@implementation  PartnerList

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
				 _PartnerArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Partner *info= [[Partner alloc]initWithDic:dict];
					 [_PartnerArray addObject:info];
				}
			}
		}
		return self;
}
@end