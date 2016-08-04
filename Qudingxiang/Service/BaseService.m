//
//  BaseService.m
//  趣定向
//
//  Created by Prince on 16/4/22.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "BaseService.h"

@implementation BaseService

+ (instancetype)shareInstance
{
    static BaseService *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[BaseService alloc] init];
    });
    return singleton;
}

- (void)startRequestMethod:(RequestMethod)method parameters:(id)parameters url:(NSString *)url success:(void (^)(id))success
{
    //1、初始化：
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //2、设置请求超时时间：
    manager.requestSerializer.timeoutInterval = 30.0f;
    //3、设置允许接收返回数据类型：
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", nil];
}

+ (void)netDataBlock:(void (^)(NSMutableDictionary *dict))block FailBlock:(void(^)(NSMutableArray *array)
                                                                           )failBlock andWithUrl:(NSString *)url andParams:(NSMutableDictionary *)params
{
    NSString *urlString = [hostUrl stringByAppendingString:url];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //params = [[NSMutableDictionary alloc] initWithCapacity:0];;
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    __block NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [mgr POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dict = responseObject;
        if (block) {
            block(dict);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSMutableArray *failArr = [[NSMutableArray alloc]init];
        [failArr addObject:error];
        if (failBlock) {
            failBlock(failArr);
        }
        
    }];

}
@end
