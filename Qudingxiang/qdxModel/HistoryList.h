//
//  HistoryList.h
//  趣定向
//
//  Created by Air on 2017/3/28.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HistoryModel.h"

@interface HistoryList : NSObject

@property (nonatomic,copy) NSString *Code; //当前页
@property (nonatomic,strong) NSMutableArray *historyArray;//列表
-(id)initWithDic:(NSDictionary *) infoDict;

@end
