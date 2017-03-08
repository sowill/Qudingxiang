//
//  QDXSlideHeaderView.m
//  趣定向
//
//  Created by Air on 2016/11/25.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "QDXSlideHeaderView.h"
#import "QDXSlideHeaderCell.h"

#import "QDXSlideView.h"

@interface QDXSlideHeaderView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong)UICollectionViewFlowLayout *flowLayout;

@property (nonatomic,strong)NSArray *titleAry;

@property (nonatomic,copy)HeaderCellClick headerCellClick;

@end

static NSString *QDXSlideHeaderCellIdentifier = @"QDXSlideHeaderCell";

@implementation QDXSlideHeaderView

- (instancetype)initWithFrame:(CGRect)frame titleAry:(NSArray *)titleAry
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleAry = [NSArray arrayWithArray:titleAry];
        [self setup];
    }
    return self;
}

// 设置子视图
- (void)setup{
    // 添加collectionView视图
    [self addSubview:self.collectionView];
}

// 初始化布局
- (UICollectionViewFlowLayout *)flowLayout{
    if (!_flowLayout) {
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.itemSize = CGSizeMake(self.frame.size.width / self.titleAry.count, self.frame.size.height);
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _flowLayout;
}

// 初始化collectionView
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
//        [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self registHelperCell];
        
    }
    return _collectionView;
}

- (void)registHelperCell{
    [self.collectionView registerClass:[QDXSlideHeaderCell class] forCellWithReuseIdentifier:QDXSlideHeaderCellIdentifier];
}

#pragma mark - collectionView的代理方法 -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.titleAry.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    QDXSlideHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:QDXSlideHeaderCellIdentifier forIndexPath:indexPath];
    if (indexPath.row == 0) {
        [self updateCellStatus:cell selected:YES];
    }
    cell.label.text = self.titleAry[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    QDXSlideHeaderCell *cell = (QDXSlideHeaderCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    //选中之后的cell变颜色
    [self updateCellStatus:cell selected:YES];
    
    if (self.headerCellClick) {
        self.headerCellClick(indexPath.row);
    }
}

//取消选中操作
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    QDXSlideHeaderCell *cell = (QDXSlideHeaderCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self updateCellStatus:cell selected:NO];
}

// 改变cell的背景颜色
-(void)updateCellStatus:(QDXSlideHeaderCell *)cell selected:(BOOL)selected
{
    cell.label.textColor = selected ? QDXBlue:QDXBlack;
//    cell.line.backgroundColor = selected ? QDXBlue:[UIColor whiteColor];
//    [UIView animateWithDuration:0.5f animations:^{
//        // 1. 用一个临时变量保存返回值。
//        CGRect temp = cell.line.frame;
//
//        // 2. 给这个变量赋值。因为变量都是L-Value，可以被赋值
//        temp.size.width = selected ? QdxWidth/2 : 0;
//        
//        // 3. 修改frame的值
//        cell.line.frame = temp;
//        
//    } completion:^(BOOL finished){
//        
//    }];
}

-(void)updateHeaderStateWithIndex:(NSIndexPath *)index withCollection:(UICollectionView *)collectionView withSelected:(BOOL)select
{
    QDXSlideHeaderCell *cell = (QDXSlideHeaderCell *)[collectionView cellForItemAtIndexPath:index];
    
    [self updateCellStatus:cell selected:select];
}

// 设置cell点击回调block
- (void)customHeaderCellClick:(HeaderCellClick)headerCellClick{
    self.headerCellClick = headerCellClick;
}

@end
