//
//  TextFieldTableViewCell.m
//  趣定向
//
//  Created by Air on 2017/3/29.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "TextFieldTableViewCell.h"
#import "UITextField+IndexPath.h"

@interface  TextFieldTableViewCell()
@end

@implementation TextFieldTableViewCell

- (void)setTitleString:(NSString *)string andDataString:(NSString *)dataString andIndexPath:(NSIndexPath *)indexPath{
    // 核心代码
    self.textField.indexPath = indexPath;
    self.textField.text = dataString;
    self.titleLabel.text = string;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.textField];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (UITextField *)textField{
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake( FitRealValue(30) + 100, 0, QdxWidth - FitRealValue(30 + 30) - 100, FitRealValue(120))];
        _textField.placeholder = @"请输入";
        _textField.textAlignment = NSTextAlignmentRight;
        _textField.font = [UIFont systemFontOfSize:16];
    }
    return _textField;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(30), 0, 100, FitRealValue(120))];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = QDXBlack;
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
