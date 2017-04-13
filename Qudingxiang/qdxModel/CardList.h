//
//  CardList.h
//  趣定向
//
//  Created by Air on 2017/4/12.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CardModel.h"

@interface CardList : NSObject
@property (nonatomic,copy) NSString *count; //总条数
@property (nonatomic,copy) NSString *allpage; //总页数
@property (nonatomic,copy) NSString *curr; //当前页
@property (nonatomic,strong) NSMutableArray *cardArray;//列表
-(id)initWithDic:(NSDictionary *) infoDict;
@end
