//
//  QDXGameModel.h
//  Qudingxiang
//  Created by Air on 15/9/29.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QDXTeamsModel;
@class QDXPointModel;
@class LineModel;
@class QDXHIstoryModel;
@class point_questionModel;
@class line_pointModel;

@interface QDXGameModel : NSObject
/**
 *  队长ID
 */
@property (copy,nonatomic) NSString *customer_id;
/**
 *  isLeader
 */
@property (copy,nonatomic) NSString *isLeader;
/**
 *  线路ID
 */
@property (copy,nonatomic) NSString *line_id;
/**
 *  当前线路ID
 */
@property (copy,nonatomic) NSString *myline_id;
/**
 *  需要打印的二维码
 */
@property (copy,nonatomic) NSString *printcode;
/**
 *  题目数量
 */
@property (copy,nonatomic) NSString *question;
/**
 *  当前成绩
 */
@property (copy,nonatomic) NSString *score;
/**
 *  开始时间
 */
@property (copy,nonatomic) NSString *sdate;
/**
 *  队伍名称
 */
@property (copy,nonatomic) NSString *team;
/**
 *  游戏状态 1.准备开始 2.游戏中 3.完成比赛 4.强制结束
 */
@property (copy,nonatomic) NSString *mstatus_id;
/**
 *  当前对应点标
 */
@property (copy,nonatomic) NSString * pointmap_id;
/**
 *  团队
 */
@property (strong, nonatomic) NSMutableArray *teams;
/**
 *  点标
 */
@property (strong,nonatomic) QDXPointModel *point;
/**
 *  线路
 */
@property (strong,nonatomic) LineModel *line;
/**
 *  pointmap
 */
@property (strong,nonatomic) point_questionModel *pointmap;
/**
 *  linepoint
 */
@property (strong,nonatomic) line_pointModel *linepoint;
/**
 *  历史
 */
@property (strong,nonatomic) NSMutableArray *history;

-(instancetype)initWithL_id:(NSString *)line_id
                       ML_id:(NSString *)myline_id
                       MS_id:(NSString *)mstatus_id
                       Sdate:(NSString *)sdate
                       Score:(NSString *)score
                       Isleader:(NSString *)isLeader
                       P_mid:(NSString *)pointmap_id;
@end
