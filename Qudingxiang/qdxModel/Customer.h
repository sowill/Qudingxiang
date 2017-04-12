//Created by DCode on 2017-03-20 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface Customer: NSObject
@property (nonatomic,copy) NSString *customer_id; //编号
@property (nonatomic,copy) NSString *customer_cn; //名称
@property (nonatomic,copy) NSString *customer_code; //登录账号
@property (nonatomic,copy) NSString *customer_pwd; //登录密码
@property (nonatomic,copy) NSString *customer_token; //Token
@property (nonatomic,copy) NSString *customer_qid; //QQ授权
@property (nonatomic,copy) NSString *customer_wxid; //微信授权
@property (nonatomic,copy) NSString *customer_headurl; //头像
@property (nonatomic,copy) NSString *customer_signature; //签名
@property (nonatomic,copy) NSString *customer_cdate; //创建时间
@property (nonatomic,copy) NSString *customer_ldate; //登录时间
@property (nonatomic,copy) NSString *customer_Ipaddress; //IP地址
@property (nonatomic,copy) NSString *customer_vcode; //验证码
@property (nonatomic,copy) NSString *customer_address; //地址
@property (nonatomic,copy) NSString *customer_level; //级别
@property (nonatomic,copy) NSString *area_id; //场地
 
-(id)initWithDic:(NSDictionary *) infoDict;
@end