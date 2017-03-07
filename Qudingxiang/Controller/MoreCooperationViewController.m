//
//  MoreCooperationViewController.m
//  趣定向
//
//  Created by Air on 2017/3/7.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "MoreCooperationViewController.h"
#import "LogoCollectionViewCell.h"

@interface MoreCooperationViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic, strong)UIButton *logoBtn;

@property(nonatomic, strong)UICollectionView *collectionView;

@end

static NSString *LogoReuseID = @"LogoReuseID";

@implementation MoreCooperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = QDXBGColor;
    
    self.navigationItem.title = @"合作单位";

    self.items = @[@"阿里体育logo",@"横店影视定向logo",@"驴妈妈logo",@"漫道logo",@"我要赞logo",@"阳澄湖半岛logo"];
    
    [self setupUI];
}

-(void)setupUI
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(FitRealValue(226), FitRealValue(140));
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 10 ;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(FitRealValue(20), FitRealValue(40), QdxWidth - FitRealValue(40), QdxHeight - FitRealValue(20)) collectionViewLayout:layout];
    self.collectionView.backgroundColor = QDXBGColor;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    //    self.collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0, 0);
    
    [self.collectionView registerClass:[LogoCollectionViewCell class] forCellWithReuseIdentifier:LogoReuseID];
    
    [self.view addSubview:self.collectionView];
}

-(void)setItems:(NSArray *)items{
    _items = items;
    
    [self.collectionView reloadData];
}

#pragma mark --------------------------------------------------
#pragma mark UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LogoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LogoReuseID forIndexPath:indexPath];
    cell.logo = self.items[indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
