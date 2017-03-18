//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface qdxPoint: NSObject
@property (nonatomic,copy) NSString *point_id; //编号
@property (nonatomic,copy) NSString *point_cn; //点标名称
@property (nonatomic,copy) NSString *point_sn; //产品序号
@property (nonatomic,copy) NSString *area_id; //场地
@property (nonatomic,copy) NSString *area_cn;
@property (nonatomic,copy) NSString *point_lon; //经度
@property (nonatomic,copy) NSString *point_lat; //纬度
@property (nonatomic,copy) NSString *point_mac; //标签
@property (nonatomic,copy) NSString *point_qr; //二维码
@property (nonatomic,copy) NSString *point_rssi; //范围
@property (nonatomic,copy) NSString *onoff_id; //绑定
@property (nonatomic,copy) NSString *onoff_cn;
@property (nonatomic,copy) NSString *point_power; //电量
@property (nonatomic,copy) NSString *point_rdate; //检测时间
-(id)initWithDic:(NSDictionary *) infoDict;
@end
