//
//  HomeService.m
//  趣定向
//
//  Created by Prince on 16/3/15.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "HomeService.h"

@implementation HomeService
+ (void)topViewDataBlock:(void (^)(NSMutableDictionary *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithToken:(NSString *)tokenKey
{
    NSString *urlString = [hostUrl stringByAppendingString:detailUrl];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //mgr.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //params[@"TokenKey"] = tokenKey;
    params[@"areatype_id"] = @"2";
    params[@"curr"] = @"1";
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

//    [mgr POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        dict = responseObject;
//        if (block) {
//            block(dict);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSMutableArray *failArr = [[NSMutableArray alloc]init];
//        [failArr addObject:error];
//        if (failBlock) {
//            failBlock(failArr);
//        }
//        
//    }];

}

+ (void)btnStateBlock:(void (^)(NSMutableDictionary *dict))block andWithToken:(NSString *)tokenKey
{
    NSString *urlString = [hostUrl stringByAppendingString:usingTicket];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = tokenKey;
    __block NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [mgr POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dict = responseObject;
        if (block) {
            block(dict);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        
    }];

//    [mgr POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        dict = responseObject;
//        if (block) {
//            block(dict);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        
//    }];

}

+ (void)btnTabStateBlock:(void (^)(NSMutableDictionary *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithToken:(NSString *)tokenKey
{
    NSString *urlString = [hostUrl stringByAppendingString:usingTicket];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = tokenKey;
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

+ (void)choiceLineStateBlock:(void (^)(NSMutableDictionary *dict))block andWithToken:(NSString *)tokenKey
{
    NSString *urlString = [hostUrl stringByAppendingString:lineUrl];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = tokenKey;
    __block NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [mgr POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dict = responseObject;
        if (block) {
            block(dict);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
        
    }];

}

+ (void)cellDataBlock:(void (^)(NSMutableDictionary *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithToken:(NSString *)tokenKey andWithCurr:(NSString *)curr andWithType:(NSString *)type{
    NSString *urlString = [hostUrl stringByAppendingString:goodsUrl];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //params[@"TokenKey"] = tokenKey;
    params[@"areatype_id"] = @"1";
    params[@"curr"] = @"1";
    params[@"type"] =type;
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

//    [mgr POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        dict = responseObject;
//        if (block) {
//            block(dict);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSMutableArray *failArr = [[NSMutableArray alloc]init];
//        [failArr addObject:error];        
//        if (failBlock) {
//            failBlock(failArr);
//        }
//    }];

}
@end
