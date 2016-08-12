//
//  PointAnnotationView.h
//  趣定向
//
//  Created by Air on 16/5/17.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "PointView.h"

@interface PointAnnotationView : MAAnnotationView

@property (nonatomic, readonly) PointView *point_View;
@property (nonatomic, strong) UILabel *point_ID;
//@property (nonatomic, strong) NSString *point_url;
@end
