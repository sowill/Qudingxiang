//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface Province: NSObject
@property (nonatomic,copy) NSString *province_id; //编号
@property (nonatomic,copy) NSString *province_cn; //省
@property (nonatomic,copy) NSString *utilstatus_id; //状态
@property (nonatomic,copy) NSString *utilstatus_cn;
-(id)initWithDic:(NSDictionary *) infoDict;
@end