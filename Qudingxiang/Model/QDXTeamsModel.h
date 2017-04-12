//
//  QDXTeamsModel.h
//  趣定向
//
//  Created by Air on 16/3/15.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDXTeamsModel : NSObject
/**
 *  用户ID
 */
@property (copy,nonatomic) NSString *customer_id;
/**
 *  用户名称
 */
@property (copy,nonatomic) NSString *customer_name;
/**
 *  我的当前线路
 */
@property (copy,nonatomic) NSString *myline_id;
/**
 *  团队ID
 */
@property (copy,nonatomic) NSString *teams_id;
@end
