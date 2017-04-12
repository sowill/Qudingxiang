//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface Area: NSObject
@property (nonatomic,copy) NSString *area_id; //编号
@property (nonatomic,copy) NSString *area_cn; //名称
@property (nonatomic,copy) NSString *area_type; //类型
@property (nonatomic,copy) NSString *province_id; //省
@property (nonatomic,copy) NSString *province_cn;
@property (nonatomic,copy) NSString *city_id; //城市
@property (nonatomic,copy) NSString *city_cn;
@property (nonatomic,copy) NSString *county_id; //区(县)
@property (nonatomic,copy) NSString *county_cn;
@property (nonatomic,copy) NSString *area_url; //图片
@property (nonatomic,copy) NSString *area_vcode; //授权码
@property (nonatomic,copy) NSString *area_cdate; //创建时间
@property (nonatomic,copy) NSString *sysuser_id; //创建人
@property (nonatomic,copy) NSString *sysuser_cn;
-(id)initWithDic:(NSDictionary *) infoDict;
@end