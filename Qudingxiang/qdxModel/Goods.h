//Created by DCode on 2017-03-16 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>

@interface Goods: NSObject
@property (nonatomic,copy) NSString *goods_id; //编号
@property (nonatomic,copy) NSString *goods_cn; //名称
@property (nonatomic,copy) NSString *goods_index; //顺序
@property (nonatomic,copy) NSString *goods_topshow; //首页显示
@property (nonatomic,copy) NSString *onoff_cn;
@property (nonatomic,copy) NSString *goodstatus_id; //状态
@property (nonatomic,copy) NSString *goodstatus_cn;
@property (nonatomic,copy) NSString *goods_price; //价格
@property (nonatomic,copy) NSString *goods_url; //图片
@property (nonatomic,copy) NSString *goods_flag; //含门票
@property (nonatomic,copy) NSString *goods_des; //详情
@property (nonatomic,copy) NSString *goods_notice; //须知
@property (nonatomic,copy) NSString *goods_prompt; //提示
@property (nonatomic,copy) NSString *goods_time; //时间
@property (nonatomic,copy) NSString *goods_address; //地点
@property (nonatomic,copy) NSString *line_id; //线路
@property (nonatomic,copy) NSString *line_cn;
@property (nonatomic,copy) NSString *goods_preview; //浏览
@property (nonatomic,copy) NSString *goods_cdate; //创建时间
@property (nonatomic,copy) NSString *goodstype_id; //发布类型
@property (nonatomic,copy) NSString *goodstype_cn;
-(id)initWithDic:(NSDictionary *) infoDict;
@end
