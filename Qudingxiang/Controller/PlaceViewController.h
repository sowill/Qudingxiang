//
//  PlaceViewController.h
//  趣定向
//
//  Created by Air on 2017/3/9.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "BaseViewController.h"

@interface PlaceViewController : BaseViewController

@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) NSString *navTitle;

@property (nonatomic, strong) NSMutableArray *cityArr;

@property (nonatomic, strong) NSString *cityId;

@end
