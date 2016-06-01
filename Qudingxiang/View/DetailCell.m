//
//  DetailCell.m
//  Qudingxiang
//
//  Created by Air on 15/9/28.
//  Copyright (c) 2015年 Air. All rights reserved.
//

#import "DetailCell.h"
#import "QDXDetailsModel.h"

@interface DetailCell()
{
    UITextView *details;
}
@end

@implementation DetailCell

+ (instancetype)baseCellWithTableView:(UITableView *)tableView
{
    static NSString *cellID = @"ID";
    DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[DetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        //添加cell的子控件
        [cell addSubviews];
    }
    
    return cell;
}

-(void)addSubviews
{
    details = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 290, 290)];
    details.editable = NO;
    details.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    details.font = [UIFont fontWithName:@"Arial" size:15.0f];
    details.textColor = [UIColor grayColor];
    //    details.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:details];
}

-(void)setDetailModel:(QDXDetailsModel *)detailModel
{
    _detailModel = detailModel;
    details.text = detailModel.descript;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
