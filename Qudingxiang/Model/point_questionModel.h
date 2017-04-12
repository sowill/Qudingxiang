//
//  point_questionModel.h
//  趣定向
//
//  Created by Air on 16/3/16.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QDXQuestionModel;
@interface point_questionModel : NSObject
/**
 *  pointmap_id
 */
@property (copy,nonatomic) NSString *pointmap_id;
/**
 *  pointqumap_id
 */
@property (copy,nonatomic) NSString *pointqumap_id;
/**
 *  任务编号
 */
@property (copy,nonatomic) NSString *question_id;
/**
 *  线路ID
 */
@property (copy,nonatomic) NSString *line_id;
/**
 *  pindex
 */
@property (copy,nonatomic) NSString *pindex;
/**
 *  点标ID
 */
@property (copy,nonatomic) NSString *point_id;
/**
 *  点标积分
 */
@property (copy,nonatomic) NSString *pointmap_score;
/**
 *  问题
 */
@property (strong,nonatomic) QDXQuestionModel *question;

-(instancetype)initWithQ_id:(NSString *)q_id
                       P_mapid:(NSString *)p_mapid;
@end
