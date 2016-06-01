//
//  BaseService.h
//  趣定向
//
//  Created by Prince on 16/4/22.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseService : NSObject
+ (void)netDataBlock:(void (^)(NSMutableDictionary *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithUrl:(NSString *)url andParams:(NSMutableDictionary *)params;
@end
