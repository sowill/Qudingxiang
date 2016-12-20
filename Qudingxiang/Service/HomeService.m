
//
//  HomeService.m
//  趣定向
//
//  Created by Prince on 16/3/15.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "HomeService.h"

@implementation HomeService
static HomeService *httpRequest = nil;
+ (HomeService *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (httpRequest == nil) {
            httpRequest = [[self alloc] init];
        }
    });
    return httpRequest;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (httpRequest == nil) {
            httpRequest = [super allocWithZone:zone];
        }
    });
    return httpRequest;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    return httpRequest;
}

- (void)topViewDatasucceed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure;
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *urlString = [hostUrl stringByAppendingString:detailUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"areatype_id"] = @"2";
    params[@"curr"] = @"1";
    [manager POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        succeed(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)statesucceed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure WithToken:(NSString *)tokenKey;
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];
    NSString *urlString = [hostUrl stringByAppendingString:usingTicket];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = tokenKey;
    [manager POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress){
            
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
            succeed(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
    }];
}

- (void)loadCellsucceed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure WithCurr:(NSString *)curr WithType:(NSString *)type ;
{
    NSString *urlString = [hostUrl stringByAppendingString:goodsUrl];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"areatype_id"] = @"1";
    params[@"curr"] = curr;
    params[@"type"] =type;
    [manager POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress){
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        succeed(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)dbversionsucceed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/util/Dbversion"];
    [manager POST:url parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [NSKeyedArchiver archiveRootObject:responseObject[@"goods"] toFile:QDXGoods];
        [NSKeyedArchiver archiveRootObject:responseObject[@"myline"] toFile:QDXMyline];
        succeed(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)POST:(NSString *)URLString succeed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"TokenKey"] = save;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];
    [manager POST:URLString parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        succeed(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
@end
