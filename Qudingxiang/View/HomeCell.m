//
//  HomeCell.m
//  Qudingxiang
//
//  Created by Mac on 15/10/22.
//  Copyright © 2015年 Air. All rights reserved.
//

#import "HomeCell.h"
#import "CellModel.h"
@interface HomeCell()
{
    UILabel *_desLabel;
    UILabel *_nameLabel;
    UIImageView *_imageView;
}
@end

@implementation HomeCell

+ (instancetype)baseCellWithTableView:(UITableView *)tableView
{
    static NSString *cellID = @"ID";
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[HomeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        //添加cell的子控件
        [cell addSubViews];
    }
    return cell;
}

- (void)addSubViews
{
    _imageView = [ToolView createImageWithFrame:CGRectMake(15, 13, 35, 40)];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"j%i",arc4random()%6]];

    //[self.contentView addSubview:_imageView];
    _desLabel = [ToolView createLabelWithFrame:CGRectMake(70, 10, 100, 20) text:@"路线" font:15 superView:self.contentView];
    _desLabel.textColor = QDXBlack;
    _nameLabel = [ToolView createLabelWithFrame:CGRectMake(70, 30, 150, 32) text:@"名字" font:16 superView:self.contentView];
    _nameLabel.textColor = QDXGray;
}

- (void)setModel:(CellModel *)model
{
    _model = model;
    _desLabel.text = [NSString stringWithFormat:@"%@",model.line_name];
    _nameLabel.text = [NSString stringWithFormat:@"%@",model.line_sub];
    
    
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
