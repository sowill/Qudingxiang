//
//  QDXOrderInfoModel.h
//  趣定向
//
//  Created by Air on 16/1/21.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDXOrderInfoModel : NSObject
/*  订单数量*/
@property (nonatomic,assign) int count;
/*  当前页*/
@property (nonatomic,assign) int curr;
/*  数据*/
@property (nonatomic,strong) NSMutableArray *data;
/*  总页数*/
@property (nonatomic,assign) int page;

+(instancetype)OrderInfoWithDict:(NSDictionary *)dict;
-(instancetype)initWithDict:(NSDictionary *)dict;
@end
