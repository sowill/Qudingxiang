//
//  TeamModel.h
//  趣定向
//
//  Created by Air on 2017/3/29.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamModel : NSObject

@property (nonatomic,copy) NSString *myline_id;
@property (nonatomic,copy) NSString *team_cn;
@property (nonatomic,copy) NSString *team_id;
@property (nonatomic,copy) NSString *team_leader;
-(id)initWithDic:(NSDictionary *) infoDict;

@end
