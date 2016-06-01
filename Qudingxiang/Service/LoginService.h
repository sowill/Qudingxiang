//
//  LoginService.h
//  趣定向
//
//  Created by Prince on 16/3/11.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginService : NSObject
+ (void)getAccessBlock:(void (^)(NSMutableDictionary *dict))block andWithKey:(NSString *)key andWithSecret:(NSString *)secret andWithWXCode:(NSString *)code;

+ (void)getUserInfoBlock:(void (^)(NSMutableDictionary *dict))block andWithToken:(NSString *)token andWithOpenID:(NSString *)openID;

+ (void)QQandWXlog:(void (^)(NSMutableDictionary *dict))block andWithTXOpenID:(NSString *)txID andWithWXOpenID:(NSString *)wxID;

+ (void)logInBlock:(void (^)(NSMutableDictionary *dict))block andWithUserName:(NSString *)userName
   andWithPassWord:(NSString *)passWord;
@end
