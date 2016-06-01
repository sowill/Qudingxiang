//
//  QDXostatus.h
//  趣定向
//
//  Created by Air on 16/1/21.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDXostatus : NSObject
/*  订单状态（中）*/
@property (nonatomic,copy) NSString * ostatus_name;

+(instancetype)ostatusWithDict:(NSDictionary *)dict;
-(instancetype)initWithDict:(NSDictionary *)dict;
@end
