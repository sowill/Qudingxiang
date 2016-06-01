//
//  MineService.m
//  趣定向
//
//  Created by Prince on 16/3/16.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "MineService.h"

@implementation MineService
+ (void)cellDataBlock:(void (^)(NSMutableDictionary *dict))block FailBlock:(void (^)(NSMutableArray *))failBlock andWithToken:(NSString *)tokenKey
{
    NSString *urlString = [hostUrl stringByAppendingString:@"Home/Customer/authlogin"];
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
