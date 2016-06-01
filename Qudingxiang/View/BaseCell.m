//
//  BaseCell.m
//  Qudingxiang
//
//  Created by Mac on 15/9/16.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "BaseCell.h"
#import "HomeModel.h"


@interface BaseCell()
{
    //旧UI
    UILabel *_titleLabel;
    UIImageView *_imageView;
    UILabel *_descriptionLabel;
    UILabel *_addresslabel;
    
    //新UI
    UIImageView *_imageViewN;
    UILabel *_nameLabel;
    UILabel *_priceLabel;
    UILabel *_indexLabel;
    UILabel *_parkNamelabel;
    UIImageView *_starView;
    NSInteger _index;
    UIImageView *_starViewNormal;
}
@end
@implementation BaseCell

+ (instancetype)baseCellWithTableView:(UITableView *)tableView
{
    static NSString *cellID = @"ID";
    BaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        //cell = [[BaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        if(!cell){
            cell = [[BaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        //添加cell的子控件
        [cell addSubViewsNew];
        
    }
    return cell;

}


- (void)addSubViewsNew
{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, 10)];
//    view.backgroundColor = [UIColor colorWithRed:232/255.0 green:236/255.0 blue:241/255.0 alpha:0.5];
//    [self.contentView addSubview:view];
//    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, QdxWidth*2/3, QdxWidth/2)];
//    bgView.backgroundColor = [UIColor colorWithRed:120/255.0 green:214/255.0 blue:252/255.0 alpha:1];
    _imageViewN = [ToolView createImageWithFrame:CGRectMake(10, 10, 70, 70)];
    CALayer *layer = _imageViewN.layer;
    [layer setMasksToBounds:NO];
    [self.contentView  addSubview:_imageViewN];
    CGFloat imageViewY = CGRectGetMaxY(_imageViewN.frame);
    _parkNamelabel = [ToolView createLabelWithFrame:CGRectMake(imageViewY+10, 10, QdxWidth, 20) text:@"公园名称" font:15 superView:self.contentView];
    CGFloat parkLabelMaxY = CGRectGetMaxY(_parkNamelabel.frame);
    _parkNamelabel.textAlignment = NSTextAlignmentLeft;
    _parkNamelabel.backgroundColor = [UIColor whiteColor];
    _parkNamelabel.font = [UIFont systemFontOfSize:15];
    _parkNamelabel.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1];
    
    _priceLabel = [ToolView createLabelWithFrame:CGRectMake(imageViewY+10, parkLabelMaxY+5, QdxWidth, 20) text:@"¥" font:18 superView:self.contentView];
    _priceLabel.textAlignment = NSTextAlignmentLeft;
    _priceLabel.font = [UIFont systemFontOfSize:15];
    _priceLabel.backgroundColor = [UIColor whiteColor];
    _priceLabel.textColor = [UIColor colorWithRed:255/255.0 green:81/255.0 blue:0/255.0 alpha:1];
    CGFloat priceLabelMaxY = CGRectGetMaxY(_priceLabel.frame);
    
    _nameLabel = [ToolView createLabelWithFrame:CGRectMake(imageViewY+10, priceLabelMaxY+5, QdxWidth/4, 20) text:@"项目名称" font:15 superView:self.contentView];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    _nameLabel.font = [UIFont systemFontOfSize:13];
    _nameLabel.backgroundColor = [UIColor whiteColor];
    _nameLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    
}
- (void)setHomeModel:(HomeModel *)homeModel
{
    _homeModel = homeModel;
    _nameLabel.text = [NSString stringWithFormat:@"%@",homeModel.line[@"line_sub"]];
    _parkNamelabel.text = [NSString stringWithFormat:@"%@",homeModel.goods_name];
    _priceLabel.text = [NSString stringWithFormat:@"¥ %@",homeModel.goods_price];
    [_imageViewN setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostUrl,homeModel.good_url]] placeholderImage:[UIImage imageNamed:@"banner_cell"]];
    _index = homeModel.goods_level;
    for (NSInteger i = 0; i<_index;i++){
        _starView = [ToolView createImageWithFrame:CGRectMake(QdxWidth-25-17*i, 60+5, 15, 15)];
        _starView.backgroundColor = [UIColor whiteColor];
        _starView.image = [UIImage imageNamed:@"index_star"];
        CALayer *layerStar = _starView.layer;
        [layerStar setMasksToBounds:NO];
        [self.contentView  addSubview:_starView];
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
