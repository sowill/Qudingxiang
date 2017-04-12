//
//  MineCellService.h
//  趣定向
//
//  Created by Mac on 16/8/12.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MineCellService : NSObject
+ (MineCellService *)sharedInstance;

- (void)cellDatasucceed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure andWithCurr:(NSString *)curr;

- (void)teamCellDatasucceed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure andWithCurr:(NSString *)curr;

@end
