//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface City: NSObject
@property (nonatomic,copy) NSString *city_id; //编号
@property (nonatomic,copy) NSString *city_cn; //城市
@property (nonatomic,copy) NSString *province_id; //省
@property (nonatomic,copy) NSString *province_cn;
@property (nonatomic,copy) NSString *utilstatus_id; //状态
@property (nonatomic,copy) NSString *utilstatus_cn;
-(id)initWithDic:(NSDictionary *) infoDict;
@end