//
//  QDXHomeCollectionView.m
//  趣定向
//
//  Created by Air on 2017/1/10.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "QDXHomeCollectionView.h"
#import "JPAnimationTool.h"
#import "HomeModel.h"

@interface QDXHomeCollectionView()

@end

@implementation QDXHomeCollectionView

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
    self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,FitRealValue(600), FitRealValue(400))];
    self.coverImageView.tag = JPCoverImageViewTag;
    [self.contentView addSubview:self.coverImageView];
}

-(void)setDataString:(HomeModel *)dataString{
    
    _dataString = dataString;
    
    [self.coverImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostUrl,dataString.good_url]] placeholderImage:[UIImage imageNamed:@"banner_cell"]];
}

@end
