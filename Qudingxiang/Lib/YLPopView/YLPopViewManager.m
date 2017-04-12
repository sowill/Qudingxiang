//
//  YLPopViewManager.m
//  趣定向
//
//  Created by Air on 2016/12/9.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "YLPopViewManager.h"

@implementation YLPopViewManager

static id _instance;

+(instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

@end
