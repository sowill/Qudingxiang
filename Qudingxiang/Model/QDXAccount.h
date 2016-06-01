//
//  QDXAccount.h
//  Qudingxiang
//
//  Created by Air on 15/9/14.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDXAccount : NSObject

/** 用户名称*/
@property (nonatomic,copy) NSString *customer_name;
/** 手机号码*/
@property (nonatomic,copy) NSString *code;
/** qq号*/
@property (nonatomic,assign) long long *qid;
/** 微信号*/
@property (nonatomic,assign) long long *wxid;
/** 密码*/
@property (nonatomic,copy) NSString *password;
/** TokenKey*/
@property (nonatomic,copy) NSString *token;


//+(instancetype)accountWithDict:(NSDictionary *)dict;
//-(instancetype)initWithDict:(NSDictionary *)dict;
@end
