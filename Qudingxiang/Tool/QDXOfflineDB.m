//
//  QDXQuestionDB.m
//  趣定向
//
//  Created by Air on 16/3/16.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXOfflineDB.h"
#import "point_questionModel.h"
#import "QDXQuestionModel.h"
#import "QDXHIstoryModel.h"
#import "line_pointModel.h"
#import "QDXPointModel.h"
#import "QDXGameModel.h"
#import <sqlite3.h>

@implementation QDXOfflineDB

static QDXOfflineDB *dataBase = nil;

+(instancetype)shareDataBase
{
    //使用GCD方法   使单例方法只创建一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //初始化单例对象
        dataBase = [[QDXOfflineDB alloc]init];
        //打开数据库
        [dataBase openOfflineDB];
    });
    return dataBase;
}

//创建数据库对象
static sqlite3 *db = nil;
//打开数据库

-(void)openOfflineDB
{
    //如果数据库已经打开,则不需要执行后面的操作  直接return
    if (db != nil) {
        return;
    }
    //存放数据库的路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"QDXOffine.sqlite"];
    
    NSLog(@"%@",path);
    //打开数据库(如果该数据库存在则直接打开,否则自动创建一个再打开)
    int result = sqlite3_open([path UTF8String], &db);
    if (result == SQLITE_OK) {
//        NSLog(@"数据库打开成功");
        //建表
        const char *sql1 = "CREATE TABLE IF NOT EXISTS qdx_question (q_id integer PRIMARY KEY AUTOINCREMENT,question_name text NOT NULL,qa text,qb text,qc text,qd text,qkey text NOT NULL,question_id NOT NULL)";
        
        const char *sql2 = "CREATE TABLE IF NOT EXISTS qdx_point_question (p_q_id integer PRIMARY KEY AUTOINCREMENT,question_id text NOT NULL,pointmap_id text NOT NULL)";
        
        const char *sql3 = "CREATE TABLE IF NOT EXISTS qdx_history (h_id integer PRIMARY KEY AUTOINCREMENT,edate text,myline_id text,point_id text,score text)";
        
        const char *sql4 = "CREATE TABLE IF NOT EXISTS qdx_line_point (l_p_id integer PRIMARY KEY AUTOINCREMENT,line_id text NOT NULL,point_id text NOT NULL,pointmap_id text NOT NULL,pointmap_des text,pindex text,linetype_id text)";
        
        const char *sql5 = "CREATE TABLE IF NOT EXISTS qdx_point (p_id integer PRIMARY KEY AUTOINCREMENT,point_id text NOT NULL,area_id text,LAT text,LON text,label text NOT NULL,point_name text NOT NULL,rssi text NOT NULL)";
        
        const char *sql6 = "CREATE TABLE IF NOT EXISTS qdx_myline (m_l_id integer PRIMARY KEY AUTOINCREMENT,line_id text NOT NULL,myline_id text,mstatus_id text,sdate text,score text,isLeader text,pointmap_id text)";
        
        char *errmsg = NULL;
        sqlite3_exec(db, sql1, NULL, NULL, &errmsg);
        sqlite3_exec(db, sql2, NULL, NULL, &errmsg);
        sqlite3_exec(db, sql3, NULL, NULL, &errmsg);
        sqlite3_exec(db, sql4, NULL, NULL, &errmsg);
        sqlite3_exec(db, sql5, NULL, NULL, &errmsg);
        sqlite3_exec(db, sql6, NULL, NULL, &errmsg);
    }else
    {
        //如果失败,打印失败原因
//        NSLog(@"%d",result);
    }
}

//关闭数据库
-(void)closeOfflineDB
{
    int result = sqlite3_close(db);
    if (result == SQLITE_OK) {
//        NSLog(@"数据库关闭成功");
        //当关闭数据库的时候将db置为空,是因为打开数据库的时候,我们需要使用nil作判断
        db = nil;
        
        const char *sql1 = "DROP TABLE qdx_point_question";
        const char *sql2 = "DROP TABLE qdx_question";
        const char *sql3 = "DROP TABLE qdx_history";
        const char *sql4 = "DROP TABLE qdx_line_point";
        const char *sql5 = "DROP TABLE qdx_point";
        const char *sql6 = "DROP TABLE qdx_myline";
        char *errmsg = NULL;
        sqlite3_exec(db, sql1, NULL, NULL, &errmsg);
        sqlite3_exec(db, sql2, NULL, NULL, &errmsg);
        sqlite3_exec(db, sql3, NULL, NULL, &errmsg);
        sqlite3_exec(db, sql4, NULL, NULL, &errmsg);
        sqlite3_exec(db, sql5, NULL, NULL, &errmsg);
        sqlite3_exec(db, sql6, NULL, NULL, &errmsg);
    }else
    {
        //如果失败,打印失败原因
//        NSLog(@"%d",result);
    }
}

-(void)deleteTheSame
{
    NSString *sql1 = [NSString stringWithFormat:@"delete from qdx_point_question where p_q_id not in (select min(p_q_id) as p_q_id from qdx_point_question group by question_id,pointmap_id)"];
    
    NSString *sql2 = [NSString stringWithFormat:@"delete from qdx_question where question_id in(select question_id from qdx_question group by question_id having count(question_id)>1) and q_id not in (select min(q_id) from qdx_question group by question_id having count(question_id)>1)"];
    
    NSString *sql3 = [NSString stringWithFormat:@"delete from qdx_history where h_id not in (select min(h_id) as h_id from qdx_history group by point_id,myline_id)"];
    
    NSString *sql4 = [NSString stringWithFormat:@"delete from qdx_line_point where l_p_id not in (select min(l_p_id) as l_p_id from qdx_line_point group by line_id,pointmap_id)"];
    
    NSString *sql5 = [NSString stringWithFormat:@"delete from qdx_point where p_id not in (select min(p_id) as p_id from qdx_point group by point_id)"];
    
    NSString *sql6 = [NSString stringWithFormat:@"delete from qdx_myline where m_l_id not in (select max(m_l_id) as m_l_id from qdx_myline group by myline_id)"];
    
    sqlite3_exec(db, [sql1 UTF8String], nil, nil, nil);
    sqlite3_exec(db, [sql2 UTF8String], nil, nil, nil);
    sqlite3_exec(db, [sql3 UTF8String], nil, nil, nil);
    sqlite3_exec(db, [sql4 UTF8String], nil, nil, nil);
    sqlite3_exec(db, [sql5 UTF8String], nil, nil, nil);
    sqlite3_exec(db, [sql6 UTF8String], nil, nil, nil);
}

-(QDXGameModel *)selectMylineWithMLid:(NSString *)myline_id
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM qdx_myline WHERE myline_id =  '%@'",myline_id];
    sqlite3_stmt *stmt = nil;
    int result =  sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        sqlite3_bind_text(stmt, 2, [myline_id UTF8String], -1, nil);
        QDXGameModel *myline = [QDXGameModel new];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            NSString  *line_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 1)];
            NSString *myline_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 2)];
            NSString *mstatus_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 3)];
            NSString *sdate = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 4)];
            NSString *score = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 5)];
            NSString *isLeader = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 6)];
            NSString *pointmap_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 7)];
            myline = [[QDXGameModel alloc] initWithL_id:line_id ML_id:myline_id MS_id:mstatus_id Sdate:sdate Score:score Isleader:isLeader P_mid:pointmap_id];
        }
        sqlite3_finalize(stmt);
        return myline;
    }else
    {
        sqlite3_finalize(stmt);
        return nil;
    }
}

-(void)modifyMyline:(QDXGameModel *)myline
{
    NSString *sql = [NSString stringWithFormat:@"UPDATE qdx_myline SET mstatus_id = '%@',sdate = '%@',score = '%@',pointmap_id = '%@' WHERE myline_id = '%@'",myline.mstatus_id,myline.sdate,myline.score,myline.pointmap_id,myline.myline_id];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        sqlite3_bind_text(stmt, 3, [myline.mstatus_id UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 4, [myline.sdate UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 5, [myline.score UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 7, [myline.pointmap_id UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 2, [myline.myline_id UTF8String], -1, nil);
        sqlite3_step(stmt);
    }else
    {
//        NSLog(@"修改失败");
    }
    sqlite3_finalize(stmt);
}

-(NSArray *)selectAllPointWithPid:(NSArray *)point_idArray
{
    sqlite3_stmt *stmt = nil;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM qdx_point WHERE point_id IN %@",point_idArray];
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        NSMutableArray *array = [NSMutableArray array];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            NSString  *point_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 1)];
            NSString *area_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 2)];
            NSString *LAT = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 3)];
            NSString *LON = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 4)];
            NSString *label = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 5)];
            NSString *point_name = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 6)];
            NSString *rssi = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 7)];
            QDXPointModel *point = [[QDXPointModel alloc] initWithP_id:point_id A_id:area_id LAT:LAT LON:LON Label:label P_name:point_name Rssi:rssi];
            [array addObject:point];
        }
        sqlite3_finalize(stmt);
        return array;
    }else
    {
        sqlite3_finalize(stmt);
        return nil;
    }
}

-(QDXPointModel *)selectPointWithPid:(NSString *)point_id
{
    NSString *sql = [NSString stringWithFormat:@"SELECT *FROM qdx_point WHERE point_id =  '%@'",point_id];
    sqlite3_stmt *stmt = nil;
    int result =  sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [point_id UTF8String], -1, nil);
        QDXPointModel *point = [QDXPointModel new];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            NSString  *point_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 1)];
            NSString *area_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 2)];
            NSString *LAT = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 3)];
            NSString *LON = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 4)];
            NSString *label = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 5)];
            NSString *point_name = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 6)];
            NSString *rssi = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 7)];
            point = [[QDXPointModel alloc] initWithP_id:point_id A_id:area_id LAT:LAT LON:LON Label:label P_name:point_name Rssi:rssi];
        }
        sqlite3_finalize(stmt);
        return point;
    }else
    {
        sqlite3_finalize(stmt);
        return nil;
    }
}

-(NSArray *)selectPointWithLid:(NSString *)line_id
{
    sqlite3_stmt *stmt = nil;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM qdx_line_point WHERE line_id ='%@' ORDER BY pindex ASC",line_id];
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        NSMutableArray *array = [NSMutableArray array];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            NSString  *line_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 1)];
            NSString *point_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 2)];
            NSString *pointmap_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 3)];
            NSString *pointmap_des = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 4)];
            NSString *pindex = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 5)];
            NSString *linetype_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 6)];
            line_pointModel *line_point = [[line_pointModel alloc] initWithL_id:line_id P_id:point_id P_mapid:pointmap_id P_mapdes:pointmap_des P_index:pindex l_typeid:linetype_id];
            [array addObject:line_point];
        }
        sqlite3_finalize(stmt);
        return array;
    }else
    {
        sqlite3_finalize(stmt);
        return nil;
    }
}

-(NSArray *)selectQuestionWithQid:(NSString *)pointmap_id
{
    sqlite3_stmt *stmt = nil;
    NSString *sql = [NSString stringWithFormat:@"SELECT *FROM qdx_question WHERE question_id IN (SELECT question_id FROM qdx_point_question WHERE pointmap_id = '%@')",pointmap_id];
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        NSMutableArray *array = [NSMutableArray array];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            //字符串类型,需要先进行UTF8转码
            NSString  *question_name = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 1)];
            NSString *qa = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 2)];
            NSString *qb = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 3)];
            NSString *qc = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 4)];
            NSString *qd = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 5)];
            NSString *qkey = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 6)];
            NSString *question_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 7)];
            QDXQuestionModel *qusetion = [[QDXQuestionModel alloc] initWithQName:question_name Qa:qa Qb:qb Qc:qc Qd:qd Qkey:qkey Qid:question_id];
            [array addObject:qusetion];
        }
        sqlite3_finalize(stmt);
        return array;
    }else
    {
        sqlite3_finalize(stmt);
        return nil;
    }
}

-(NSArray *)selectHistoryWithMLid:(NSString *)myline_id
{
    sqlite3_stmt *stmt = nil;
    NSString *sql = [NSString stringWithFormat:@"SELECT *FROM qdx_history WHERE myline_id = '%@' ORDER BY h_id ASC",myline_id];
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        NSMutableArray *array = [NSMutableArray array];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            //字符串类型,需要先进行UTF8转码
            NSString  *edate = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 1)];
            NSString *myline_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 2)];
            NSString *point_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 3)];
            NSString *score = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 4)];
            
            QDXHIstoryModel *history = [[QDXHIstoryModel alloc] initWithEdate:edate Myline_id:myline_id Point_id:point_id Score:score];
            [array addObject:history];
        }
        sqlite3_finalize(stmt);
        return array;
    }else
    {
        sqlite3_finalize(stmt);
        return nil;
    }
}

//查询所有   直接返回
-(NSArray *)selectAllQuestion
{
    sqlite3_stmt *stmt = nil;
    NSString *sql = @"SELECT *FROM qdx_question";
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        NSMutableArray *array = [NSMutableArray array];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            NSString  *question_name = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 1)];
            NSString *qa = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 2)];
            NSString *qb = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 3)];
            NSString *qc = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 4)];
            NSString *qd = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 5)];
            NSString *qkey = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 6)];
            NSString *question_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 7)];
            QDXQuestionModel *qusetion = [[QDXQuestionModel alloc] initWithQName:question_name Qa:qa Qb:qb Qc:qc Qd:qd Qkey:qkey Qid:question_id];
            [array addObject:qusetion];
        }
        sqlite3_finalize(stmt);
        return array;
    }else
    {
//        NSLog(@"查询失败");
        sqlite3_finalize(stmt);
        return nil;
    }
}

-(void)insertPoint:(QDXPointModel *)point
{
    sqlite3_stmt *stmt = nil;
    NSString *sql = @"INSERT INTO qdx_point (p_id,point_id,area_id,LAT,LON,label,point_name,rssi)VALUES(?,?,?,?,?,?,?,?)";
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt,nil);
    if (result == SQLITE_OK) {
        sqlite3_bind_text(stmt, 2, [point.point_id UTF8String], -1 , nil);
        sqlite3_bind_text(stmt, 3, [point.area_id UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 4, [point.LAT UTF8String], -1 , nil);
        sqlite3_bind_text(stmt, 5, [point.LON UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 6, [point.label UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 7, [point.point_name UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 8, [point.rssi UTF8String], -1, nil);
        sqlite3_step(stmt);
    }else
    {
//        NSLog(@"存入失败%d",result);
    }
    sqlite3_finalize(stmt);
}

-(void)insertLineAndPoint:(line_pointModel *)line_point
{
    sqlite3_stmt *stmt = nil;
    NSString *sql = @"INSERT INTO qdx_line_point (l_p_id,line_id,point_id,pointmap_id,pointmap_des,pindex,linetype_id)VALUES(?,?,?,?,?,?,?)";
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt,nil);
    if (result == SQLITE_OK) {
        sqlite3_bind_text(stmt, 2, [line_point.line_id UTF8String], -1 , nil);
        sqlite3_bind_text(stmt, 3, [line_point.point_id UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 4, [line_point.pointmap_id UTF8String], -1 , nil);
        sqlite3_bind_text(stmt, 5, [line_point.pointmap_des UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 6, [line_point.pindex UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 7, [line_point.linetype_id UTF8String], -1, nil);
        sqlite3_step(stmt);
    }else
    {
//        NSLog(@"存入失败%d",result);
    }
    sqlite3_finalize(stmt);
}

-(void)insertHistory:(QDXHIstoryModel *)history
{
    sqlite3_stmt *stmt = nil;
    NSString *sql = @"INSERT INTO qdx_history (h_id,edate,myline_id,point_id,score)VALUES(?,?,?,?,?)";
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt,nil);
    if (result == SQLITE_OK) {
        sqlite3_bind_text(stmt, 2, [history.edate UTF8String], -1 , nil);
        sqlite3_bind_text(stmt, 3, [history.myline_id UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 4, [history.point_id UTF8String], -1 , nil);
        sqlite3_bind_text(stmt, 5, [history.edate UTF8String], -1, nil);
        sqlite3_step(stmt);
    }else
    {
//        NSLog(@"存入失败%d",result);
    }
    sqlite3_finalize(stmt);
}

-(void)insertPointAndQuestion:(point_questionModel *)point_questions
{
    sqlite3_stmt *stmt = nil;
    NSString *sql = @"INSERT INTO qdx_point_question (p_q_id,question_id,pointmap_id)VALUES(?,?,?)";
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt,nil);
    if (result == SQLITE_OK) {
        sqlite3_bind_text(stmt, 2, [point_questions.question_id UTF8String], -1 , nil);
        sqlite3_bind_text(stmt, 3, [point_questions.pointmap_id UTF8String], -1, nil);
        sqlite3_step(stmt);
    }else
    {
//        NSLog(@"存入失败%d",result);
    }
    sqlite3_finalize(stmt);
}

//添加
-(void)insertQuestion:(QDXQuestionModel *)questions
{
    sqlite3_stmt *stmt = nil;
    NSString *sql = @"INSERT INTO qdx_question (q_id,question_name,qa,qb,qc,qd,qkey,question_id)VALUES(?,?,?,?,?,?,?,?)";
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt,nil);
    if (result == SQLITE_OK) {
        sqlite3_bind_text(stmt, 2, [questions.question_name UTF8String], -1 , nil);
        sqlite3_bind_text(stmt, 3, [questions.qa UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 4, [questions.qb UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 5, [questions.qc UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 6, [questions.qd UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 7, [questions.qkey UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 8, [questions.question_id UTF8String], -1, nil);
        sqlite3_step(stmt);
    }else
    {
//        NSLog(@"存入失败%d",result);
    }
    sqlite3_finalize(stmt);
}

-(void)insertMyLine:(QDXGameModel *)myline
{
    sqlite3_stmt *stmt = nil;
    NSString *sql = @"INSERT INTO qdx_myline (m_l_id,line_id,myline_id,mstatus_id,sdate,score,isLeader,pointmap_id)VALUES(?,?,?,?,?,?,?,?)";
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt,nil);
    if (result == SQLITE_OK) {
        sqlite3_bind_text(stmt, 2, [myline.line_id UTF8String], -1 , nil);
        sqlite3_bind_text(stmt, 3, [myline.myline_id UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 4, [myline.mstatus_id UTF8String], -1 , nil);
        sqlite3_bind_text(stmt, 5, [myline.sdate UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 6, [myline.score UTF8String], -1 , nil);
        sqlite3_bind_text(stmt, 7, [myline.isLeader UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 8, [myline.pointmap_id UTF8String], -1, nil);
        sqlite3_step(stmt);
    }else
    {
//        NSLog(@"存入失败%d",result);
    }
    sqlite3_finalize(stmt);
}

//查询单个   直接返回
-(QDXQuestionModel *)selectOneQuestion:(NSString *)question_id
{
    NSString *sql = [NSString stringWithFormat:@"SELECT *FROM qdx_question WHERE question_id = '%@'",question_id];
    sqlite3_stmt *stmt = nil;
    int result =  sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        
        sqlite3_bind_text(stmt, 7, [question_id UTF8String], -1, nil);
        
        QDXQuestionModel *question = [QDXQuestionModel new];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            question = [[QDXQuestionModel alloc] initWithQName:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)]
                                                            Qa:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)]
                                                            Qb:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)] Qc:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)] Qd:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)] Qkey:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)] Qid:[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 7)]];
        }
        
        sqlite3_finalize(stmt);
        return question;
    }else
    {
        sqlite3_finalize(stmt);
        return nil;
    }
}

-(NSArray *)selectQid:(NSString *)pointmap_id
{
    sqlite3_stmt *stmt = nil;
    NSString *sql = [NSString stringWithFormat:@"SELECT *FROM qdx_point_question WHERE pointmap_id = '%@'",pointmap_id];
    int result = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK) {
        NSMutableArray *array = [NSMutableArray array];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            NSString *question_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 1)];
            NSString *pointmap_id = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(stmt, 2)];
            point_questionModel *pointmap = [[point_questionModel alloc] initWithQ_id:question_id P_mapid:pointmap_id];;
            [array addObject:pointmap];
        }
        sqlite3_finalize(stmt);
        return array;
    }else
    {
        sqlite3_finalize(stmt);
        return nil;
    }
}

@end
