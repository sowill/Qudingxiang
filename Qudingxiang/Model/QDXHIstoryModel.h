//
//  QDXHIstoryModel.h
//  趣定向
//
//  Created by Air on 16/3/15.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QDXPointModel;

@interface QDXHIstoryModel : NSObject
/**
 *  到点时间
 */
@property (copy,nonatomic) NSString *edate;
/**
 *  我的当前线路
 */
@property (copy,nonatomic) NSString *myline_id;
/**
 *  点标ID
 */
@property (copy,nonatomic) NSString *point_id;
/**
 *  到点成绩
 */
@property (copy,nonatomic) NSString *score;
/**
 *  点标
 */
@property (strong,nonatomic) QDXPointModel *point;

-(instancetype)initWithEdate:(NSString *)edate
                       Myline_id:(NSString *)myline_id
                       Point_id:(NSString *)point_id
                       Score:(NSString *)score;
@end
