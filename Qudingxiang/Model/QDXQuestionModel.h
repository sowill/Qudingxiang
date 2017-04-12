//
//  QDXQuestionModel.h
//  趣定向
//
//  Created by Air on 16/3/16.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDXQuestionModel : NSObject
/**
 *  级别
 */
@property (copy,nonatomic) NSString *level;
/**
 *  qa
 */
@property (copy,nonatomic) NSString *qa;
/**
 *  qb
 */
@property (copy,nonatomic) NSString *qb;
/**
 *  qc
 */
@property (copy,nonatomic) NSString *qc;
/**
 *  qd
 */
@property (copy,nonatomic) NSString *qd;
/**
 *  问题类型
 */
@property (copy,nonatomic) NSString *qtype_id;
/**
 *  划分
 */
@property (copy,nonatomic) NSString *qgroup;
/**
 *  问题
 */
@property (copy,nonatomic) NSString *question_name;
/**
 *  答案
 */
@property (copy,nonatomic) NSString *qkey;
/**
 *  question_id
 */
@property (copy,nonatomic) NSString *question_id;
/**
 *  问题种类
 */
@property (copy,nonatomic) NSString *ischoice;

-(instancetype)initWithQName:(NSString *)q_name
                          Qa:(NSString *)q_a
                          Qb:(NSString *)q_b
                          Qc:(NSString *)q_c
                          Qd:(NSString *)q_d
                          Qkey:(NSString *)q_key
                          Qid:(NSString *)q_id;
@end
