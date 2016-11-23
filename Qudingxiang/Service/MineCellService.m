//
//  MineCellService.m
//  趣定向
//
//  Created by Mac on 16/8/12.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "MineCellService.h"

@implementation MineCellService
static MineCellService *httpRequest = nil;
+ (MineCellService *)sharedInstance
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

- (void)cellDatasucceed:(void (^)(id))succeed failure:(void (^)(NSError *))failure andWithCurr:(NSString *)curr
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",hostUrl,mineUrl];
    //创建网络请求管理对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //内容类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];
    //如果报接受类型不一致请替换一致text/html或别的
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    //发送网络请求(请求方式为POST)
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"curr"] = curr;
        [manager POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            succeed(responseObject);
            //NSLog(@"%@",responseObject);
            //[NSKeyedArchiver archiveRootObject:responseObject toFile:fileName];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
    //}

}

- (void)teamCellDatasucceed:(void (^)(id data))succeed failure:(void (^)(NSError *error))failure andWithCurr:(NSString *)curr
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",hostUrl,teamUrl];
    //创建网络请求管理对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //内容类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];
    //如果报接受类型不一致请替换一致text/html或别的
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    //发送网络请求(请求方式为POST)
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"curr"] = curr;
        [manager POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            succeed(responseObject);
            //NSLog(@"%@",responseObject);
            //[NSKeyedArchiver archiveRootObject:responseObject toFile:fileName];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
    //}
    

}
@end
