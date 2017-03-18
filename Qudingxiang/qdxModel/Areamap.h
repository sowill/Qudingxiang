//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface Areamap: NSObject
@property (nonatomic,copy) NSString *areamap_id; //编号
@property (nonatomic,copy) NSString *area_id; //场地
@property (nonatomic,copy) NSString *area_cn;
@property (nonatomic,copy) NSString *sysuser_id; //用户
@property (nonatomic,copy) NSString *sysuser_cn;
-(id)initWithDic:(NSDictionary *) infoDict;
@end