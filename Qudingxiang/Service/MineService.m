//
//  MineService.m
//  趣定向
//
//  Created by Prince on 16/3/16.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "MineService.h"

@implementation MineService
+ (void)cellDataBlock:(void (^)(NSDictionary *dict))block FailBlock:(void (^)(NSMutableArray *))failBlock andWithToken:(NSString *)tokenKey
{
    __block NSDictionary *dict = [[NSDictionary alloc] init];
    NSString *urlString = [hostUrl stringByAppendingString:@"Home/Customer/authlogin"];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = tokenKey;
    NSString *cachekey = [NSString stringWithFormat:@"%@%@%@%@",urlString,tokenKey,VGoods,VLine];
    NSString *mineFile = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *str = [ToolView md5:cachekey];
    NSString *fileName = [mineFile stringByAppendingPathComponent:str];
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
