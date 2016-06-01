//
//  LoginService.m
//  趣定向
//
//  Created by Prince on 16/3/11.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "LoginService.h"
@implementation LoginService

+ (void)getAccessBlock:(void (^)(NSMutableDictionary *dict))block andWithKey:(NSString *)key andWithSecret:(NSString *)secret andWithWXCode:(NSString *)code;
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",key,secret,code];
    //创建请求管理对象
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
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
//    }];
}

+ (void)getUserInfoBlock:(void (^)(NSMutableDictionary *dict))block andWithToken:(NSString *)token andWithOpenID:(NSString *)openID
{
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",token,openID];
    //创建请求管理对象
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    __block NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [mgr POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dict = responseObject;
        if (block) {
            block(dict);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSMutableArray *failArr = [[NSMutableArray alloc]init];
//        [failArr addObject:error];
//        if (failBlock) {
//            failBlock(failArr);
//        }
        
    }];

//    [mgr POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        dict = responseObject;
//        if (block) {
//            block(dict);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//    }];

}

+ (void)QQandWXlog:(void (^)(NSMutableDictionary *dict))block andWithTXOpenID:(NSString *)txID andWithWXOpenID:(NSString *)wxID
{
     NSString *urlString = [hostUrl stringByAppendingString:@"Home/Customer/qvlogin"];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"qid"] = txID;
    params[@"wxid"] = wxID;
    __block NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [mgr POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dict = responseObject;
        if (block) {
            block(dict);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //NSMutableArray *failArr = [[NSMutableArray alloc]init];
        [MBProgressHUD showError:@"登录失败"];
        NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
        [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];

        
    }];

//    [mgr POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        dict = responseObject;
//        if (block) {
//            block(dict);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [MBProgressHUD showError:@"登录失败"];
//        NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        documentDir= [documentDir stringByAppendingPathComponent:@"QDXAccount.data"];
//        [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
//
//    }];

}

+ (void)logInBlock:(void (^)(NSMutableDictionary *dict))block andWithUserName:(NSString *)userName andWithPassWord:(NSString *)passWord
{
    NSString *urlString = [hostUrl stringByAppendingString:@"Home/Customer/login"];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"code"] = userName;
    params[@"password"] = passWord;
    __block NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [mgr POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dict = responseObject;
        if (block) {
            block(dict);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showError:@"登录失败"];
        NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        documentDir= [documentDir stringByAppendingPathComponent:@"XWLAccount.data"];
        [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
        
    }];

//    [mgr POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        dict = responseObject;
//        if (block) {
//            block(dict);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [MBProgressHUD showError:@"登录失败"];
//        NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        documentDir= [documentDir stringByAppendingPathComponent:@"QDXAccount.data"];
//        [[NSFileManager defaultManager] removeItemAtPath:documentDir error:nil];
//        
//    }];

}
@end
