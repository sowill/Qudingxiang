//
//  UpdateService.h
//  趣定向
//
//  Created by Prince on 16/4/22.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateService : NSObject
+ (void)netDataBlock:(void (^)(NSString *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithUrl:(NSString *)url andData:(NSData *)data andfileName:(NSString *)fileName;

@end
