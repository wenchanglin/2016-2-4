//
//  FeedBackViewController.m
//  歌力思
//
//  Created by wen on 16/7/26.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "FeedBackViewController.h"
#import "UIPlaceHolderTextView.h"
#import "UIHyperlinksButton.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "Masonry.h"
#import "UseViewController.h"
#import "ErrorViewController.h"
@interface FeedBackViewController ()<UITextViewDelegate,MFMailComposeViewControllerDelegate>
@property(nonatomic,strong)UIBarButtonItem * doneButton;
@property(nonatomic,strong)UIPlaceHolderTextView * textView;
@property(nonatomic,strong) UIButton * registerButton;
@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //设置导航栏的返回按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = item;
    //更改导航栏的返回图标"<"的颜色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"#CCCCCC"];
     _doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringCN(@"wancheng", @"") style:UIBarButtonItemStylePlain target:self action:@selector(DoneButtonPress)];
    [self initViews];
}
- (void)DoneButtonPress {
    [_textView resignFirstResponder];
    
    self.navigationItem.rightBarButtonItem = nil;
}
-(void)initViews
{
    UILabel *tip1 = [[UILabel alloc] init];
    [self.view addSubview:tip1];
    tip1.text = NSLocalizedStringCN(@"commitfeedbacktip1", @"");
    tip1.textColor = [AppConstants themeColor];
    tip1.numberOfLines = 1;

    _textView = [[UIPlaceHolderTextView alloc]init];
     [self.view addSubview:_textView];
    _textView.textColor = [UIColor blackColor];//设置textview里面的字体颜色
    _textView.font = [UIFont fontWithName:@"Arial" size:13.0];//设置字体名字和字体大小
    _textView.delegate = self;//设置它的委托方法
    _textView.backgroundColor = [UIColor whiteColor];//设置它的背景颜色
    _textView.returnKeyType = UIReturnKeyDefault;//返回键的类型
    _textView.keyboardType = UIKeyboardTypeDefault;//键盘类型
    _textView.scrollEnabled = YES;//是否可以拖动
    _textView.placeholder = NSLocalizedStringCN(@"feedbackplaceholder", @"");
    _textView.placeholderColor = [UIColor grayColor];
    [tip1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(40);
        make.left.equalTo(self.view).with.offset(30);
        make.right.equalTo(self.view).with.offset(30);
    }];

    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tip1.mas_bottom).with.offset(10);
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.height.mas_equalTo([AppConstants uiScreenHeight] / 7 * 2);
    }];
    _registerButton = [[UIButton alloc]init];//WithFrame:CGRectMake(30, CGRectGetMaxY(_textView.frame)+5, [UIScreen mainScreen].bounds.size.width-60,40)];
    [self.view addSubview:_registerButton];
    [_registerButton setTitle:NSLocalizedStringCN(@"commitfeedback", @"") forState:UIControlStateNormal];
    _registerButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [_registerButton setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    [_registerButton addTarget:self action:@selector(commit) forControlEvents:UIControlEventTouchUpInside];
    _registerButton.backgroundColor = [UIColor colorWithHexString:@"#FFCC33"];
    [_registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_textView.mas_bottom).with.offset(20);
        make.left.equalTo(self.view).with.offset(30);
        make.right.equalTo(self.view).with.offset(-30);
        make.height.equalTo(@40);
    }];
    UIView * view = [[UIView alloc]init];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_registerButton.mas_bottom).with.offset(20);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@30);
    }];
    UILabel * label1 = [[UILabel alloc]init];
    [view addSubview:label1];
    label1.text = NSLocalizedStringCN(@"qitafankui", @"");
    label1.textColor = [UIColor colorWithHexString:@"#999999"];
    label1.font = [UIFont fontWithName:@"Arial" size:13.0];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_registerButton.mas_bottom).with.offset(25);
        make.left.equalTo(_textView);
        make.right.equalTo(_textView);
    }];
    //售后热线
    UILabel *tip4 = [[UILabel alloc] init];
    tip4.text = NSLocalizedStringCN(@"kefurexian2", @"");
    tip4.textColor = [UIColor blackColor];
    tip4.numberOfLines = 0;
    tip4.font = [UIFont fontWithName:@"Arial" size:15.0];
    [self.view addSubview:tip4];
    UILabel *tip5 = [[UILabel alloc] init];
    tip5.text = NSLocalizedStringCN(@"kefurexian3", @"");
    tip5.textColor = [UIColor blackColor];
    tip5.numberOfLines = 0;
    tip5.font = [UIFont fontWithName:@"Arial" size:15.0];
    [self.view addSubview:tip5];
    UILabel *tip6 = [[UILabel alloc] init];
    tip6.text = NSLocalizedStringCN(@"kefurexian4", @"");
    tip6.textColor = [UIColor blackColor];
    tip6.numberOfLines = 0;
    tip6.font = [UIFont fontWithName:@"Arial" size:15.0];
    [self.view addSubview:tip6];
    UILabel * tip7 = [[UILabel alloc]init];
    tip7.text = NSLocalizedStringCN(@"kefuworking", @"");
    tip7.textColor = [UIColor blackColor];
    tip7.numberOfLines = 0;
    tip7.font = [UIFont fontWithName:@"Arial" size:15.0];
    [self.view addSubview:tip7];
    UIHyperlinksButton * tip8 = [[UIHyperlinksButton alloc]init];
    [tip8 setTitle:NSLocalizedStringCN(@"xiaotieshi", @"") forState:UIControlStateNormal];
    [tip8 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    tip8.titleLabel.font = [UIFont fontWithName:@"Arial" size:15.0];
    [tip8 addTarget:self action:@selector(push:) forControlEvents:UIControlEventTouchUpInside];
    tip8.tag = 18;
   // [tip8 setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:tip8];
    
    UIHyperlinksButton * hotLine1 = [[UIHyperlinksButton alloc]init];
    [hotLine1 setTitle:@"4008603000" forState:UIControlStateNormal];
    [hotLine1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [hotLine1 addTarget:self action:@selector(hotLine1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hotLine1];

    UIHyperlinksButton * hotLine2 = [[UIHyperlinksButton alloc]init];
    [hotLine2 setTitle:@"13336628222" forState:UIControlStateNormal];
    [hotLine2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [hotLine2 addTarget:self action:@selector(hotLine2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hotLine2];

    UIHyperlinksButton * email = [[UIHyperlinksButton alloc]init];
    [email setTitle:@"love@greenis.com.cn" forState:UIControlStateNormal];
    [email setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [email addTarget:self action:@selector(email) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:email];
    UILabel * time = [[UILabel alloc]init];
    time.numberOfLines = 0;
    time.font = [UIFont fontWithName:@"Arial" size:15];
    time.textColor = [UIColor blackColor];
    time.text = @"8:30----17:30";
    [self.view addSubview:time];
    UIHyperlinksButton * errorBtn = [[UIHyperlinksButton alloc]init];
    [errorBtn setTitle:NSLocalizedStringCN(@"anzhuangshipin", @"") forState:UIControlStateNormal];
    [errorBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    errorBtn.titleLabel.font = [UIFont fontWithName:@"Arial" size:15.0];
    errorBtn.tag = 19;
    [errorBtn addTarget:self action:@selector(push:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:errorBtn];
    [tip4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.mas_bottom).with.offset(8);
        make.left.equalTo(_textView);
        make.right.equalTo(_textView);
    }];
    
    [tip5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tip4.mas_bottom).with.offset(8);
        make.left.equalTo(_textView);
        make.right.equalTo(_textView);
    }];
    
    [tip6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tip5.mas_bottom).with.offset(8);
        make.left.equalTo(_textView);
        make.right.equalTo(_textView);
    }];
    [tip7 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tip6.mas_bottom).with.offset(8);
        make.left.equalTo(_textView);
        make.right.equalTo(_textView);
    }];
    [tip8 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tip7.mas_bottom).with.offset(8);
        make.left.equalTo(_textView);
      //  make.width.equalTo(_textView.mas_width).with.offset(-220);
    }];
    
    [hotLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tip4);
        make.left.equalTo(self.view.mas_right).with.offset(-165);
    }];
    
    [hotLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tip5);
        make.left.equalTo(self.view.mas_right).with.offset(-165);
    }];
    
    [email mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tip6);
        make.left.equalTo(self.view.mas_right).with.offset(-180);
    }];
    [time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tip7);
        make.left.equalTo(self.view.mas_right).with.offset(-165);
    }];
    [errorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tip8);
        make.left.equalTo(self.view.mas_right).with.offset(-165);
    }];
    
}
- (void)hotLine1 {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://4008603000"]];
}
- (void)hotLine2 {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://13336628222"]];
}

- (void)email {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:@[@"love@greenis.com.cn"]];
    if (controller == nil) {
        [ProgressHUD showError:NSLocalizedStringCN(@"qingdakaiyoujianshezhiyouxiang", @"")];
        return;
    }
    else
    {
        [self presentViewController:controller animated:YES completion:nil];
    }
    
}

/**
 下一个页面，破壁机故障和使用说明
 */
-(void)push:(UIButton *)button
{
    switch (button.tag) {
        case 18:
        {
            UseViewController * use = [[UseViewController alloc]init];
            use.title = @"破壁机使用小贴士";
            [self.navigationController pushViewController:use animated:YES];
        }
            break;
        case 19:
        {
            ErrorViewController * error = [[ErrorViewController alloc]init];
            [self.navigationController pushViewController:error animated:YES];
            error.title =@"破壁机常用问题";
        }
            break;
        default:
            break;
    }
}
- (void)commit {
    if (_textView.text.length == 0) {
        [ProgressHUD showError:NSLocalizedStringCN(@"qingshurufankuineirong", @"")];
        
        return;
    }
    
    [ProgressHUD show:NSLocalizedStringCN(@"submitting", @"")];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@interaction/feedback/post/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"AccessToken": [AppConstants userInfo].accessToken, @"Content" : _textView.text};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"success urlString = %@", urlString);
              NSLog(@"Success: %@", responseObject);
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  [ProgressHUD showSuccess:NSLocalizedStringCN(@"submitfeedbacksuccess", @"")];
                  
                  [NSThread sleepForTimeInterval:2.0];
                  [self.navigationController popViewControllerAnimated:YES];
              }
              else if ([[responseObject objectForKey:@"errno"] isEqualToString:@"4401"]) {
                  [AppConstants relogin:^(BOOL success){
                      if (success) {
                          [self commit];
                      }
                      else {
                          [AppConstants notice2ManualRelogin];
                      }
                  }];
              }
              else {
                  [ProgressHUD showError:[responseObject objectForKey:@"errmsg"]];
              }
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"false urlString = %@", urlString);
              NSLog(@"Error: %@", error);
              
              [ProgressHUD showError:NSLocalizedStringCN(@"badNetwork", @"")];
          }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem = _doneButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithHexString:@"#CCCCCC"];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_textView resignFirstResponder];
}
#pragma mark - 邮件代理方法
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultCancelled) {
        [ProgressHUD showSuccess:NSLocalizedStringCN(@"emailcancel", @"")];
    }
    else if (result == MFMailComposeResultSaved) {
        [ProgressHUD showSuccess:NSLocalizedStringCN(@"emailsave", @"")];
    }
    else if (result == MFMailComposeResultSent) {
        [ProgressHUD showSuccess:NSLocalizedStringCN(@"emailsuccess", @"")];
    }
    else if (result == MFMailComposeResultFailed) {
        [ProgressHUD showError:NSLocalizedStringCN(@"emailfail", @"")];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
