//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface County: NSObject
@property (nonatomic,copy) NSString *county_id; //编号
@property (nonatomic,copy) NSString *county_cn; //区(县)
@property (nonatomic,copy) NSString *city_id; //城市
@property (nonatomic,copy) NSString *city_cn;
@property (nonatomic,copy) NSString *utilstatus_id; //状态
@property (nonatomic,copy) NSString *utilstatus_cn;
-(id)initWithDic:(NSDictionary *) infoDict;
@end