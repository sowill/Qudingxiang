//
// QQ:896525689
// Email:zhangyuluios@163.com
//                 _
// /\   /\        | |
// \ \_/ / _   _  | |     _   _
//  \_ _/ | | | | | |    | | | |
//   / \  | |_| | | |__/\| |_| |
//   \_/   \__,_| |_|__,/ \__,_|
//
//  Created by shuogao on 16/5/27.
//  Copyright © 2016年 Yulu Zhang. All rights reserved.
//

#import "YLPopViewController.h"
#import "UITextView+YLTextView.h"
@interface YLPopViewController ()<UITextViewDelegate>
@property (nonatomic,strong) UILabel *titleLabel; //标题
@property (nonatomic,strong) UITextView *textView;//textview
@property (nonatomic,strong) UIButton *noButton;//取消
@property (nonatomic,strong) UIButton *yesButton;//确定
@property (nonatomic,strong) UILabel *placeHolderLabel;//占位字符
@property (nonatomic,strong) UILabel *wordCountLabel;//字数
@property (nonatomic,strong) UIWebView *web;//网页
@end

@implementation YLPopViewController

#pragma mark - define

#define BTN_MARGIN_BOTOOM 10 //按钮底部边距
#define BTN_MARGIN_LR 10 //按钮左右边距
#define BTN_MARGIN_MIDDLE 20 //按钮中间边距
#define BTN_HEIGHT 35 //按钮高度

#pragma mark - 懒加载初始化

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)dealloc {

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 控件创建

#pragma mark - getter / setter
- (void)addContentView {
    
    
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    self.contentView.center = self.view.center;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 5;
    [self.view addSubview:self.contentView];


    _web = [[UIWebView alloc] init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.qudingxiang.cn/home/Myline/getQuestionWeb/myline_id/%@/tmp/%@",mylineid,save]];
    [_web loadRequest:[NSURLRequest requestWithURL:url]];
    [self.contentView addSubview:_web];
/*
 *  底部按钮
 */


    self.noButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.yesButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.noButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.yesButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.yesButton setTintColor:[UIColor whiteColor]];
    [self.yesButton setBackgroundImage:[UIImage imageNamed:@"btn2"] forState:UIControlStateNormal];
    [self.noButton setBackgroundImage:[UIImage imageNamed:@"btn1"] forState:UIControlStateNormal];
    [self.noButton addTarget:self action:@selector(hidden:) forControlEvents:UIControlEventTouchUpInside];
    [self.yesButton addTarget:self action:@selector(touchYes:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.noButton];
    [self.contentView addSubview:self.yesButton];



    /*
     *  顶部label
     */


    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.center = self.contentView.center;
    self.titleLabel.font = [UIFont systemFontOfSize:15.];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    if (self.Title) {
        self.titleLabel.text = self.Title;
    }else {
        self.titleLabel.text = @"提示";
    }

    [self.contentView addSubview:self.titleLabel];


    /*
     *  中间textView
     */


    self.textView = [[UITextView alloc] init];
    self.textView.backgroundColor = [UIColor colorWithRed:240/255. green:240/255. blue:240/255. alpha:1.];
    self.textView.delegate = self;
    if (self.wordCount) {
        /**
         *  使用分类限制字数。此分类可以单独拿出去使用
         *  分类使用runtime完美解决字数限制。（包括难以解决的词语联想）
         */
        self.textView.limitLength = @(self.wordCount);
    }
    [self.contentView addSubview:self.textView];


    /*
     *  占位字符
     */
    self.placeHolderLabel = [[UILabel alloc] init];
    self.placeHolderLabel.hidden = NO;
    self.placeHolderLabel.font = [UIFont systemFontOfSize:13.];
    self.placeHolderLabel.textColor = [UIColor lightGrayColor];
    [self.textView addSubview:self.placeHolderLabel];

    if (self.placeHolder) {
        self.placeHolderLabel.text = self.placeHolder;
    }else {
        self.placeHolderLabel.text = @"请在此处输入内容";
    }


    /*
     *  字数记录
     */
    self.wordCountLabel = [[UILabel alloc] init];

    if (self.wordCount) {
        self.wordCountLabel.text = [NSString stringWithFormat:@"0/%ld",self.wordCount];
    }else {
        self.wordCountLabel.hidden = YES;
    }

    self.wordCountLabel.font = [UIFont systemFontOfSize:12.];
    self.wordCountLabel.textAlignment = NSTextAlignmentCenter;
    self.wordCountLabel.textColor = [UIColor lightGrayColor];
    [self.textView addSubview:self.wordCountLabel];



    /*
     *  出现的动画
     */

    [self setAnimation];



}

//出现的动画
- (void)setAnimation {

    [UIView animateWithDuration:0.3 animations:^{


        self.contentView.frame = CGRectMake(0, 0, self.contentViewSize.width, self.contentViewSize.height);
        self.contentView.center = self.view.center;
        self.contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];


    } completion:^(BOOL finished) {
        self.titleLabel.frame = CGRectMake(10, 10, self.contentViewSize.width - 20, 25);

        _web.frame = CGRectMake(10, 10 + 25, self.contentViewSize.width - 20, self.contentViewSize.height*.8 -BTN_HEIGHT -BTN_MARGIN_BOTOOM*2- 55);

        self.noButton.frame = CGRectMake(BTN_MARGIN_LR, CGRectGetHeight(self.contentView.frame) - BTN_HEIGHT - BTN_MARGIN_BOTOOM, CGRectGetWidth(self.contentView.frame) / 2 - BTN_MARGIN_LR - BTN_MARGIN_MIDDLE / 2, BTN_HEIGHT);

        self.yesButton.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) / 2 + BTN_MARGIN_MIDDLE / 2, CGRectGetHeight(self.contentView.frame) - BTN_HEIGHT - BTN_MARGIN_BOTOOM, CGRectGetWidth(self.contentView.frame) / 2 - BTN_MARGIN_LR - BTN_MARGIN_MIDDLE / 2, BTN_HEIGHT);


        self.textView.frame = CGRectMake(10, self.contentViewSize.height*.8-BTN_HEIGHT -BTN_MARGIN_BOTOOM*2, self.contentViewSize.width - 20, self.contentViewSize.height*.2);

        self.placeHolderLabel.frame = CGRectMake(5, 5, CGRectGetWidth(self.textView.frame), 20);

        self.wordCountLabel.frame = CGRectMake(CGRectGetWidth(self.textView.frame) - 60, CGRectGetHeight(self.textView.frame) - 20, 60, 20);
    }];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
    
    
}


#pragma mark - 消息触发事件
///键盘显示事件
- (void)keyboardWillShow:(NSNotification *)notification {


    //获取键盘高度，在不同设备上，以及中英文下是不同的

    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;

    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯

    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    float boudsHeight = [UIScreen mainScreen].bounds.size.height;
    //contentView底边距离键盘顶端的距离（有可能为负有可能为正）
    float margin = boudsHeight - CGRectGetMaxY(self.contentView.frame) - kbHeight;

    //将视图上移计算好的偏移
    NSLog(@"margin - %f",margin);

    if(margin < 0) {

        [UIView animateWithDuration:duration animations:^{

            CGRect newRect = CGRectMake(CGRectGetMinX(self.contentView.frame), CGRectGetMinY(self.contentView.frame) + margin, self.contentViewSize.width, self.contentViewSize.height);
            self.contentView.frame = newRect;

        }];


    }
}

///键盘消失事件
- (void)keyboardWillHide:(NSNotification *)notify {

    // 键盘动画时间

    double duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //视图下沉恢复原状

    [UIView animateWithDuration:duration animations:^{

        CGRect origionRect = self.contentView.frame;
        CGRect newRect = CGRectMake(origionRect.origin.x, origionRect.origin.y, self.contentViewSize.width, self.contentViewSize.height);
        self.contentView.frame = newRect;
        self.contentView.center = self.view.center;
        
        
    }];
}


//消失动画
- (void)hidden {

    self.textView.text = @"";

    [UIView animateWithDuration:0.3 animations:^{

        CGRect origionRect = self.contentView.frame;
        CGRect newRect = CGRectMake(origionRect.origin.x, origionRect.origin.y, 0, 0);
        self.contentView.frame = newRect;
        self.contentView.alpha = 0;
        self.contentView.center = self.view.center;

        [self.yesButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [self.noButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        self.noButton.frame = CGRectZero;
        self.yesButton.frame = CGRectZero;
        self.noButton.alpha = 0;
        self.yesButton.alpha = 0;

        [self.titleLabel removeFromSuperview];
        [self.placeHolderLabel removeFromSuperview];
        [self.wordCountLabel removeFromSuperview];
        self.textView.alpha = 0;

    } completion:^(BOOL finished) {
        //删除整个视图
        [self.view removeFromSuperview];

    }];
}
#pragma mark - 点击事件
//取消
-(void)hidden:(UIButton *)button {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    //消失动画
    [self hidden];

}
//确认
- (void)touchYes:(UIButton *)button {

    [self.textView resignFirstResponder];
    __typeof (self)weakSelf = self;
    if (self.confirmBlock) {
        
        weakSelf.confirmBlock(weakSelf.textView.text);
    }

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [self.textView resignFirstResponder];

}

#pragma mark - 原生控件代理  TextViewDelegate


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {


    self.placeHolderLabel.hidden = YES;

    if (textView.text.length == 1 && text.length == 0) {

        self.placeHolderLabel.hidden = NO;
    }

    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {

    if (self.wordCount) {

        NSInteger wordCount = textView.text.length;
        if (wordCount > self.wordCount) {
            wordCount = self.wordCount;
        }
        self.wordCountLabel.text = [NSString stringWithFormat:@"%ld/%lu",wordCount,self.wordCount];

    }

}


@end
