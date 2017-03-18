//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface Onoff: NSObject
@property (nonatomic,copy) NSString *onoff_id; //编号
@property (nonatomic,copy) NSString *onoff_cn; //是否
-(id)initWithDic:(NSDictionary *) infoDict;
@end