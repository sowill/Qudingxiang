//
//  QDXpaytype.h
//  趣定向
//
//  Created by Air on 16/1/21.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDXpaytype : NSObject
/*  支付类型*/
@property (nonatomic,assign) int paytype_id;
/*  支付类型（中）*/
@property (nonatomic,copy) NSString * paytype_name;

+(instancetype)paytypeWithDict:(NSDictionary *)dict;
-(instancetype)initWithDict:(NSDictionary *)dict;
@end
