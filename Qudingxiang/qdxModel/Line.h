//Created by DCode on 2017-03-20 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface Line: NSObject
@property (nonatomic,copy) NSString *line_id; //编号
@property (nonatomic,copy) NSString *line_cn; //线路名称
@property (nonatomic,copy) NSString *linetype_id; //线路类型
 
@property (nonatomic,copy) NSString *line_number; //组队人数
@property (nonatomic,copy) NSString *line_pass; //全员通过

@property (nonatomic,copy) NSString *line_qrcode; //二维码有效

@property (nonatomic,copy) NSString *line_bind; //手机绑定

@property (nonatomic,copy) NSString *line_mapon; //地图显示

@property (nonatomic,copy) NSString *line_map; //地图
@property (nonatomic,copy) NSString *line_toplon; //上经度
@property (nonatomic,copy) NSString *line_toplat; //上纬度
@property (nonatomic,copy) NSString *line_botlon; //下经度
@property (nonatomic,copy) NSString *line_botlat; //下纬度
@property (nonatomic,copy) NSString *line_page; //准备页显示
@property (nonatomic,copy) NSString *utilstatus_id; //状态
 
@property (nonatomic,copy) NSString *line_cdate; //创建时间
@property (nonatomic,copy) NSString *area_id; //场地
 
-(id)initWithDic:(NSDictionary *) infoDict;
@end