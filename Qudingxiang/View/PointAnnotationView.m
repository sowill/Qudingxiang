//
//  PointAnnotationView.m
//  趣定向
//
//  Created by Air on 16/5/17.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "PointAnnotationView.h"


#define kCalloutWidth       80.0
#define kCalloutHeight      50.0

@interface PointAnnotationView ()

@property (nonatomic, strong, readwrite) PointView *point_View;

@end

@implementation PointAnnotationView

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    
    if (selected)
    {
        if (self.point_View == nil)
        {
            self.point_View = [[PointView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.point_View.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.point_View.bounds) / 2.f + self.calloutOffset.y);
        }
//        UIImageView *tempImageView = [[UIImageView alloc] init];
//        [tempImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostUrl,self.point_url]] placeholderImage:[UIImage imageNamed:@"加载中"] options:SDWebImageRefreshCached];
//        self.point_View.image = tempImageView.image;
        self.point_View.title = self.annotation.title;
        self.point_View.subtitle = self.annotation.subtitle;
        [self addSubview:self.point_View];
    }
    else
    {
        [self.point_View removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
}

-(instancetype)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        //在大头针旁边加一个label
        self.point_ID = [[UILabel alloc] initWithFrame:CGRectMake(5, -12, 20, 60)];
        self.point_ID.textAlignment = NSTextAlignmentCenter;
        self.point_ID.backgroundColor = [UIColor clearColor];
        self.point_ID.font = [UIFont fontWithName:@"Helvetica-Bold" size:10];
        self.point_ID.textColor = QDXBlack;
        [self addSubview:self.point_ID];
        
    }
    
    return self;
}

@end
