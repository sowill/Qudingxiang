//
//  QDXHomeCooperationCell.h
//  趣定向
//
//  Created by Air on 2017/3/6.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QDXHomeCooperationCell,QDXCooperationCollectionViewCell;

@protocol QDXCooperationCellDelegate <NSObject>

@optional
-(void)collectionViewDidSelectedItemIndexPath:(NSIndexPath *)indexPath collcetionView:(UICollectionView *)collectionView forCell:(QDXHomeCooperationCell *)cell;

@end

@interface QDXHomeCooperationCell : UITableViewCell

/** delegate */
@property(nonatomic, weak)id<QDXCooperationCellDelegate> delegate;

/** data */
@property(nonatomic, strong)NSArray *items;

+(instancetype)qdxCooperationWithTableView:(UITableView *)tableView;

@end
