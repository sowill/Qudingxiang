//
//  LocalSqlliteService.h
//  趣定向
//
//  Created by Air on 16/8/3.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QDXOfflineDB.h"
@interface LocalSqlliteService : NSObject

+(id)LocalSqlliteServiceOut;
-(id)LocalSqlliteServiceIn;
/**
 *  创建数据库模型
 */
@property (nonatomic, strong) QDXOfflineDB *offlineDB;
@end
