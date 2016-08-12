//
//  ActivityService.m
//  趣定向
//
//  Created by Prince on 16/3/16.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "ActivityService.h"

@implementation ActivityService
+ (void)cellDataBlock:(void (^)(NSDictionary *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithToken:(NSString *)tokenKey andWithCurr:(NSString *)curr
{
    __block NSDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString *urlString = [hostUrl stringByAppendingString:detailUrl];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    //mgr.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = tokenKey;
    params[@"areatype_id"] = @"2";
    params[@"curr"] = curr;
    NSString *cachekey = [NSString stringWithFormat:@"%@%@2%@%@%@",urlString,tokenKey,curr,VGoods,VLine];
    NSString *str = [ToolView md5:cachekey];
    NSString *actFile = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [actFile stringByAppendingPathComponent:str];
    NSDictionary *res = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    if (res!=nil) {
        dict = res;
        if(block){
            block(dict);
        }
    }else{
    [mgr POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dict = responseObject;
        if (block) {
            block(dict);
            [NSKeyedArchiver archiveRootObject:dict toFile:fileName];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSMutableArray *failArr = [[NSMutableArray alloc]init];
        [failArr addObject:error];
        if (failBlock) {
            failBlock(failArr);
        }

    }];
    }
}
@end
