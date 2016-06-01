//
//  QDXMap.h
//  趣定向
//
//  Created by Air on 16/5/19.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDXMap : NSObject
/**
 *  bottom_lat
 */
@property (copy,nonatomic) NSString *bottom_lat;
/**
 *  bottom_lon
 */
@property (copy,nonatomic) NSString *bottom_lon;
/**
 *  line_map
 */
@property (copy,nonatomic) NSString *line_map;
/**
 *  top_lat
 */
@property (copy,nonatomic) NSString *top_lat;
/**
 *  top_lon
 */
@property (copy,nonatomic) NSString *top_lon;

@end
