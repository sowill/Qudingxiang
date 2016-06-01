//
//  ActCell.m
//  Qudingxiang
//
//  Created by Mac on 15/9/22.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "ActCell.h"
#import "ActModel.h"

@interface ActCell()
{
    UILabel *_nameLabel;
    UIImageView *_imageView;
    UILabel *_detailLabel;
}
@end
@implementation ActCell

+ (instancetype)actCellWithTableView:(UITableView *)tableView
{
    static NSString *cellID = @"ID";
    ActCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[ActCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        //添加cell的子控件
        [cell addSubViews];
        
    }
    return cell;

}

- (void)addSubViews
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth,10)];
    view.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    [self.contentView addSubview:view];
//    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 10, QdxWidth, QdxWidth+32)];
//    view1.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
//    [self.contentView addSubview:view1];
    _imageView = [ToolView createImageWithFrame:CGRectMake(0, 10, QdxWidth, QdxWidth*0.59)];
    CALayer *layer = _imageView.layer;
    [layer setMasksToBounds:NO];
    [self.contentView addSubview:_imageView];
    CGFloat imageViewY = CGRectGetMaxY(_imageView.frame);
    _nameLabel = [ToolView createLabelWithFrame:CGRectMake(10, imageViewY+5, QdxWidth*3/4, 20) text:@"地点" font:14 superView:self.contentView];
    _nameLabel.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1];
    _detailLabel = [ToolView createLabelWithFrame:CGRectMake(QdxWidth*3/4-10, imageViewY+5, QdxWidth/4, 20) text:@"地址" font:14 superView:self.contentView];
    _detailLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1];
    
    
}

- (void)setModel:(ActModel *)model
{
    _model = model;
    [_imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",hostUrl,model.good_url]] placeholderImage:[UIImage imageNamed:@"banner_cell"]];
    _nameLabel.text = [NSString stringWithFormat:@"%@",model.goods_name];
    _detailLabel.text = [NSString stringWithFormat:@"%@",model.goodst[@"goodst_name"]];
    _detailLabel.textAlignment = NSTextAlignmentRight;
    if([model.goodst[@"goodst_name"] isEqualToString:@"查看"]){
       _detailLabel.textColor = [UIColor colorWithRed:0/255.0 green:153/255.0 blue:253/255.0 alpha:1];
    }else if([model.goodst[@"goodst_name"] isEqualToString:@"可购买"]){
        _detailLabel.textColor = [UIColor colorWithRed:255/255.0 green:81/255.0 blue:00/255.0 alpha:1];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
