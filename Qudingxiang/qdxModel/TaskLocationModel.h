//
//  TaskLocationModel.h
//  趣定向
//
//  Created by Air on 2017/3/27.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PointmapModel.h"

@interface TaskLocationModel : NSObject

@property (nonatomic,copy) NSString *line_botlat;
@property (nonatomic,copy) NSString *line_botlon;
@property (nonatomic,copy) NSString *line_id;
@property (nonatomic,copy) NSString *line_map;
@property (nonatomic,copy) NSString *line_mapon;
@property (nonatomic,copy) NSString *line_toplat;
@property (nonatomic,copy) NSString *line_toplon;
@property (nonatomic,strong) NSMutableArray *pointmapArray;//列表
-(id)initWithDic:(NSDictionary *) infoDict;

@end
