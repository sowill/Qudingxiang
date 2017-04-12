//
//  QDXHistoryTableViewCell.m
//  趣定向
//
//  Created by Air on 16/5/5.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXHistoryTableViewCell.h"
#import "HIstoryModel.h"

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
    
    _viewHistory = [[UIButton alloc] initWithFrame:CGRectMake(QdxWidth - FitRealValue(48 + 40), 20, FitRealValue(48), FitRealValue(48))];
    [_viewHistory setBackgroundImage:[UIImage imageNamed:@"答题记录"] forState:UIControlStateNormal];
    [_viewHistory addTarget:self action:@selector(historyClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_viewHistory];
    
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

-(void)historyClick{
    if (self.historyBtnBlock) {
        self.historyBtnBlock();
    }
}

-(void)setHistoryInfo:(HistoryModel *)HistoryInfo
{
    _HistoryInfo = HistoryInfo;
    pointName.text = [@"目标点标:  " stringByAppendingString:HistoryInfo.pointmap_cn];
    eDate.text = HistoryInfo.mylineinfo_score;
    useTime.text = [@"消耗时长:  " stringByAppendingString:[ToolView scoreTransfer:HistoryInfo.mylineinfo_cdate]];
    NSRange srange = [_HistoryInfo.pointmap_cn rangeOfString:@"起"];
    if (srange.length >0){//包含
        [lineViewTwo removeFromSuperview];
    }
    
    NSRange erange = [_HistoryInfo.pointmap_cn rangeOfString:@"终"];
    if (erange.length >0){//包含
        [lineViewOne removeFromSuperview];
    }
}


@end
