//
//  HomeModel.h
//  Qudingxiang
//
//  Created by Mac on 15/9/15.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeModel : NSObject
@property (nonatomic, strong) NSString *scrollIcon;
@property (nonatomic, strong) NSString *good_url;
@property (nonatomic, strong) NSString *goods_name;
@property (nonatomic, strong) NSString *goods_price;
@property (nonatomic, strong) NSString *goods_index;
@property (nonatomic, assign) NSInteger goods_level;
@property (nonatomic, strong) NSString *goods_id;
@property (nonatomic, strong) NSDictionary *line;
@property (nonatomic, strong) NSString *line_sub;
@property (nonatomic, strong) NSString *area_id;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *good_st;
@property (nonatomic, assign) CGFloat cellHeight;
@end

