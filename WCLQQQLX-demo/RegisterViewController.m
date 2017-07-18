//
//  RegisterViewController.m
//  歌力思
//
//  Created by wen on 16/7/27.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "RegisterViewController.h"
#import "AppConstants.h"
#import "Masonry.h"
#import "AFNetworking.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#define AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES

#import "ProgressHUD.h"
//#import "PlistEditor.h"

@interface RegisterViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) UIButton              *preRegisterButton;
@property (strong, nonatomic) UIButton              *registerButton;
@property (strong, nonatomic) UITextField           *phoneTextField;
@property (strong, nonatomic) UITextField           *usernameTextField;
@property (strong, nonatomic) UITextField           *passwordTextField;
@property (strong, nonatomic) UITextField           *SMSCodeTextField;

@property (nonatomic) double                        animationDuration;
@property (nonatomic) CGRect                        keyboardRect;
@property (strong, nonatomic) NSTimer               *timer;
@property (nonatomic) NSInteger                     leftTime;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _leftTime = 0;
    
    [self initNavigationBar];
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                                name:UIKeyboardWillShowNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [ProgressHUD dismiss];
    
    [_timer invalidate];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    
    _keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
}

- (void)keyboardWillShow:(NSNotification *)notification{
    
    _keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _animationDuration= [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
}

- (void)initNavigationBar {
    self.navigationItem.title = NSLocalizedStringCN(@"zhuce", @"");
}

- (void)initViews {
    
    UIImageView *padingView1 = [[UIImageView alloc] initWithFrame:CGRectMake(30, 104, 20, 29)];
    [self.view addSubview:padingView1];
    padingView1.image = [UIImage imageNamed:@"iphone"];
    //    手机号textfield
    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(padingView1.frame)+5, 104, [UIScreen mainScreen].bounds.size.width - 90, 29)];
    _phoneTextField.clearButtonMode = UITextFieldViewModeAlways;
    _phoneTextField.borderStyle = UITextBorderStyleNone;
    _phoneTextField.placeholder = NSLocalizedStringCN(@"shoujihao", @"");
//    _phoneTextField.backgroundColor = [UIColor grayColor];
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTextField.delegate = self;
    _phoneTextField.tag = 1;
    [self.view addSubview:_phoneTextField];
    UIView * view1 = [[UIView alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(padingView1.frame)+10, [UIScreen mainScreen].bounds.size.width-65, 1)];
    view1.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:view1];
    
    UIImageView *padingView2 = [[UIImageView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(view1.frame)+10, 20, 29)];
    [self.view addSubview:padingView2];
    padingView2.image = [UIImage imageNamed:@"user"];
    //   昵称
    _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(padingView2.frame)+5, CGRectGetMaxY(view1.frame)+10, [UIScreen mainScreen].bounds.size.width-90, 29)];
    _usernameTextField.clearButtonMode = UITextFieldViewModeAlways;
    _usernameTextField.placeholder = NSLocalizedStringCN(@"nicheng", @"");
//    _usernameTextField.backgroundColor = [UIColor grayColor];
    _usernameTextField.delegate = self;
    _usernameTextField.tag = 2;
    [self.view addSubview:_usernameTextField];
    UIView * view2 = [[UIView alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(padingView2.frame)+10, [UIScreen mainScreen].bounds.size.width-65, 1)];
    view2.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:view2];
    
    UIImageView *padingView3 = [[UIImageView alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(view2.frame)+10, 20, 29)];
    [self.view addSubview:padingView3];
    padingView3.image = [UIImage imageNamed:@"key"];
    //    密码
    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(padingView3.frame)+5, CGRectGetMaxY(view2.frame) + 10, [UIScreen mainScreen].bounds.size.width-90, 29)];
   
    _passwordTextField.clearButtonMode = UITextFieldViewModeAlways;
    _passwordTextField.placeholder = NSLocalizedStringCN(@"password", @"");
//    _passwordTextField.backgroundColor = [UIColor grayColor];
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.delegate = self;
    _passwordTextField.tag = 3;
    [self.view addSubview:_passwordTextField];
    UIView * view3 = [[UIView alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(padingView3.frame)+10, [UIScreen mainScreen].bounds.size.width-65, 1)];
    view3.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:view3];
    
    UIImageView *padingView4 = [[UIImageView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(view3.frame)+10, 20, 29)];
    [self.view addSubview:padingView4];
    padingView4.image = [UIImage imageNamed:@"newScode"];
    //短信验证码的输入框
    _SMSCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(padingView4.frame)+5, CGRectGetMaxY(view3.frame)+10, [UIScreen mainScreen].bounds.size.width-205, 29)];
    _SMSCodeTextField.borderStyle = UITextBorderStyleNone;
    _SMSCodeTextField.clearButtonMode = UITextFieldViewModeAlways;
    _SMSCodeTextField.placeholder = NSLocalizedStringCN(@"duanxinyanzhengma", @"");
//    _SMSCodeTextField.backgroundColor = [UIColor grayColor];
    _SMSCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _SMSCodeTextField.delegate = self;
    _SMSCodeTextField.tag = 4;
    [self.view addSubview:_SMSCodeTextField];
    //  获取验证码
    _preRegisterButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_SMSCodeTextField.frame)+5, CGRectGetMaxY(view3.frame)+10, 110, 29)];
    [_preRegisterButton setTitle:NSLocalizedStringCN(@"huoquyanzhengma", @"") forState:UIControlStateNormal];
    _preRegisterButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [_preRegisterButton setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    [_preRegisterButton addTarget:self action:@selector(preRegisterButtonPress) forControlEvents:UIControlEventTouchUpInside];
    _preRegisterButton.enabled = NO;
    _preRegisterButton.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:_preRegisterButton];
    UIView * view4 = [[UIView alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(padingView4.frame)+10, [UIScreen mainScreen].bounds.size.width-65, 1)];
    view4.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:view4];
    //    注册
    _registerButton = [[UIButton alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(view4.frame)+10, [UIScreen mainScreen].bounds.size.width-60, 40)];
    [_registerButton setTitle:NSLocalizedStringCN(@"zhuce", @"") forState:UIControlStateNormal];
    _registerButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [_registerButton setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    [_registerButton addTarget:self action:@selector(registerButtonPress) forControlEvents:UIControlEventTouchUpInside];
    _registerButton.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:_registerButton];
    
    _registerButton.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeOneCI:) name:UITextFieldTextDidChangeNotification object:_phoneTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeOneCI:) name:UITextFieldTextDidChangeNotification object:_usernameTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeOneCI:) name:UITextFieldTextDidChangeNotification object:_passwordTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeOneCI:) name:UITextFieldTextDidChangeNotification object:_SMSCodeTextField];
}

-(void)textFieldTextDidChangeOneCI:(NSNotification *)notification
{
    if (_phoneTextField.text.length != 0 && ![_passwordTextField.text isEqualToString:@""] && ![_usernameTextField.text isEqualToString:@""] && _leftTime == 0) {
        _preRegisterButton.enabled = YES;
        _preRegisterButton.backgroundColor = [UIColor colorWithHexString:@"#FFCC33"];
    }
    
    if (_phoneTextField.text.length != 0 && ![_passwordTextField.text isEqualToString:@""] && ![_usernameTextField.text isEqualToString:@""] && _SMSCodeTextField.text.length == 6) {
        _registerButton.enabled = YES;
        _registerButton.backgroundColor = [UIColor colorWithHexString:@"#FFCC33"];
    }
}
//获取验证码
- (void)preRegisterButtonPress {
    [self hideKeyboard];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@authentication/user/PreRegister/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"UserName": _usernameTextField.text, @"Nickname" : _usernameTextField.text, @"UserPSW" : _passwordTextField.text, @"Mobile" : _phoneTextField.text};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              //              NSLog(@"success urlString = %@", urlString);
              //              NSLog(@"Success: %@", responseObject);
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  //                  注意查收短信
                  [ProgressHUD showSuccess:NSLocalizedStringCN(@"zhuyichashouduanxin", @"")];
                  
                  _leftTime = 30;
                  _preRegisterButton.backgroundColor = [UIColor grayColor];
                  //                  这种状态下的按钮【无法】接收点击事件﻿
                  _preRegisterButton.enabled = NO;
                  
                  self.timer= [NSTimer scheduledTimerWithTimeInterval:1
                                                               target:self
                                                             selector:@selector(changeButtonName)
                                                             userInfo:nil
                                                              repeats:YES];
              }
              else {
                  //                  昵称已经被使用
                  [ProgressHUD showError:[responseObject objectForKey:@"errmsg"]];
                  //                  NSLog(@"self.timer= [NSTimer scheduledTimerWithTimeInterval:11111     %@",[responseObject objectForKey:@"errmsg"]);
              }
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"false urlString = %@", urlString);
              NSLog(@"Error: %@", error);
              
              [ProgressHUD showError:NSLocalizedStringCN(@"badNetwork", @"")];
          }];
}

- (void)changeButtonName{
    if (_leftTime > 0) {
        _leftTime--;
        NSString * string;
//        if (_leftTime % 2 == 0)
//        {
            //            %lds后
            string = [NSString stringWithFormat:NSLocalizedStringCN(@"Nmiaohou", @""), (long)_leftTime];
//        }
//        else {
//            string = NSLocalizedStringCN(@"huoquyanzhengma", @"");
//       }
        _preRegisterButton.titleLabel.text = string;
        _preRegisterButton.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    }
    else {
        //        移除计时器
        [_timer invalidate];
        _preRegisterButton.enabled = YES;
        _preRegisterButton.backgroundColor = [UIColor colorWithHexString:@"#FFCC33"];
        _preRegisterButton.titleLabel.text = NSLocalizedStringCN(@"huoquyanzhengma", @"");
    }
}
//注册
- (void)registerButtonPress {
    [self hideKeyboard];
    
    [ProgressHUD show:NSLocalizedStringCN(@"zhucezhong", @"")];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@authentication/user/ConfirmRegister/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"Userid": _phoneTextField.text, @"Password" : _passwordTextField.text, @"SmSvalidateKey" : _SMSCodeTextField.text};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              //              NSLog(@"success urlString = %@", urlString);
              //              NSLog(@"Success: %@", responseObject);
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  
                  [AppConstants userInfo].accessToken = [responseObject objectForKey:@"AccessToken"];
                  [AppConstants userInfo].account = _phoneTextField.text;
                  [AppConstants userInfo].password = _passwordTextField.text;
                  [AppConstants userInfo].OAuthName = @"";
                  [AppConstants userInfo].openid = @"";
                  [AppConstants saveUserInfo];
                  
                  [self getOriginUserInfo];
                  
                  //                  [NSThread detachNewThreadSelector:@selector(timedPop) toTarget:self withObject:nil];
              }
              else {
                  //                    昵称已经被使用
                  [ProgressHUD showError:[responseObject objectForKey:@"errmsg"]];
              }
              
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"false urlString = %@", urlString);
              NSLog(@"Error: %@", error);
              
              [ProgressHUD showError:NSLocalizedStringCN(@"badNetwork", @"")];
          }];
    
}

- (void)timedPop
{
    @autoreleasepool
    {
        NSTimeInterval sleep = 2.0;
        
        [NSThread sleepForTimeInterval:sleep];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

- (void)getOriginUserInfo {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@authentication/user/infomation/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"AccessToken": [AppConstants userInfo].accessToken};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              //              NSLog(@"success urlString = %@", urlString);
              //              NSLog(@"Success: %@", responseObject);
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  [ProgressHUD showSuccess:NSLocalizedStringCN(@"zhucechenggong", @"")];

                  [AppConstants userInfo].userId = [responseObject objectForKey:@"userid"];
                  [AppConstants userInfo].nickname = [responseObject objectForKey:@"nickname"];
                  [AppConstants userInfo].sex = [responseObject objectForKey:@"sex"];
                  [AppConstants userInfo].mobile = [responseObject objectForKey:@"mobile"];
                  [AppConstants userInfo].avatarURL = [[responseObject objectForKey:@"avatarPic"] objectForKey:@"avatarURL"];
                  
                  [AppConstants saveUserInfo];
                  
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"registerSuccess" object:nil];
                  
                  [NSThread detachNewThreadSelector:@selector(timedPop) toTarget:self withObject:nil];
              }
              else if ([[responseObject objectForKey:@"errno"] isEqualToString:@"4401"]) {
                  [AppConstants relogin:^(BOOL success){
                      if (success) {
                          [self getOriginUserInfo];
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hideKeyboard];
}
//回收键盘
- (void)hideKeyboard {
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_usernameTextField resignFirstResponder];
    [_SMSCodeTextField resignFirstResponder];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"here");
    [textField resignFirstResponder];
    return true;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"textField.tag = %ld", (long)textField.tag);
    BOOL isShould = YES;
    
    if (textField.tag == 1) {
        if (range.location>=11)
        {
            isShould = NO;
        }
        else
        {
            isShould = YES;
        }
    }
    else if (textField.tag == 4) {
        if (range.location>=6)
        {
            isShould = NO;
        }
        else
        {
            isShould = YES;
        }
    }
    
    return isShould;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
   
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
   
}



@end
