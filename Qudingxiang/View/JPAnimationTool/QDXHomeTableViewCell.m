//
//  QDXHomeTableViewCell.m
//  趣定向
//
//  Created by Air on 2017/1/10.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "QDXHomeTableViewCell.h"
#import "QDXHomeCollectionView.h"

@interface QDXHomeTableViewCell()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;

@end

static NSString *QDXCollectionViewReuseID = @"QDXCollectionViewResuseID";

@implementation QDXHomeTableViewCell

+(instancetype)qdxHomeCellWithTableView:(UITableView *)tableView
{
    QDXHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:QDXCollectionViewReuseID];
    if (!cell) {
        cell = [[QDXHomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:QDXCollectionViewReuseID];
        [cell setup];
    }
    return cell;
}

-(void)awakeFromNib{
    [super awakeFromNib];

}

-(void)setup{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize = CGSizeMake(QdxWidth*3.0/4.0, 236);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0 ;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, 236) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0, 0);
    
    [self.collectionView registerClass:[QDXHomeCollectionView class] forCellWithReuseIdentifier:QDXCollectionViewReuseID];
    
    [self.contentView addSubview:self.collectionView];
}

-(void)setItems:(NSArray *)items{
    _items = items;
    [self.collectionView reloadData];
}

#pragma mark --------------------------------------------------
#pragma mark UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(collectionViewDidSelectedItemIndexPath:collcetionView:forCell:)]) {
        [self.delegate collectionViewDidSelectedItemIndexPath:indexPath collcetionView:collectionView forCell:self];
    }
}

#pragma mark --------------------------------------------------
#pragma mark UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    QDXHomeCollectionView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:QDXCollectionViewReuseID forIndexPath:indexPath];
    cell.dataString = self.items[indexPath.row];
    return cell;
}

@end
