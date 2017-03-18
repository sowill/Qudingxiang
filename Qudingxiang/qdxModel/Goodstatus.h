//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface Goodstatus: NSObject
@property (nonatomic,copy) NSString *goodstatus_id; //编号
@property (nonatomic,copy) NSString *goodstatus_cn; //发布状态
-(id)initWithDic:(NSDictionary *) infoDict;
@end