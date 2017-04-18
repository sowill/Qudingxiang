//
//  LineCell.m
//  Qudingxiang
//
//  Created by Mac on 15/9/18.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "LineCell.h"
#import "Line.h"

@interface LineCell()
{
    UILabel *_desLabel;
    UILabel *_nameLabel;
    UIImageView *_imageView;
    UIButton *_quickBtn;
}
@end
@implementation LineCell
+ (instancetype)baseCellWithTableView:(UITableView *)tableView
{
    static NSString *cellID = @"ID";
    LineCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[LineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        //添加cell的子控件
        [cell addSubViews];
    }
    return cell;
}

- (void)addSubViews
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth,FitRealValue(20))];
    view.backgroundColor = QDXBGColor;
    [self.contentView addSubview:view];
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(FitRealValue(30), FitRealValue(47 + 20), 18, 18)];
    [_imageView setImage:[UIImage imageNamed:@"勾选默认"]];
    [self.contentView addSubview:_imageView];
    _quickBtn = [ToolView createButtonWithFrame:CGRectMake(0, 10, QdxWidth, FitRealValue(130)) title:@"" backGroundImage:@"" Target:self action:@selector(quickbtnClicked) superView:self.contentView];
    _quickBtn.tag = 1;
    _desLabel = [ToolView createLabelWithFrame:CGRectMake(FitRealValue(87),FitRealValue(20), QdxWidth-70, FitRealValue(130)) text:@"路线" font:17 superView:self.contentView];
    _desLabel.textColor = QDXBlack;
    _nameLabel = [ToolView createLabelWithFrame:CGRectMake(QdxWidth - FitRealValue(180 + 30), FitRealValue(20), FitRealValue(180), FitRealValue(130)) text:@"名字" font:15 superView:self.contentView];
    _nameLabel.textColor = QDXGray;
    
    if (QdxHeight >667) {
        _desLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.font = [UIFont systemFontOfSize:14];
    }
    
}

- (void)quickbtnClicked{
    if(self.quickClick){
        self.quickClick();
    }
    
}

-(void)setLine:(Line *)line
{
    _line = line;
    _desLabel.text = [NSString stringWithFormat:@"%@",line.line_cn];
    _nameLabel.text = [NSString stringWithFormat:@"%@",line.linetype_cn];
}

-(void)setSelect:(NSInteger)select{
    _select = select;
    if (_select ==0) {
        [_imageView setImage:[UIImage imageNamed:@"勾选默认"]];
    }else{
        [_imageView setImage:[UIImage imageNamed:@"勾选选中"]];
    }
    
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
