//
//  MineCell.m
//  Qudingxiang
//
//  Created by Mac on 15/10/10.
//  Copyright © 2015年 Air. All rights reserved.
//

#import "MineCell.h"
#import "MineModel.h"
@interface MineCell()
{
    UILabel *_desLabel;
    UILabel *_nameLabel;
    UILabel *_statusLabel;
    UIImageView *_imageView;
}
@end
@implementation MineCell

+ (instancetype)baseCellWithTableView:(UITableView *)tableView
{
    static NSString *cellID = @"ID";
    MineCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[MineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        //添加cell的子控件
        [cell addSubViews];
    }
    return cell;
    
}

- (void)addSubViews
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, 10)];
    view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    [self.contentView addSubview:view];
    _imageView = [ToolView createImageWithFrame:CGRectMake(0, 10, QdxHeight*0.13, QdxHeight*0.13)];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.image = [UIImage imageNamed:@""];
    CALayer *lay  = _imageView.layer;//获取ImageView的层
    [lay setMasksToBounds:NO];
    //[lay setCornerRadius:45.0];
    [self.contentView addSubview:_imageView];
    _desLabel = [ToolView createLabelWithFrame:CGRectMake(QdxHeight*0.13 + 10, 10+QdxHeight*0.026, QdxWidth-30, 20) text:@"路线" font:17 superView:self.contentView];
    _desLabel.textColor = [UIColor colorWithRed:17/255.0f green:17/255.0f blue:17/255.0f alpha:1.0f];
    _nameLabel = [ToolView createLabelWithFrame:CGRectMake(QdxHeight*0.13 + 10, QdxHeight*0.13-QdxHeight*0.026-10, QdxWidth-30, 20) text:@"名字" font:15 superView:self.contentView];
    _nameLabel.textColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    UIImageView *rightView = [[UIImageView alloc] init];
    rightView.frame = CGRectMake(QdxWidth - 16, 10+QdxHeight*0.13/2-5, 6, 10);
    rightView.image = [UIImage imageNamed:@"activity_arrow"];
    [self.contentView addSubview:rightView];
}

- (void)setModel:(MineModel *)model
{
    _model = model;
    _desLabel.text = [NSString stringWithFormat:@"%@",model.line[@"line_name"]];
    _nameLabel.text = [NSString stringWithFormat:@"%@",model.line[@"line_sub" ]];
    _statusLabel.text = [NSString stringWithFormat:@"%@",model.mstatus[@"mstatus_name"]];
    if([model.mstatus[@"mstatus_id"] isEqualToString:@"4"]){
        _imageView.image = [UIImage imageNamed:@"强制结束"];
    }else if([model.mstatus[@"mstatus_id"] isEqualToString:@"1"]){
        _imageView.image = [UIImage imageNamed:@"未开始"];
    }else if([model.mstatus[@"mstatus_id"] isEqualToString:@"3"]){
        _imageView.image = [UIImage imageNamed:@"已完成"];
    }else if([model.mstatus[@"mstatus_id"] isEqualToString:@"5"]){
        _imageView.image = [UIImage imageNamed:@"超时结束"];
    }else if([model.mstatus[@"mstatus_id"] isEqualToString:@"2"]){
        _imageView.image = [UIImage imageNamed:@"活动中"];
    }
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
