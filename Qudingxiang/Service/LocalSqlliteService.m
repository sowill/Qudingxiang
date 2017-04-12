//
//  LocalSqlliteService.m
//  趣定向
//
//  Created by Air on 16/8/3.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "LocalSqlliteService.h"
#import "QDXGameModel.h"
#import "QDXTeamsModel.h"
#import "LineModel.h"
#import "QDXHIstoryModel.h"
#import "QDXPointModel.h"
#import "QDXAreaModel.h"
#import "QDXQuestionModel.h"
#import "point_questionModel.h"
#import "line_pointModel.h"



@implementation LocalSqlliteService

//-(id)init{
//    
//     if(self=[super init])
//    {
//      self.offlineDB = [QDXOfflineDB shareDataBase];
//    }
//    return self;
//}

+(id)LocalSqlliteServiceOut
{
    return [[self alloc] LocalSqlliteServiceIn];
}

-(id)LocalSqlliteServiceIn
{
    self.offlineDB = [QDXOfflineDB shareDataBase];
    [self setupgetMylineInfo];
    [self setuploadPoint];
    [self setuploadQuestion];
    
    return nil;
}


-(void)setuploadPoint
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"myline_id"] = mylineid;
    NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/Myline/loadPoint"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        int ret = [infoDict[@"Code"] intValue];
        if (ret == 1) {
            NSArray *line_pointArray = [line_pointModel mj_objectArrayWithKeyValuesArray:infoDict[@"Msg"]];
            for (line_pointModel *line_point in line_pointArray) {
                QDXPointModel *points = [[QDXPointModel alloc] initWithP_id:line_point.point.point_id A_id:line_point.point.area_id LAT:line_point.point.LAT LON:line_point.point.LON Label:line_point.point.label P_name:line_point.point.point_name Rssi:line_point.point.rssi];
                line_pointModel *l_question = [[line_pointModel alloc] initWithL_id:line_point.line_id P_id:line_point.point_id P_mapid:line_point.pointmap_id P_mapdes:line_point.pointmap_des P_index:line_point.pindex l_typeid:line_point.line.linetype_id];
                [_offlineDB insertLineAndPoint:l_question];
                [_offlineDB insertPoint:points];
            }
        }
        else{
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)setuploadQuestion
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"myline_id"] = mylineid;
    NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/Myline/loadQuestion"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        int ret = [infoDict[@"Code"] intValue];
        if (ret == 1) {
            NSArray *point_questionArray = [point_questionModel mj_objectArrayWithKeyValuesArray:infoDict[@"Msg"]];
            for (point_questionModel *point_question in point_questionArray) {
                QDXQuestionModel *questions = [[QDXQuestionModel alloc] initWithQName:point_question.question.question_name Qa:point_question.question.qa Qb:point_question.question.qb Qc:point_question.question.qc Qd:point_question.question.qd Qkey:point_question.question.qkey Qid:point_question.question.question_id];
                point_questionModel *p_question = [[point_questionModel alloc] initWithQ_id:point_question.question_id P_mapid:point_question.pointmap_id];
                [_offlineDB insertPointAndQuestion:p_question];
                [_offlineDB insertQuestion:questions];
            }
        }
        else{
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)setupgetMylineInfo
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"TokenKey"] = save;
    params[@"myline_id"] = mylineid;
    NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/Myline/getMyline"];
    
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        int ret = [infoDict[@"Code"] intValue];
        if (ret==1) {
            QDXGameModel *game = [QDXGameModel mj_objectWithKeyValues:infoDict[@"Msg"]];
            for (QDXHIstoryModel *history in game.history) {
                QDXHIstoryModel *historys = [[QDXHIstoryModel alloc] initWithEdate:history.edate Myline_id:history.myline_id Point_id:history.point_id Score:history.point_id];
                [_offlineDB insertHistory:historys];
            }
            
            QDXGameModel *myline = [[QDXGameModel alloc] initWithL_id:game.line_id ML_id:game.myline_id MS_id:game.mstatus_id Sdate:game.sdate Score:game.score Isleader:game.isLeader P_mid:game.pointmap_id];
            [_offlineDB insertMyLine:myline];
            
            NSString *map_url = [hostUrl stringByAppendingString:game.point.area.map];
            UIImage *map_image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:map_url]]];
            
            NSData *data;
            
            if (UIImagePNGRepresentation(map_image) == nil) {
                
                data = UIImageJPEGRepresentation(map_image, 1);
                
            } else {
                
                data = UIImagePNGRepresentation(map_image);
                
            }
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"image"];
            [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            [fileManager createFileAtPath:[NSString stringWithFormat:@"%@/map_%@.png",filePath,mylineid] contents:data attributes:nil];
            
        }
        else{
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

@end
