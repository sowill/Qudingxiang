//
//  DWViewCell.m
//  CardSlide
//
//  Created by DavidWang on 15/11/25.
//  Copyright © 2015年 DavidWang. All rights reserved.
//

#import "DWViewCell.h"

@interface DWViewCell ()

@end

@implementation DWViewCell

//- (void)awakeFromNib {
//    self.layer.cornerRadius = 5.0f;
//
//    CALayer *layer = [self layer];
//    layer.borderColor = [[UIColor lightGrayColor] CGColor];
//    layer.borderWidth = 1.0f;
//    
//    self.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.layer.shadowOffset = CGSizeMake(0, 0);
//    self.layer.shadowOpacity = 0.5;
//    self.layer.shadowRadius = 10.0;
//}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showImg = [[UIImageView alloc] initWithFrame:self.bounds];
        self.showImg.layer.cornerRadius = 5.0f;
        self.showImg.layer.masksToBounds = YES;
        [self.contentView addSubview:self.showImg];
    }
    return self;
}

@end
