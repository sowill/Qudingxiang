//
//  QDXQuestionModel.m
//  趣定向
//
//  Created by Air on 16/3/16.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXQuestionModel.h"

@implementation QDXQuestionModel

-(instancetype)initWithQName:(NSString *)q_name
                          Qa:(NSString *)q_a
                          Qb:(NSString *)q_b
                          Qc:(NSString *)q_c
                          Qd:(NSString *)q_d
                        Qkey:(NSString *)q_key
                         Qid:(NSString *)q_id
{
    if (self = [super init]) {
        _question_name = q_name;
        _qa = q_a;
        _qb = q_b;
        _qc = q_c;
        _qd = q_d;
        _qkey = q_key;
        _question_id = q_id;
    }
    return self;
}

@end
