//
//  SettingCell.m
//  趣定向
//
//  Created by Prince on 16/3/17.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "SettingCell.h"
@interface SettingCell()
{
    UILabel *_nameLabel;
    UILabel *_valueLabel;
    UIImageView *_imageView;
}
@end
@implementation SettingCell

- (void)awakeFromNib {
    // Initialization code
}

+ (instancetype)baseCellWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ID";
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[SettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        //添加cell的子控件
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if(indexPath.section == 0){
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(42, 11, 70, 21)];;
            nameLabel.text = @"清楚图片缓存";
            [cell addSubview:nameLabel];
            UIImageView *imageView = [ToolView createImageWithFrame:CGRectMake(14, 11, 20, 20)];
            imageView.backgroundColor = [UIColor clearColor];
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"j%i",arc4random()%5]];
            [cell addSubview:imageView];
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(QdxWidth*2/3, 10, QdxWidth/3, 64)];;
            float dataValue;
            valueLabel.text = [NSString stringWithFormat:@"%.2fMB",dataValue];
            [cell addSubview:valueLabel];
        }
      
    }
    return cell;

}


- (void)addExtraView
{
    _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(QdxWidth*2/3, 10, QdxWidth/3, 64)];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
