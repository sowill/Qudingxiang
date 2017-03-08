//
//  QDXSlideCollectionViewCell.h
//  趣定向
//
//  Created by Air on 2016/11/25.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeModel;

typedef void(^TableViewCellClick)(HomeModel *homeModel);


@interface QDXSlideCollectionViewCell : UICollectionViewCell

@property (nonatomic,assign)NSInteger flag;

@property (nonatomic,strong)UITableView *tableView;

@property (nonatomic,strong)NSArray *homeModelArray;

- (void) coustomTableViewCellClick:(TableViewCellClick)tableViewCellClick;

@end
