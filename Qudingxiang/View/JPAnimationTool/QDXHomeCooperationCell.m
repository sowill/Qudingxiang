//
//  QDXHomeCooperationCell.m
//  趣定向
//
//  Created by Air on 2017/3/6.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "QDXHomeCooperationCell.h"
#import "QDXCooperationCollectionViewCell.h"

@interface QDXHomeCooperationCell()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;

@end

static NSString *QDXHomeCooperationCellReuseID = @"QDXHomeCooperationCellReuseID";

@implementation QDXHomeCooperationCell

+(instancetype)qdxCooperationWithTableView:(UITableView *)tableView
{
    QDXHomeCooperationCell *cell = [tableView dequeueReusableCellWithIdentifier:QDXHomeCooperationCellReuseID];
    if (!cell) {
        cell = [[QDXHomeCooperationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:QDXHomeCooperationCellReuseID];

        [cell setup];
    }
    return cell;
}

-(void)setup{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize = CGSizeMake(FitRealValue(250), FitRealValue(120));
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0 ;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, FitRealValue(240)) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
//    self.collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0, 0);
    
    [self.collectionView registerClass:[QDXCooperationCollectionViewCell class] forCellWithReuseIdentifier:QDXHomeCooperationCellReuseID];
    
    [self.contentView addSubview:self.collectionView];
}

-(void)setItems:(NSMutableArray *)items{
    _items = items;
    [self.collectionView reloadData];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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
    
    if (self.items.count > 6) {
        return 6;
    }
    
    return self.items.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.items.count > 6) {
        QDXCooperationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:QDXHomeCooperationCellReuseID forIndexPath:indexPath];
        cell.dataString = self.items[indexPath.row];
        return cell;
    }
    
    QDXCooperationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:QDXHomeCooperationCellReuseID forIndexPath:indexPath];
    cell.dataString = self.items[indexPath.row];
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
