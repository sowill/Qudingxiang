//Created by DCode on 2017-03-15 .
//Copyright © 2017 Shallvi. All rights reserved.  

#import <Foundation/Foundation.h>
#import "City.h"

@interface CityList: NSObject
@property (nonatomic,copy) NSString *count; //总条数
@property (nonatomic,copy) NSString *allpage; //总页数
@property (nonatomic,copy) NSString *curr; //当前页
@property (nonatomic,strong) NSMutableArray *cityArray;//列表
-(id)initWithDic:(NSDictionary *) infoDict;
@end
