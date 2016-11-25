//
//  QDXSlideHeaderCell.m
//  趣定向
//
//  Created by Air on 2016/11/25.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXSlideHeaderCell.h"

@implementation QDXSlideHeaderCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}

-(void)setup
{
    self.label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [UIFont systemFontOfSize:12];
//    _label.layer.borderWidth = 1;
//    _label.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.contentView addSubview:_label];
}

@end
