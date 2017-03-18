//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface Linetype: NSObject
@property (nonatomic,copy) NSString *linetype_id; //编号
@property (nonatomic,copy) NSString *linetype_cn; //线路类型
-(id)initWithDic:(NSDictionary *) infoDict;
@end