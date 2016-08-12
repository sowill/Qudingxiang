//
//  HomeService.h
//  趣定向
//
//  Created by Prince on 16/3/15.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeService : NSObject
+ (HomeService *)sharedInstance;
- (void)topViewDatasucceed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;
- (void)statesucceed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure WithToken:(NSString *)tokenKey;
- (void)dbversionsucceed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;
- (void)loadCellsucceed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure WithCurr:(NSString *)curr WithType:(NSString *)type ;

- (void)POST:(NSString *)URLString succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;
@end
