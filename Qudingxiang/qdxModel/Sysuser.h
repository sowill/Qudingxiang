//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface Sysuser: NSObject
@property (nonatomic,copy) NSString *sysuser_id; //编号
@property (nonatomic,copy) NSString *sysuser_cn; //名称
@property (nonatomic,copy) NSString *sysuser_code; //登录账户
@property (nonatomic,copy) NSString *sysuser_pwd; //登录密码
@property (nonatomic,copy) NSString *permission_id; //权限
@property (nonatomic,copy) NSString *permission_cn;
@property (nonatomic,copy) NSString *cdate; //创建时间
@property (nonatomic,copy) NSString *ldate; //登录时间
-(id)initWithDic:(NSDictionary *) infoDict;
@end