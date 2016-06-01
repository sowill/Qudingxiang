//
//  AlipayModel.h
//  趣定向
//
//  Created by Air on 16/1/26.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlipayModel : NSObject
@property (nonatomic, strong) NSString *partner;
@property (nonatomic, strong) NSString *privateKey;
@property (nonatomic, strong) NSString *seller;

//+(instancetype)alipayWithDict:(NSDictionary *)dict;
//-(instancetype)initWithDict:(NSDictionary *)dict;
@end
