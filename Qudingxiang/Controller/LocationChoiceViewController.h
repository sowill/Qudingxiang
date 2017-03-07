//
//  LocationChoiceViewController.h
//  趣定向
//
//  Created by Air on 2017/3/6.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "BaseViewController.h"

@protocol ChoseCityDelegate <NSObject>

@optional
-(void)choseCityPassValue:(NSString *)city;

@end

@interface LocationChoiceViewController : BaseViewController

/** data */
@property(nonatomic, strong)NSArray *items;

/** delegate */
@property(nonatomic, weak)id<ChoseCityDelegate> delegate;

@property(nonatomic, strong) NSString *location;

@end
