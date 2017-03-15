//Created by DCode on 2017-03-15 .
//Copyright © 2017 Shallvi. All rights reserved.  
#import "CityList.h"
#import "City.h"

@implementation  CityList

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
			_count = infoDict[@"count"];
			_allpage = infoDict[@"allpage"];
			_curr = infoDict[@"curr"];
			 
			NSDictionary *dicCity = infoDict[@"data"];
			if([dicCity isEqual:[NSNull null]]){
				NSLog(@" county data is null!");
			}else{
				_cityArray = [[NSMutableArray alloc] init];
				for(NSDictionary *dict in dicCity){

					City *info= [City cityWithDic:dict];

					[_cityArray addObject:info];
				}
			}
			 
		}
		return self;
}
@end
