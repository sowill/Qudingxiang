//
//  RecentActivityViewController.h
//  趣定向
//
//  Created by Air on 2017/3/17.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "BaseViewController.h"
@class Goods;

@protocol GoodsCellSelected <NSObject>

@optional
-(void)goodsCellSelectedWith:(Goods *)goods;

@end

@interface RecentActivityViewController : BaseViewController

@property (nonatomic,strong) NSString *cityId;

@property (nonatomic,strong) NSString *stateId;

@property (nonatomic,strong) NSString *typeId;

@property (nonatomic,weak)id<GoodsCellSelected> delegate;

@end
