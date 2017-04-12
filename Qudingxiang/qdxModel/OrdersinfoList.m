

#import "OrdersinfoList.h"

@implementation  OrdersinfoList

-(id)initWithDic:(NSDictionary *) infoDict{
		if(self=[super init]){
            _goods_id = infoDict[@"goods_id"];
			_goods_cn= infoDict[@"goods_cn"];
			_goods_price= infoDict[@"goods_price"];
			_goods_url=infoDict[@"goods_url"];
			_goods_address=infoDict[@"goods_address"];
			_goods_time=infoDict[@"goods_time"];
			 NSDictionary *dicData = infoDict[@"data"];
			 if([dicData isEqual:[NSNull null]]){
				 NSLog(@" dicData data is null!");
			 }else{
				 _ordersinfoArray = [[NSMutableArray alloc] init];
				 for(NSDictionary *dict in dicData){
					 Ordersinfo *info= [[Ordersinfo alloc]initWithDic:dict];
					 [_ordersinfoArray addObject:info];
				}
			}
		}
		return self;
}
@end
