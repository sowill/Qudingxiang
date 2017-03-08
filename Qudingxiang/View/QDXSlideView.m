//
//  QDXSlideView.m
//  趣定向
//
//  Created by Air on 2016/11/25.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXSlideView.h"
#import "QDXSlideCollectionViewCell.h"
#import "QDXSlideHeaderView.h"
#import "QDXOrdermodel.h"

@interface QDXSlideView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong)UICollectionView *collectionView;

@property (nonatomic,strong)UICollectionViewFlowLayout *flowLayout;

@property (nonatomic,strong)QDXSlideHeaderView *headerView;

@property (nonatomic,strong)NSArray *titleAry;

@property (nonatomic,strong)UIView *line;

@end

static NSString *identifier = @"UICollectionCell";

@implementation QDXSlideView

- (instancetype)initWithFrame:(CGRect)frame titleAry:(NSArray *)titleAry{
    if (self = [super initWithFrame:frame]) {
        self.titleAry = [NSArray arrayWithArray:titleAry];
        self.backgroundColor = QDXBGColor;
        [self setup];
    }
    return self;
}

// 设置子视图
- (void)setup{
    // 添加头视图
    [self addSubview:self.headerView];
    // 将collectionView添加在视图上
    [self addSubview:self.collectionView];
    
    [self addSubview:self.line];
}

-(UIView *)line{
    if (!_line) {
        self.line = [[UIView alloc] init];
        self.line.frame = CGRectMake(FitRealValue(24), FitRealValue(80) - 2, QdxWidth/2 - FitRealValue(24) , 2);
        self.line.backgroundColor = QDXBlue;
    }
    return _line;
}

// 设置布局样式
- (UICollectionViewFlowLayout *)flowLayout{
    if (!_flowLayout) {
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = CGSizeMake(QdxWidth, QdxHeight);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _flowLayout;
}

// 初始化左右滑动视图collection
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, FitRealValue(80), QdxWidth, QdxHeight - FitRealValue(80)) collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = QDXBGColor;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [self registHelperCell];
    }
    return _collectionView;
}


// 注册相关cell
- (void)registHelperCell{
    [self.collectionView registerClass:[QDXSlideCollectionViewCell class] forCellWithReuseIdentifier:identifier];
}

// 初始化头视图
- (UIView *)headerView{
    if (!_headerView) {
        self.headerView = [[QDXSlideHeaderView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, FitRealValue(80)) titleAry:self.titleAry];
        [self customHeaderViewClock];
    }
    return _headerView;
}

// 设置头部标题栏点击事件
- (void)customHeaderViewClock{
    [self.headerView customHeaderCellClick:^(NSInteger index) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionNone) animated:YES];
    }];
}

#pragma mark - collectionView的代理方法 -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (!self.titleAry) {return 0;}
    return self.titleAry.count;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [UIView animateWithDuration:0.1f animations:^{
        [self.headerView updateHeaderStateWithIndex:indexPath withCollection:self.headerView.collectionView withSelected:YES];
    }];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > QdxWidth/2) {
        [UIView animateWithDuration:0.1f animations:^{
            self.line.frame = CGRectMake(QdxWidth/2, FitRealValue(80) - 2, QdxWidth/2 - FitRealValue(24), 2);
        }];
    }else{
        [UIView animateWithDuration:0.1f animations:^{
            self.line.frame = CGRectMake(FitRealValue(24), FitRealValue(80) - 2, QdxWidth/2 - FitRealValue(24) , 2);
        }];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [UIView animateWithDuration:0.1f animations:^{
        [self.headerView updateHeaderStateWithIndex:indexPath withCollection:self.headerView.collectionView withSelected:NO];
    }];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    QDXSlideCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundColor = QDXBGColor;

    cell.flag = indexPath.row;
    
    cell.homeModelArray = self.homeModelArray;
    
    [cell coustomTableViewCellClick:^(HomeModel *homeModel){
        if (self.passWithValueBlock) {
            self.passWithValueBlock(homeModel);
        }
    }];
    
    return cell;
}

//- (void)customTableViewWillAppear:(TableViewWillAppear)tableViewWillAppear
//{
//    self.tableViewWillAppear = tableViewWillAppear;
//}

@end
