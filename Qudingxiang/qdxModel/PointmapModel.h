//
//  PointmapModel.h
//  趣定向
//
//  Created by Air on 2017/3/27.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PointmapModel : NSObject

@property (nonatomic,copy) NSString *point_lat;
@property (nonatomic,copy) NSString *point_lon;
@property (nonatomic,copy) NSString *pointmap_cn;

-(id)initWithDic:(NSDictionary *) infoDict;

@end
