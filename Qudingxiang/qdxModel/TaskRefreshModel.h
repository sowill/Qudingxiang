//
//  TaskRefreshModel.h
//  趣定向
//
//  Created by Air on 2017/3/27.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskRefreshModel : NSObject

@property (nonatomic,copy) NSString *myline_adate;
@property (nonatomic,copy) NSString *myline_id;
@property (nonatomic,copy) NSString *mylinest_id;
@property (nonatomic,copy) NSString *pointmap_cn;
@property (nonatomic,copy) NSString *pointmap_mac;
@property (nonatomic,copy) NSString *pointmap_pop;
@property (nonatomic,copy) NSString *pointmap_rssi;
@property (nonatomic,copy) NSString *line_time;
@property (nonatomic,copy) NSString *linetype_id;

-(id)initWithDic:(NSDictionary *) infoDict;

@end
