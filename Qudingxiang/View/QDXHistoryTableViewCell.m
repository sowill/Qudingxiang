//
//  QDXHistoryTableViewCell.m
//  趣定向
//
//  Created by Air on 16/5/5.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXHistoryTableViewCell.h"
#import "QDXHIstoryModel.h"
#import "QDXPointModel.h"


@interface QDXHistoryTableViewCell()
{
    UILabel *pointName;
    UILabel *eDate;
    UILabel *useTime;
    UIImageView *lineViewTwo;
    UIImageView *lineViewOne;
    UIImageView *pointView;
}
@end

@implementation QDXHistoryTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"cellidentifier";
    QDXHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[QDXHistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        cell.imageView.image = [ToolView createImageWithColor:[UIColor whiteColor]];
        [cell createViews];
    }
    return cell;
}

-(void)createViews
{
    pointName = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, 145, 15)];
    pointName.textColor = [UIColor colorWithWhite:0.600 alpha:1.000];
    pointName.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:pointName];
    
    eDate = [[UILabel alloc] initWithFrame:CGRectMake(50, 20 + 15 + 10, 145, 30)];
    eDate.textColor = [UIColor colorWithWhite:0.600 alpha:1.000];
    eDate.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:eDate];
    
    useTime = [[UILabel alloc] initWithFrame:CGRectMake(QdxWidth - 10 - 120, 20 + 15 + 10, 120, 30)];
    useTime.textColor = [UIColor colorWithWhite:0.600 alpha:1.000];
    useTime.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:useTime];
    
    pointView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 20 + 5, 6, 7)];
    pointView.image = [UIImage imageNamed:@"到达点"];
    [self.contentView addSubview:pointView];
    
    lineViewOne = [[UIImageView alloc] initWithFrame:CGRectMake(25+2.5, 0, 1, 25)];
    lineViewOne.image = [UIImage imageNamed:@"到达线"];
    [self.contentView addSubview:lineViewOne];
    
    lineViewTwo = [[UIImageView alloc] initWithFrame:CGRectMake(25+2.5, 20+5 + 7, 1, 73 - (20 + 3 + 7))];
    lineViewTwo.image = [UIImage imageNamed:@"到达线"];
    [self.contentView addSubview:lineViewTwo];
}

-(void)setHistoryInfo:(QDXHIstoryModel *)HistoryInfo
{
    _HistoryInfo = HistoryInfo;
    pointName.text = [@"目标点标:  " stringByAppendingString:HistoryInfo.point.point_name];
    eDate.text = HistoryInfo.edate;
    useTime.text = [@"消耗时长:  " stringByAppendingString:[ToolView scoreTransfer:HistoryInfo.score]];
    NSRange srange = [_HistoryInfo.point.point_name rangeOfString:@"起"];
    if (srange.length >0){//包含
        [lineViewTwo removeFromSuperview];
    }
    
//    if ([_HistoryInfo.point.point_name isEqualToString:@"起点"]||[_HistoryInfo.point.point_name isEqualToString:@"起点点标"]) {
//    }
    
    NSRange erange = [_HistoryInfo.point.point_name rangeOfString:@"终"];
    if (erange.length >0){//包含
        [lineViewOne removeFromSuperview];
    }
}


@end
