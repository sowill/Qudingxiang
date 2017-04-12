//
//  QDXQuestionDB.h
//  趣定向
//
//  Created by Air on 16/3/16.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QDXQuestionModel;
@class point_questionModel;
@class QDXHIstoryModel;
@class QDXPointModel;
@class line_pointModel;
@class QDXGameModel;

@interface QDXOfflineDB : NSObject

+(instancetype)shareDataBase;
/**
 *  打开数据库建表
 */
-(void)openOfflineDB;
/**
 *  关闭数据库删表
 */
-(void)closeOfflineDB;
/**
 *  查询 所有问题
 */
-(NSArray *)selectAllQuestion;
/**
 *  通过myline_id查询对应历史记录
 */
-(NSArray *)selectHistoryWithMLid:(NSString *)myline_id;
/**
 *  用SELECTQUESTIONWITHQID代替 查询问题
 */
-(QDXQuestionModel *)selectOneQuestion:(NSString *)question_id;
/**
 *  用SELECTQUESTIONWITHQID代替 查询对应关系
 */
-(NSArray *)selectQid:(NSString *)pointmap_id;
/**
 *  通过pointmap_id查询对应问题
 */
-(NSArray *)selectQuestionWithQid:(NSString *)pointmap_id;
/**
 *  通过line_id查询点标的顺序
 */
-(NSArray *)selectPointWithLid:(NSString *)line_id;
/**
 *  通过历史点标查询需要去的点标
 */
-(NSArray *)selectAllPointWithPid:(NSArray *)point_idArray;
/**
 *  通过point_id查询对应点标
 */
-(QDXPointModel *)selectPointWithPid:(NSString *)point_id;
/**
 *  通过mylineid查询线路信息
 */
-(QDXGameModel *)selectMylineWithMLid:(NSString *)myline_id;
/**
 *  添加问题表
 */
-(void)insertQuestion:(QDXQuestionModel *)questions;
/**
 *  添加点标与问题对应关系表
 */
-(void)insertPointAndQuestion:(point_questionModel *)point_questions;
/**
 *  添加历史记录表
 */
-(void)insertHistory:(QDXHIstoryModel *)history;
/**
 *  添加点标表
 */
-(void)insertPoint:(QDXPointModel *)point;
/**
 *  添加线路与点标对应关系表
 */
-(void)insertLineAndPoint:(line_pointModel *)line_point;
/**
 *  添加我的线路表
 */
-(void)insertMyLine:(QDXGameModel *)myline;
/**
 *  修改当前线路状态
 */
-(void)modifyMyline:(QDXGameModel *)myline;
/**
 *  删除重复记录
 */
-(void)deleteTheSame;
@end
