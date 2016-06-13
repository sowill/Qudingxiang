//
//  LineCell.m
//  Qudingxiang
//
//  Created by Mac on 15/9/18.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "LineCell.h"
#import "LineModel.h"
@interface LineCell()
{
    UILabel *_desLabel;
    UILabel *_nameLabel;
    UIImageView *_imageView;
    UIButton *_quickBtn;
    UIButton *_detailBtn;
    
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth,10)];
    view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    [self.contentView addSubview:view];
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (QdxHeight*0.114 )/2, 18, 18)];
    [_imageView setImage:[UIImage imageNamed:@"勾选默认"]];
    [self.contentView addSubview:_imageView];
    _quickBtn = [ToolView createButtonWithFrame:CGRectMake(0, 10, QdxWidth-80, QdxHeight*0.114-10) title:@"" backGroundImage:@"" Target:self action:@selector(quickbtnClicked) superView:self.contentView];
    _quickBtn.tag = 1;
    _desLabel = [ToolView createLabelWithFrame:CGRectMake(38, 10+QdxHeight*0.026, QdxWidth-70, QdxHeight*0.026) text:@"路线" font:15 superView:self.contentView];
    _desLabel.textColor = [UIColor colorWithRed:17/255.0f green:17/255.0f blue:17/255.0f alpha:1.0f];;
    _nameLabel = [ToolView createLabelWithFrame:CGRectMake(38, 10+QdxHeight*0.026*2+QdxHeight*0.018, QdxWidth - 70, QdxHeight*0.021) text:@"名字" font:12 superView:self.contentView];
    _nameLabel.textColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    _detailBtn = [ToolView createButtonWithFrame:CGRectMake(QdxWidth-80, 10, 70, QdxHeight*0.114 - QdxHeight*0.018/2) title:@"查看详情" backGroundImage:@"" Target:self action:@selector(btnClicked) superView:self.contentView];
    _detailBtn.titleEdgeInsets = UIEdgeInsetsMake(QdxHeight*0.114/2, 0, 0, 0);
    [_detailBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:153/255.0 blue:253/255.0 alpha:1] forState:UIControlStateNormal];
    _detailBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _detailBtn.tag = 2;
    if (QdxHeight >667) {
        _desLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _detailBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    
}

-(void)btnClicked{
    
    if(self.detailClick){
        self.detailClick();
    }
    
}

- (void)quickbtnClicked{
    if(self.quickClick){
        self.quickClick();
    }
    
}
- (void)setLineModel:(LineModel *)lineModel
{
    _lineModel = lineModel;
    _desLabel.text = [NSString stringWithFormat:@"%@",lineModel.line_name];
    _nameLabel.text = [NSString stringWithFormat:@"%@",lineModel.line_sub];
}

-(void)setSelect:(NSInteger)select{
    _select = select;
    if (_select ==0) {
        [_imageView setImage:[UIImage imageNamed:@"勾选默认"]];
    }else{
        [_imageView setImage:[UIImage imageNamed:@"勾选选中"]];
    }
    
}

-(void)setRow:(NSInteger)row{
    _row = row;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
