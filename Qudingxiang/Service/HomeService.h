//
//  HomeService.h
//  趣定向
//
//  Created by Prince on 16/3/15.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeService : NSObject
+ (void)topViewDataBlock:(void (^)(NSDictionary *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithToken:(NSString *)tokenKey;

+ (void)btnStateBlock:(void (^)(NSMutableDictionary *dict))block andWithToken:(NSString *)tokenKey;

+ (void)choiceLineStateBlock:(void (^)(NSMutableDictionary *dict))block andWithToken:(NSString *)tokenKey;

+ (void)cellDataBlock:(void (^)(NSDictionary *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithToken:(NSString *)tokenKey andWithCurr:(NSString *)curr andWithType:(NSString *)type;

+ (void)btnTabStateBlock:(void (^)(NSMutableDictionary *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithToken:(NSString *)tokenKey;

+ (void)dbversionBlock:(void (^)(void))block;
 
@end
