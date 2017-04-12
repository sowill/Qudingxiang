//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface Goodstype: NSObject
@property (nonatomic,copy) NSString *goodstype_id; //编号
@property (nonatomic,copy) NSString *goodstype_cn; //发布类型
-(id)initWithDic:(NSDictionary *) infoDict;
@end