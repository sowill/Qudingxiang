//
//  BaseService.h
//  趣定向
//
//  Created by Prince on 16/4/22.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>
//请求方式
typedef NS_ENUM(NSUInteger,RequestMethod) {
    POST = 0,
    GET,
    PUT,
    PATCH,
    DELETE
};

//错误代码
typedef NS_ENUM(NSInteger, AFNetworkingErrorType) {
    AFNetworkingErrorType_TimeOut = NSURLErrorTimedOut,
    AFNetworkingErrorType_UnURL = NSURLErrorUnsupportedURL,
    AFNetworkingErrorType_NoNetwork = NSURLErrorNotConnectedToInternet,
    AFNetworkingErrorType_404Failed = NSURLErrorBadServerResponse,
    AFNetworkingErrorType_3840Failed = 3840
};
@interface BaseService : NSObject
//初始化请求单例
+ (instancetype)shareInstance;

+ (void)netDataBlock:(void (^)(NSMutableDictionary *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithUrl:(NSString *)url andParams:(NSMutableDictionary *)params;
@end
