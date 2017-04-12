//
//  UpdateService.m
//  趣定向
//
//  Created by Prince on 16/4/22.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "UpdateService.h"

@implementation UpdateService
+ (void)netDataBlock:(void (^)(NSString *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithUrl:(NSString *)url andData:(NSData *)data andfileName:(NSString *)fileName
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    __block NSString *dict = [[NSString alloc] init];
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"imgfile" fileName:fileName mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        //打印下上传进度
//        NSLog(@"%lf",1.0 *uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        dict = result;
        //请求成功
        //NSLog(@"请求成功：%@",responseObject);
        //NSLog(@"请求成功：1111%@",dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //请求失败
        NSLog(@"请求失败：%@",error);
    }];

}
@end
