//
//  TeamList.h
//  趣定向
//
//  Created by Air on 2017/3/29.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TeamModel.h"

@interface TeamList : NSObject

@property (nonatomic,copy) NSString *Code;
@property (nonatomic,strong) NSMutableArray *teamArray;
@property (nonatomic,copy) NSString *myline_team;
-(id)initWithDic:(NSDictionary *) infoDict;

@end
