//Created by DCode on 2017-03-15 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>
//#import "Province.h"
#import "City.h"
//#import "County.h"
//#import "Line.h"

@interface Utilstatus: NSObject
@property (nonatomic,copy) NSString *utilstatus_id; //编号
@property (nonatomic,copy) NSString *utilstatus_cn; //状态

-(id)initWithDic:(NSDictionary *) infoDict;
@end
