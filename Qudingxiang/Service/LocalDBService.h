//
//  LocalDBService.h
//  趣定向
//
//  Created by Air on 16/8/2.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LocalDBService : NSObject

+ (void)LoadDb:(void (^)(NSDictionary *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithLine:(NSString *)line_id andWithMyline:(NSString *)Myline_id;
+ (NSDictionary *)CheckTask:(NSDictionary *)param;
+ (NSDictionary *)ReadMyline:(NSString *)Myline_id;
+ (void)WriteMyline:(NSDictionary *)dict;
+ (void)UploadHistory:(NSString *)Myline_id;
@end
