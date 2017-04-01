//
//  QDXTeamsViewController.m
//  Qudingxiang
//
//  Created by Air on 15/10/22.
//  Copyright © 2015年 Air. All rights reserved.
//

#import "QDXTeamsViewController.h"
#import "TeamList.h"
#import "TeamModel.h"
#import "UITextField+IndexPath.h"
#import "TextFieldTableViewCell.h"

#define TASKWEIGHT                         FitRealValue(560)
#define TASKHEIGHT                         FitRealValue(480)

@interface QDXTeamsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, strong) NSMutableArray *arrayDataSouce;

@property (nonatomic, strong) UIButton *completeBtn;

@property (nonatomic, strong) UIView* BGView; //遮罩

@property (nonatomic, strong) UIView* deliverView; //底部View

@property (nonatomic, strong) NSString *qrcdeString;

@end

@implementation QDXTeamsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupgetMyTeam];

    self.title = @"组队";
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
}

- (void)textFieldDidEndEditing:(NSNotification *)noti{

    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.tableView.frame;
        frame.origin.y = 0.0;
        self.tableView.frame = frame;
    }];
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(NSNotification *)noti{
    UITextField *textField=noti.object;
    NSIndexPath *indexPath = textField.indexPath;
    
    CGFloat offset = QdxHeight - (FitRealValue(120) * indexPath.row + textField.frame.size.height + 500);
    if (offset <= 0) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.tableView.frame;
            frame.origin.y = offset;
            self.tableView.frame = frame;
        }];
    }
}

- (void)textFieldDidChanged:(NSNotification *)noti{

    /// 数据源赋值
    UITextField *textField=noti.object;
    NSIndexPath *indexPath = textField.indexPath;
    
    if (indexPath.section == 1) {
        [self.arrayDataSouce replaceObjectAtIndex:indexPath.row withObject:textField.text];
    }else if (indexPath.section == 2){
        [self.arrayDataSouce replaceObjectAtIndex:(indexPath.row + 1) withObject:textField.text];
    }
}

#pragma marks - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 2) {
        return 5;
    }else{
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return FitRealValue(20);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

//二维码的frame
- (void)setupCreateView
{
    self.BGView                 = [[UIView alloc] init];
    self.BGView.frame           = [[UIScreen mainScreen] bounds];
    self.BGView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(BGViewClick)];
    [self.BGView addGestureRecognizer:tapGesture];
    [self.view addSubview:self.BGView];
    float codeHeight = TASKHEIGHT;

    self.deliverView                 = [[UIView alloc] init];
    self.deliverView.frame           = CGRectMake(QdxWidth/2 - TASKWEIGHT/2,(QdxHeight-64 - codeHeight)/2,TASKWEIGHT,codeHeight);
    self.deliverView.backgroundColor = [UIColor whiteColor];
    self.deliverView.layer.borderWidth = 1;
    self.deliverView.layer.cornerRadius = 8;
    self.deliverView.layer.borderColor = [[UIColor clearColor]CGColor];
    [self.view addSubview:self.deliverView];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0,FitRealValue(36), TASKWEIGHT, 20)];
    title.text = @"请队员扫描一下二维码组队";
    title.textColor = QDXBlack;
    title.font = [UIFont systemFontOfSize:14];
    title.textAlignment = NSTextAlignmentCenter;
    [self.deliverView addSubview:title];

    UIImageView *createCode = [[UIImageView alloc] initWithFrame:CGRectMake(FitRealValue(110), title.frame.origin.y + 20 + FitRealValue(36), FitRealValue(340), FitRealValue(340))];
    [createCode setImageWithURL:[NSURL URLWithString:_qrcdeString] placeholderImage:[UIImage imageNamed:@"加载中-1"]];
    [self.deliverView addSubview:createCode];
}

-(void)BGViewClick{
    [self.BGView removeFromSuperview];
    [self.deliverView removeFromSuperview];
}

-(void)clearBtnClick{
    NSString *url = [newHostUrl stringByAppendingString:teamqrcodeUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"myline_id"] = _myLineid;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        if ([responseObject[@"Code"] intValue] == 0) {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }else{
            _qrcdeString = responseObject[@"Msg"];
        }
        [self setupCreateView];
    } failure:^(NSError *error) {
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, FitRealValue(120))];
        lineView.backgroundColor = [UIColor whiteColor];
        [cell addSubview:lineView];
        
        UILabel *scanLabel = [[UILabel alloc] initWithFrame:CGRectMake(FitRealValue(30), 0, FitRealValue(200), FitRealValue(120))];
        scanLabel.textAlignment = NSTextAlignmentLeft;
        scanLabel.textColor = QDXBlack;
        scanLabel.font = [UIFont systemFontOfSize:16];
        scanLabel.text = @"扫一扫组队";
        [lineView addSubview:scanLabel];
        
        UIImageView *scanImageView = [[UIImageView alloc] initWithFrame:CGRectMake(QdxWidth - FitRealValue(30+48), FitRealValue(36), FitRealValue(48), FitRealValue(48))];
        scanImageView.image = [UIImage imageNamed:@"二维码"];
        [lineView addSubview:scanImageView];
        
        UIButton *clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, FitRealValue(120))];
        clearBtn.backgroundColor = [UIColor clearColor];
        [lineView addSubview:clearBtn];
        [clearBtn addTarget:self action:@selector(clearBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }else{
        static NSString *Id = @"HTextViewCell";
        TextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Id];
        if (!cell) {
            cell = [[TextFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Id];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textField.indexPath = indexPath;
        if (indexPath.section == 1) {
            cell.textField.text = _arrayDataSouce[indexPath.row];
            cell.textField.placeholder = @"请输入队伍名称";
            cell.titleLabel.text = @"队名：";
        }else if (indexPath.section == 2){
            cell.textField.placeholder = @"请输入昵称";
            if (indexPath.row == 0) {
                cell.titleLabel.text = @"队长：";
            }else{
                cell.titleLabel.text = @"队员：";
            }
            cell.textField.text = _arrayDataSouce[indexPath.row + 1];
        }
        
        return cell;
    }
}

#pragma mark - private
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

}

- (void)hiddenKeyBord{
    [self.view endEditing:YES];
}

#pragma marks- lazy
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, QdxWidth, QdxHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = QDXBGColor;
        _tableView.rowHeight = FitRealValue(120);
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBord)];
        [_tableView addGestureRecognizer:gesture];
    }
    return _tableView;
}

- (UIButton *)completeBtn{
    if (!_completeBtn) {
        _completeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, QdxHeight - FitRealValue(20 + 88) - 64, (QdxWidth - 20), 44)];
        [_completeBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_completeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        CGFloat top = 25; // 顶端盖高度
        CGFloat bottom = 25; // 底端盖高度
        CGFloat left = 5; // 左端盖宽度
        CGFloat right = 5; // 右端盖宽度
        UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
        // 指定为拉伸模式，伸缩后重新赋值
        [_completeBtn setBackgroundImage:[[UIImage imageNamed:@"sign_button"] resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        [_completeBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeBtn;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setupgetMyTeam{
    _arrayDataSouce = [NSMutableArray arrayWithCapacity:0];
    NSString *url = [newHostUrl stringByAppendingString:getTeamUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"myline_id"] = _myLineid;
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        if ([responseObject[@"Code"] intValue] == 0) {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }else{
            TeamList *teamList = [[TeamList alloc] initWithDic:responseObject];
            [_arrayDataSouce addObject:teamList.myline_team];
            for (TeamModel *team in teamList.teamArray) {
                [_arrayDataSouce addObject:team.team_cn];
            }
            if (teamList.teamArray.count < 5) {
                for (int i = 0; i < 5 - teamList.teamArray.count; i++) {
                    [_arrayDataSouce addObject:@""];
                }
            }
        }
        [self.view addSubview:self.tableView];
        
        [self.tableView addSubview:self.completeBtn];
    } failure:^(NSError *error) {
        
    }];
}

- (void)btnClick{
    NSString *url = [newHostUrl stringByAppendingString:setTeamUrl];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"myline_id"] = _myLineid;
    [self.arrayDataSouce enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *string = (NSString *)obj;
        if (string.length == 0) {
            NSLog(@"第%lu个位置元素为空", (unsigned long)idx);
        }else{
            NSLog(@"%@", obj);
            
            switch (idx) {
                case 0:
                    params[@"myline_team"] = obj;
                    break;
                case 1:
                    params[@"team_cn"] = obj;
                    break;
                case 2:
                    params[@"team_cn2"] = obj;
                    break;
                case 3:
                    params[@"team_cn3"] = obj;
                    break;
                case 4:
                    params[@"team_cn4"] = obj;
                    break;
                case 5:
                    params[@"team_cn5"] = obj;
                    break;
                    
                default:
                    break;
            }
        }
    }];
    
    [PPNetworkHelper POST:url parameters:params success:^(id responseObject) {
        
        if ([responseObject[@"Code"] intValue] == 0) {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
