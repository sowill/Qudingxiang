

#import <Foundation/Foundation.h>

#import "Ordersinfo.h"

@interface OrdersinfoList: NSObject
@property (nonatomic,copy) NSString *goods_id; //id
@property (nonatomic,copy) NSString *goods_cn; //名称
@property (nonatomic,copy) NSString *goods_price; //价格
@property (nonatomic,copy) NSString *goods_url; //产品图片
@property (nonatomic,copy) NSString *goods_address; //活动地址
@property (nonatomic,copy) NSString *goods_time;//活动时间
@property (nonatomic,strong) NSMutableArray *ordersinfoArray;//列表
-(id)initWithDic:(NSDictionary *) infoDict;
@end
