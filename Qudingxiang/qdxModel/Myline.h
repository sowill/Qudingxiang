//Created by DCode on 2017-03-20 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface Myline: NSObject
@property (nonatomic,copy) NSString *myline_id; //编号
@property (nonatomic,copy) NSString *line_id; //线路
@property (nonatomic,copy) NSString *line_cn;
@property (nonatomic,copy) NSString *customer_id; //用户
@property (nonatomic,copy) NSString *customer_cn;
@property (nonatomic,copy) NSString *mylinest_id; //状态
@property (nonatomic,copy) NSString *mylinest_cn;
@property (nonatomic,copy) NSString *myline_adate; //开始时间
@property (nonatomic,copy) NSString *myline_score; //成绩
@property (nonatomic,copy) NSString *myline_ms; //毫秒
@property (nonatomic,copy) NSString *myline_team; //队名
@property (nonatomic,copy) NSString *myline_group; //分组
@property (nonatomic,copy) NSString *myline_preview; //浏览
@property (nonatomic,copy) NSString *myline_print; //打印码
-(id)initWithDic:(NSDictionary *) infoDict;
@end