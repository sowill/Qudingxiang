//
//  QDXSlideCollectionViewCell.h
//  趣定向
//
//  Created by Air on 2016/11/25.
//  Copyright © 2016年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QDXOrdermodel;

typedef void(^SignInClick)();

typedef void(^TableViewCellClick)(QDXOrdermodel *order);


@interface QDXSlideCollectionViewCell : UICollectionViewCell

@property (nonatomic,assign)NSInteger flag;

@property (nonatomic,strong)UITableView *tableView;

- (void)tableViewWillAppear;

- (void) coustomSignInClick:(SignInClick)signinClick;

- (void) coustomTableViewCellClick:(TableViewCellClick)tableViewCellClick;

@end
