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
    self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,FitRealValue(30),FitRealValue(166), FitRealValue(166))];
    self.coverImageView.tag = JPCoverImageViewTag;
    [self.contentView addSubview:self.coverImageView];
    
    self.coverLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,FitRealValue(166 + 30 + 20), FitRealValue(166), FitRealValue(30))];
    self.coverLabel.textColor = QDXBlack;
    self.coverLabel.font = [UIFont systemFontOfSize:14];
    self.coverLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.coverLabel];
}

-(void)setDataString:(NSString *)dataString{
    
    _dataString = dataString;
    
    self.coverImageView.image = [UIImage imageNamed:dataString];
    
    self.coverLabel.text = dataString;
    
//    [self.coverImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostUrl,dataString.good_url]] placeholderImage:[UIImage imageNamed:@"banner_cell"]];
    
//    self.coverLabel.text = dataString.goods_name;
}

@end
