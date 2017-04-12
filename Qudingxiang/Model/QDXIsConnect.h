//
//  QDXIsConnect.h
//  Qudingxiang
//  Created by Air on 15/9/18.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>
@class line_pointModel;
@class QDXMap;

@interface QDXIsConnect : NSObject

/** 成功连接*/
@property (nonatomic,copy) NSString *Code;

/**
 *  详细信息
 */
@property (nonatomic, strong) NSDictionary *Msg;

/**
 *  所有点标
 */
@property (strong,nonatomic) NSMutableArray *All;

/**
 *  目标点标
 */
@property (strong,nonatomic) NSMutableArray *Unknown;

/**
 *  历史点标
 */
@property (strong,nonatomic) NSMutableArray *History;

/**
 *  地图信息
 */
@property (nonatomic, strong) QDXMap *MapPoint;

@end
