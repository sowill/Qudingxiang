//
//  LocationChoiceViewController.h
//  趣定向
//
//  Created by Air on 2017/3/6.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "BaseViewController.h"
@class City;

@protocol ChoseCityDelegate <NSObject>

@optional
-(void)choseCityPassValue:(City *)city;

@end

@interface LocationChoiceViewController : BaseViewController

/** delegate */
@property(nonatomic, weak)id<ChoseCityDelegate> delegate;

@property(nonatomic, copy) NSString *location;

@end
