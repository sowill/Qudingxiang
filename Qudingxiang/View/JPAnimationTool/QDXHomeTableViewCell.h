//
//  QDXHomeTableViewCell.h
//  趣定向
//
//  Created by Air on 2017/1/10.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QDXHomeTableViewCell, QDXHomeCollectionView;

@protocol QDXHomeTableViewCellDelegate <NSObject>

@optional
-(void)collectionViewDidSelectedItemIndexPath:(NSIndexPath *)indexPath collcetionView:(UICollectionView *)collectionView forCell:(QDXHomeTableViewCell *)cell;

@end

@interface QDXHomeTableViewCell : UITableViewCell

/** delegate */
@property(nonatomic, weak)id<QDXHomeTableViewCellDelegate> delegate;

/** data */
@property(nonatomic, strong)NSArray *items;

+(instancetype)qdxHomeCellWithTableView:(UITableView *)tableView;

@end
