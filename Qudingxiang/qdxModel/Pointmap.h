//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface Pointmap: NSObject
@property (nonatomic,copy) NSString *pointmap_id; //编号
@property (nonatomic,copy) NSString *point_id; //点标
@property (nonatomic,copy) NSString *point_cn;
@property (nonatomic,copy) NSString *pointmap_cn; //点标别名
@property (nonatomic,copy) NSString *line_id; //线路名称
@property (nonatomic,copy) NSString *line_cn;
@property (nonatomic,copy) NSString *pointmap_index; //顺序
@property (nonatomic,copy) NSString *pointmap_team; //队员有效
@property (nonatomic,copy) NSString *onoff_cn;
@property (nonatomic,copy) NSString *pointmap_task; //任务描述
@property (nonatomic,copy) NSString *pointmap_key; //任务答案
@property (nonatomic,copy) NSString *pointmap_des; //导引描述
@property (nonatomic,copy) NSString *pointmap_pop; //提示图片
@property (nonatomic,copy) NSString *pointmap_show; //显示图片
@property (nonatomic,copy) NSString *pointmap_score; //分值
@property (nonatomic,copy) NSString *pointmap_time; //限时
@property (nonatomic,copy) NSString *pointmap_group; //分支组
@property (nonatomic,copy) NSString *pointmap_hascoupon; //是否有优惠券
@property (nonatomic,copy) NSString *pointmap_coupon; //优惠券
@property (nonatomic,copy) NSString *pointmap_coupontime; //有效期
@property (nonatomic,copy) NSString *pointmap_istask; //线下任务
-(id)initWithDic:(NSDictionary *) infoDict;
@end
