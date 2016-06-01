//
//  LineModel.h
//  Qudingxiang
//
//  Created by Mac on 15/9/18.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LineModel : NSObject
/**
 *  场地ID
 */
@property (copy,nonatomic) NSString *area_id;
/**
 *  线路描述
 */
@property (copy,nonatomic) NSString *line_des;
/**
 *  线路名称
 */
@property (nonatomic, strong) NSString *line_name;
/**
 *  线路下标题
 */
@property (nonatomic, strong) NSString *line_sub;
/**
 *  线路ID
 */
@property (nonatomic, strong) NSString *line_id;
/**
 *  线路地图
 */
@property (nonatomic, strong) NSString *line_map;

/**
 *  线路种类
 */
@property (nonatomic, strong) NSString *linetype_id;

@property (nonatomic, strong) NSString *line_code;

@property (nonatomic, strong) NSString *line_line;

@property (nonatomic, strong) NSDictionary *ticket;

@end

