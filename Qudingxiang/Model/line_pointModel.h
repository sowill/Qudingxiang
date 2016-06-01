//
//  line_pointModel.h
//  趣定向
//
//  Created by Air on 16/3/22.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LineModel;
@class QDXPointModel;
@interface line_pointModel : NSObject
/**
 *  线路ID
 */
@property (copy,nonatomic) NSString *line_id;
/**
 *  点标排序
 */
@property (copy,nonatomic) NSString *pindex;
/**
 *  点标ID
 */
@property (copy,nonatomic) NSString *point_id;
/**
 *  点标描述
 */
@property (copy,nonatomic) NSString *pointmap_des;
/**
 *  pointmap_id
 */
@property (copy,nonatomic) NSString *pointmap_id;
/**
 *  点标
 */
@property (strong,nonatomic) QDXPointModel *point;
/**
 *  线路
 */
@property (strong,nonatomic) LineModel *line;

-(instancetype)initWithL_id:(NSString *)line_id
                       P_id:(NSString *)point_id
                       P_mapid:(NSString *)pointmap_id
                       P_mapdes:(NSString *)pointmap_des
                       P_index:(NSString *)pindex;
@end
