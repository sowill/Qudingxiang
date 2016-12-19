
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
//    NSString *cachekey = [NSString stringWithFormat:@"%@21%@%@",urlString,VGoods,VLine];
//    NSString *str = [ToolView md5:cachekey];
//    NSString *topViewFile = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *fileName = [topViewFile stringByAppendingPathComponent:str];
//    NSDictionary *res = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
//    if (res!=nil) {
//        succeed(res);
//    }else{
    [manager POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        succeed(responseObject);
//        [NSKeyedArchiver archiveRootObject:responseObject toFile:fileName];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
//    }

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
    //创建网络请求管理对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];     //如果报接受类型不一致请替换一致text/html或别的
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil nil];
    //发送网络请求(请求方式为POST)
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

    //创建网络请求管理对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //内容类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];

    //如果报接受类型不一致请替换一致text/html或别的
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil nil];
    //发送网络请求(请求方式为POST)
    [manager POST:URLString parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        succeed(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
@end
