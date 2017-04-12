//
//  HistoryModel.h
//  趣定向
//
//  Created by Air on 2017/3/28.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryModel : NSObject

@property (nonatomic,copy) NSString *mylineinfo_cdate;
@property (nonatomic,copy) NSString *mylineinfo_score;
@property (nonatomic,copy) NSString *pointmap_cn;
@property (nonatomic,copy) NSString *pointmap_id;
-(id)initWithDic:(NSDictionary *) infoDict;
@end
