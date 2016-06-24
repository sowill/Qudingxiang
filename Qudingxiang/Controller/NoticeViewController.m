//
//  NoticeViewController.m
//  趣定向
//
//  Created by Prince on 16/4/19.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "NoticeViewController.h"
@interface NoticeViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    CGFloat _first;
    CGFloat _second;
    UIWebView *protocol;
}
@end

@implementation NoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"活动须知";
    //[self createTableView];
    protocol = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight)];
    protocol.backgroundColor = [UIColor clearColor];
    protocol.scrollView.showsVerticalScrollIndicator = FALSE;
    [self.view addSubview:protocol];
    [self setupProtocol];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(void)setupProtocol
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr. responseSerializer = [ AFHTTPResponseSerializer serializer ];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *url = [hostUrl stringByAppendingString:@"index.php/Home/Util/portocol"];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithDictionary:dict];
        [protocol loadHTMLString:infoDict[@"Msg"] baseURL:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
- (void)createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, QdxHeight-26) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    //_tableView.scrollEnabled = NO;
    _tableView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    [self.view addSubview:_tableView];
    
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ID";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if(indexPath.section == 0){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, QdxWidth-10, 50)];
        label.numberOfLines = 0;
        NSDictionary *attributesDic = [self settingAttributesWithLineSpacing:5 FirstLineHeadIndent:5 Font:[UIFont systemFontOfSize:14] TextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        label.attributedText = [[NSAttributedString alloc] initWithString:@"1.活动参与者请自行准备智能手机，手机版本ios7.0或andriod4.3以上。" attributes:attributesDic];
        [cell addSubview:label];
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, QdxWidth-10, 50)];
        label1.numberOfLines = 0;
        NSDictionary *attributesDic1 = [self settingAttributesWithLineSpacing:5 FirstLineHeadIndent:5 Font:[UIFont systemFontOfSize:14] TextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        label1.attributedText = [[NSAttributedString alloc] initWithString:@"2.活动参与者的年龄段为5~65岁，14岁以下儿童必须全程由家长陪同。" attributes:attributesDic1];
        [cell addSubview:label1];
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, QdxWidth-10, 50)];
        label2.numberOfLines = 0;
        NSDictionary *attributesDic2 = [self settingAttributesWithLineSpacing:5 FirstLineHeadIndent:5 Font:[UIFont systemFontOfSize:14] TextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        label2.attributedText = [[NSAttributedString alloc] initWithString:@"3.手机APP上一旦点击“活动开始”并确认，系统将自动进行记录，不允许退票或退款。" attributes:attributesDic2];
        [cell addSubview:label2];
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, QdxWidth-10, 50)];
        label3.numberOfLines = 0;
        NSDictionary *attributesDic3 = [self settingAttributesWithLineSpacing:5 FirstLineHeadIndent:5 Font:[UIFont systemFontOfSize:14] TextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        label3.attributedText = [[NSAttributedString alloc] initWithString:@"4.活动参与者所提供的信息须详实准确，并遵守活动规则，服从推送指令。" attributes:attributesDic3];
        [cell addSubview:label3];
        UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, QdxWidth-10, 50)];
        label4.numberOfLines = 0;
        NSDictionary *attributesDic4 = [self settingAttributesWithLineSpacing:5 FirstLineHeadIndent:5 Font:[UIFont systemFontOfSize:14] TextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        label4.attributedText = [[NSAttributedString alloc] initWithString:@"5.活动进行中，如果因为任何原因不想继续参与活动，可以中途退出，但无法获得完赛证书和成绩。" attributes:attributesDic4];
        [cell addSubview:label4];
        UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(10, 250, QdxWidth-10, 120)];
        label5.numberOfLines = 0;
        NSDictionary *attributesDic5 = [self settingAttributesWithLineSpacing:5 FirstLineHeadIndent:5 Font:[UIFont systemFontOfSize:14] TextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        label5.attributedText = [[NSAttributedString alloc] initWithString:@"6.活动参与者承诺身体健康，无以下疾病：a. 先天性心脏病和风湿性心脏病患者；b. 高血压和脑血管疾病患者；c. 心肌炎和其他心脏病患者；d. 冠状动脉病患者和严重心律不齐者；e. 血糖过高或过少的糖尿病。" attributes:attributesDic5];
        [cell addSubview:label5];
        UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(10, 370, QdxWidth-10, 50)];
        label6.numberOfLines = 0;
        NSDictionary *attributesDic6 = [self settingAttributesWithLineSpacing:5 FirstLineHeadIndent:5 Font:[UIFont systemFontOfSize:14] TextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        label6.attributedText = [[NSAttributedString alloc] initWithString:@"7.活动参与者自愿参加本活动，如因个人身体及其它个人原因导致的人身伤害和财产损失，由参与者个人承担责任。" attributes:attributesDic6];
        [cell addSubview:label6];
        
        UILabel *label7 = [[UILabel alloc] initWithFrame:CGRectMake(10, 420, QdxWidth-10, 50)];
        label7.numberOfLines = 0;
        NSDictionary *attributesDic7 = [self settingAttributesWithLineSpacing:5 FirstLineHeadIndent:5 Font:[UIFont systemFontOfSize:14] TextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        label7.attributedText = [[NSAttributedString alloc] initWithString:@"8.严禁恶意破坏与活动相关的各类基础设施，如经查实按照所损坏设施的两倍市场价格赔偿。" attributes:attributesDic7];
        [cell addSubview:label7];
        
        
    }else{
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, QdxWidth-10, 50)];
        label.numberOfLines = 0;
        NSDictionary *attributesDic = [self settingAttributesWithLineSpacing:5 FirstLineHeadIndent:5 Font:[UIFont systemFontOfSize:14] TextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        label.attributedText = [[NSAttributedString alloc] initWithString:@"1.如活动当天因为天气原因（下雨）活动无法正常进行则活动顺延，以提前一天电话。" attributes:attributesDic];
        CGFloat contentLabelHeight = [label.text boundingRectWithSize:CGSizeMake(QdxWidth-20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.height;
        [cell addSubview:label];
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, QdxWidth-10, 50)];
        label1.numberOfLines = 0;
        NSDictionary *attributesDic1 = [self settingAttributesWithLineSpacing:5 FirstLineHeadIndent:5 Font:[UIFont systemFontOfSize:14] TextColor:[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1]];
        label1.attributedText = [[NSAttributedString alloc] initWithString:@"2.如果因个人原因无法参加活动要求退款，须提前三天拨打报名电话，说明原因办理退款。" attributes:attributesDic1];
        CGFloat contentLabelHeight1 = [label1.text boundingRectWithSize:CGSizeMake(QdxWidth-20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.height;
        _second = contentLabelHeight1 +contentLabelHeight;
        CGRect cellFrame = [cell frame];
        cellFrame.size.height =_second;
        [cell setFrame:cellFrame];
        [cell addSubview:label1];
        
    }
    return cell;
}


- (NSDictionary *)settingAttributesWithLineSpacing:(CGFloat)lineSpacing FirstLineHeadIndent:(CGFloat)firstLineHeadIndent Font:(UIFont *)font TextColor:(UIColor *)textColor{
    //分段样式
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //行间距
    paragraphStyle.lineSpacing = lineSpacing;
    //首行缩进
    paragraphStyle.firstLineHeadIndent = firstLineHeadIndent;
    //富文本样式
    NSDictionary *attributeDic = @{
                                   NSFontAttributeName : font,
                                   NSParagraphStyleAttributeName : paragraphStyle,
                                   NSForegroundColorAttributeName : textColor
                                   };
    return attributeDic;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 480;
    }else{
        return 100;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, QdxWidth, 20)];
    view.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 10, QdxWidth, 41)];
    view1.backgroundColor = [UIColor whiteColor];
    [view addSubview:view1];
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(10, 40, QdxWidth, 1)];
    view2.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    [view1 addSubview:view2];
    if (section == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, QdxWidth, 20)];
        label.text = @"活动须知";
        label.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        [view1 addSubview:label];
    }else{
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, QdxWidth, 20)];
        label.text = @"注意事项";
        label.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        [view1 addSubview:label];
    }
    return view;
}
@end
