//
//  MyAnnotation.h
//  趣定向
//
//  Created by Air on 16/8/9.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSInteger,PinType) {
    /**
     *  已过
     */
    HISTORY_POINT = 0,
    /**
     *  为到
     */
    TARGET_POINT,
    /**
     *  所有
     */
    ALL_POINT,
};

@interface MyAnnotation : NSObject<MKAnnotation>

@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,retain) NSNumber *type;

- (instancetype)initWithAnnotationModelWithDict:(NSDictionary *)dict;

@end
