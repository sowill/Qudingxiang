//
//  MyAnnotation.m
//  趣定向
//
//  Created by Air on 16/8/9.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation

- (instancetype)initWithAnnotationModelWithDict:(NSDictionary *)dict{
    self = [super init];
    if (self) {
        
        self.coordinate = CLLocationCoordinate2DMake([dict[@"coordinate"][@"latitute"] doubleValue], [dict[@"coordinate"][@"longitude"] doubleValue]);
        self.title = dict[@"detail"];
        self.name = dict[@"name"];
        self.type = dict[@"type"];
        
    }
    return self;
}

@end
