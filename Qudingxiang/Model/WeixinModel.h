//
//  WeixinModel.h
//  趣定向
//
//  Created by Air on 16/1/29.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeixinModel : NSObject

@property (nonatomic, strong) NSString *appid;
@property (nonatomic, strong) NSString *noncestr;
@property (nonatomic, strong) NSString *partnerid;
@property (nonatomic, strong) NSString *prepayid;
@property (nonatomic, strong) NSString *sign;
@property (nonatomic, strong) NSString *timestamp;
@end
