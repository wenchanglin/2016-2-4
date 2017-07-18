//
//  ChangePasswordViewController.m
//  歌力思
//
//  Created by greenis on 16/8/2.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()<UITextFieldDelegate>
@property(nonatomic,strong)UITextField * oldPwdTextField;//旧密码
@property(nonatomic,strong)UITextField *  PwdTextField;//新密码
@property(nonatomic,strong)UITextField * truePwdTextField;//确认密码
@property(nonatomic,strong)UIButton * registerButton;//注册
@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initViews];
}
-(void)initViews
{
    UIImageView *padingView1 = [[UIImageView alloc] initWithFrame:CGRectMake(40, 104, 25, 30)];
    [self.view addSubview:padingView1];
    padingView1.image = [UIImage imageNamed:@"key"];
    //    旧密码
    _oldPwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(padingView1.frame)+10, 104, [UIScreen mainScreen].bounds.size.width - 120, 29)];
    _oldPwdTextField.clearButtonMode = UITextFieldViewModeAlways;
    _oldPwdTextField.borderStyle = UITextBorderStyleNone;
    _oldPwdTextField.placeholder = NSLocalizedStringCN(@"oldpassword", @"");
    _oldPwdTextField.textColor = [UIColor colorWithHexString:@"#666666"];
    _oldPwdTextField.delegate = self;
    _oldPwdTextField.tag = 1;
    [self.view addSubview:_oldPwdTextField];
    UIView * view1 = [[UIView alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(padingView1.frame)+15, [UIScreen mainScreen].bounds.size.width-90, 1)];
    view1.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:view1];
    
    UIImageView *padingView2 = [[UIImageView alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(view1.frame)+15, 25, 30)];
    [self.view addSubview:padingView2];
    padingView2.image = [UIImage imageNamed:@"newPwd"];
    //   新密码
    _PwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(padingView2.frame)+10, CGRectGetMaxY(view1.frame)+15, [UIScreen mainScreen].bounds.size.width-120, 30)];
    _PwdTextField.clearButtonMode = UITextFieldViewModeAlways;
    _PwdTextField.placeholder = NSLocalizedStringCN(@"newpassword", @"");
    _PwdTextField.textColor =[UIColor colorWithHexString:@"#666666"];
    _PwdTextField.secureTextEntry = YES;
    _PwdTextField.delegate = self;
    _PwdTextField.tag = 2;
    [self.view addSubview:_PwdTextField];
    UIView * view2 = [[UIView alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(padingView2.frame)+15, [UIScreen mainScreen].bounds.size.width-90, 1)];
    view2.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:view2];
    
    UIImageView *padingView3 = [[UIImageView alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(view2.frame)+15, 25, 30)];
    [self.view addSubview:padingView3];
    padingView3.image = [UIImage imageNamed:@"truePwd"];
    //   确认新密码
    _truePwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(padingView3.frame)+10, CGRectGetMaxY(view2.frame) + 15, [UIScreen mainScreen].bounds.size.width-120, 30)];
    
    _truePwdTextField.clearButtonMode = UITextFieldViewModeAlways;
    _truePwdTextField.placeholder = NSLocalizedStringCN(@"newpasswordagain", @"");
    _truePwdTextField.textColor = [UIColor colorWithHexString:@"#666666"];
    _truePwdTextField.clearButtonMode = UITextFieldViewModeAlways;
    _truePwdTextField.secureTextEntry = YES;
    _truePwdTextField.delegate = self;
    _truePwdTextField.tag = 3;
    [self.view addSubview:_truePwdTextField];
    UIView * view3 = [[UIView alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(padingView3.frame)+15, [UIScreen mainScreen].bounds.size.width-90, 1)];
    view3.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:view3];
    //注册
    _registerButton = [[UIButton alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(view3.frame)+15, [UIScreen mainScreen].bounds.size.width-90, 35)];
    [_registerButton setTitle:NSLocalizedStringCN(@"xiugaimima", @"") forState:UIControlStateNormal];
    _registerButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [_registerButton setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    [_registerButton addTarget:self action:@selector(changePassword) forControlEvents:UIControlEventTouchUpInside];
    _registerButton.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:_registerButton];
    _registerButton.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeOneCI:) name:UITextFieldTextDidChangeNotification object:_oldPwdTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeOneCI:) name:UITextFieldTextDidChangeNotification object:_PwdTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeOneCI:) name:UITextFieldTextDidChangeNotification object:_truePwdTextField];

}

-(void)textFieldTextDidChangeOneCI:(NSNotification *)notification
{
    if (_oldPwdTextField.text.length != 0 && _PwdTextField.text.length != 0 && _PwdTextField.text.length != 0 && [_PwdTextField.text isEqualToString:_truePwdTextField.text]) {
        _registerButton.enabled = YES;
        _registerButton.backgroundColor = [UIColor colorWithHexString:@"#FFCC33"];
    }
    else {
        _registerButton.enabled = NO;
        _registerButton.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    }
}
- (void)hideKeyboard {
    [_oldPwdTextField resignFirstResponder];
    [_PwdTextField resignFirstResponder];
    [_truePwdTextField resignFirstResponder];
}
- (void)changePassword {
    [self hideKeyboard];
    
    [ProgressHUD show:NSLocalizedStringCN(@"changingpassword", @"")];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@authentication/user/changepassword/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"AccessToken": [AppConstants userInfo].accessToken, @"OldPassword": _oldPwdTextField.text, @"NewPassword": _PwdTextField.text};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"success urlString = %@", urlString);
              NSLog(@"Success: %@", responseObject);
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  [ProgressHUD showSuccess:NSLocalizedStringCN(@"changepasswordsuccess", @"")];
                  
                  [NSThread sleepForTimeInterval:2.0];
                  [self.navigationController popViewControllerAnimated:YES];
                
              }
              else if ([[responseObject objectForKey:@"errno"] isEqualToString:@"4401"]) {
                  [AppConstants relogin:^(BOOL success){
                      if (success) {
                          [self changePassword];
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

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self hideKeyboard];
}

@end
