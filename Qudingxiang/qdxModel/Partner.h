//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface Partner: NSObject
@property (nonatomic,copy) NSString *partner_id; //编号
@property (nonatomic,copy) NSString *partner_cn; //合作伙伴
@property (nonatomic,copy) NSString *partner_logo; //商标
-(id)initWithDic:(NSDictionary *) infoDict;
@end