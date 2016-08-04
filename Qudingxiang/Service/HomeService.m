
//
//  HomeService.m
//  趣定向
//
//  Created by Prince on 16/3/15.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "HomeService.h"

@implementation HomeService
+ (void)topViewDataBlock:(void (^)(NSDictionary *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithToken:(NSString *)tokenKey
{
    __block NSDictionary *dict = [[NSDictionary alloc] init];
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
    NSString *cachekey = [NSString stringWithFormat:@"%@%@21%@%@",urlString,tokenKey,VGoods,VLine];
    NSString *str = [ToolView md5:cachekey];
    
    NSString *fileName = [accountFile stringByAppendingPathComponent:str];
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

+ (void)cellDataBlock:(void (^)(NSDictionary *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithToken:(NSString *)tokenKey andWithCurr:(NSString *)curr andWithType:(NSString *)type{
    __block NSDictionary *dict = [[NSDictionary alloc] init];
    NSString *urlString = [hostUrl stringByAppendingString:goodsUrl];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"areatype_id"] = @"1";
    params[@"curr"] = @"1";
    params[@"type"] =type;
    NSString *cachekey = [NSString stringWithFormat:@"%@%@%@%@%@%@",urlString,tokenKey,curr,type,VGoods,VLine];
    NSString *str = [ToolView md5:cachekey];
    
    NSString *fileName = [accountFile stringByAppendingPathComponent:str];
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

+ (void)dbversionBlock:(void (^)(void))block
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *url = [hostUrl stringByAppendingString:@"Home/util/Dbversion"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        [NSKeyedArchiver archiveRootObject:infoDict[@"goods"] toFile:QDXGoods];
        [NSKeyedArchiver archiveRootObject:infoDict[@"myline"] toFile:QDXMyline];
        if (block) {
            block();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block();
        }
    }];

}
@end
