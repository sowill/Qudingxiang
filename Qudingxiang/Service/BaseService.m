//
//  BaseService.m
//  趣定向
//
//  Created by Prince on 16/4/22.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "BaseService.h"

@implementation BaseService
+ (void)netDataBlock:(void (^)(NSMutableDictionary *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithUrl:(NSString *)url andParams:(NSMutableDictionary *)params
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
