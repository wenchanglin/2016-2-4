//
//  ForgetPasswordViewController.m
//  歌力思
//
//  Created by wen on 16/7/27.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "AppConstants.h"
#import "Masonry.h"
#import "AFNetworking.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#define AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES
#import "ProgressHUD.h"

@interface ForgetPasswordViewController ()<UITextFieldDelegate>


@property (strong, nonatomic) UIButton              *forgetPasswordButton;
@property (strong, nonatomic) UITextField           *usernameTextField;
@property (strong, nonatomic) UITextField           *phoneTextField;

@property (nonatomic) double                        animationDuration;
@property (nonatomic) CGRect                        keyboardRect;
@property (strong, nonatomic) NSTimer               *timer;
@property (nonatomic) NSInteger                     leftTime;
@end

@implementation ForgetPasswordViewController

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
    self.navigationItem.title = NSLocalizedStringCN(@"forgetpassword", @"");
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"#CCCCCC"],NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
}

- (void)initViews {
    
    UIImageView *padingView1 = [[UIImageView alloc] initWithFrame:CGRectMake(30, 104, 20, 29)];
    [self.view addSubview:padingView1];
    padingView1.image = [UIImage imageNamed:@"iphone"];
    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(padingView1.frame)+5, 104, [UIScreen mainScreen].bounds.size.width - 85, 29)];
    
    _phoneTextField.borderStyle = UITextBorderStyleNone;
    _phoneTextField.placeholder = NSLocalizedStringCN(@"shoujihao", @"");
    //_phoneTextField.backgroundColor = [UIColor whiteColor];
    _phoneTextField.textColor = [UIColor colorWithHexString:@"#666666"];
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTextField.delegate = self;
    _phoneTextField.clearButtonMode = UITextFieldViewModeAlways;
    _phoneTextField.tag = 1;
    
    [self.view addSubview:_phoneTextField];
    UIView * view1 = [[UIView alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(padingView1.frame)+10, [UIScreen mainScreen].bounds.size.width-60, 1)];
    view1.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:view1];
    UIImageView *padingView2 = [[UIImageView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(view1.frame) + 10, 20, 29)];
    [self.view addSubview:padingView2];
    padingView2.image = [UIImage imageNamed:@"user"];
    

    _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(padingView2.frame)+5,CGRectGetMaxY(view1.frame)+10 ,[UIScreen mainScreen].bounds.size.width - 85, 29)];
    _usernameTextField.borderStyle = UITextBorderStyleNone;
    _usernameTextField.placeholder = NSLocalizedStringCN(@"nicheng", @"");
   // _usernameTextField.backgroundColor = [UIColor whiteColor];
    _usernameTextField.delegate = self;
    _usernameTextField.tag = 2;
    _usernameTextField.clearButtonMode = UITextFieldViewModeAlways;
    [self.view addSubview:_usernameTextField];
    UIView * view2 = [[UIView alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(padingView2.frame)+10, [UIScreen mainScreen].bounds.size.width-60, 1)];
    view2.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:view2];
    _forgetPasswordButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_forgetPasswordButton setTitle:NSLocalizedStringCN(@"resetpassword", @"") forState:UIControlStateNormal];
    _forgetPasswordButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
   
    [_forgetPasswordButton setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateNormal];
    [_forgetPasswordButton addTarget:self action:@selector(forgetPasswordButtonPress) forControlEvents:UIControlEventTouchUpInside];
    _forgetPasswordButton.enabled = NO;
    _forgetPasswordButton.backgroundColor = [UIColor colorWithHexString:@"CCCCCC"];
    [self.view addSubview:_forgetPasswordButton];

    _forgetPasswordButton.frame = CGRectMake(30, CGRectGetMaxY(view2.frame) + 10,[UIScreen mainScreen].bounds.size.width - 60, 40);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeOneCI:) name:UITextFieldTextDidChangeNotification object:_phoneTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeOneCI:) name:UITextFieldTextDidChangeNotification object:_usernameTextField];
}

-(void)textFieldTextDidChangeOneCI:(NSNotification *)notification
{
    if (_phoneTextField.text.length != 0 && ![_usernameTextField.text isEqualToString:@""] && _leftTime == 0) {
        _forgetPasswordButton.enabled = YES;
        _forgetPasswordButton.backgroundColor = _forgetPasswordButton.backgroundColor = [UIColor colorWithHexString:@"#FFCC33"];
    }
    else {
        _forgetPasswordButton.enabled = NO;
        _forgetPasswordButton.backgroundColor = [UIColor lightGrayColor];
    }
}

- (void)changeButtonName{
    if (_leftTime > 0) {
        _leftTime--;
        NSString * string = [NSString stringWithFormat:NSLocalizedStringCN(@"Nmiaohou", @""), (long)_leftTime];
        _forgetPasswordButton.titleLabel.text = string;
    }
    else {
        [_timer invalidate];
        _forgetPasswordButton.enabled = YES;
       _forgetPasswordButton.backgroundColor = [UIColor colorWithHexString:@"#FFCC33"];
        //        重置密码
        _forgetPasswordButton.titleLabel.text = NSLocalizedStringCN(@"resetpassword", @"");
    }
}

- (void)forgetPasswordButtonPress {
    [self hideKeyboard];
    
    [ProgressHUD show:NSLocalizedStringCN(@"chulizhong", @"")];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@authentication/user/forgetpassword/mobile/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"userName": _usernameTextField.text, @"mobileNumber" : _phoneTextField.text};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"success urlString = %@", urlString);
              NSLog(@"Success: %@", responseObject);
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  
                  [ProgressHUD showSuccess:NSLocalizedStringCN(@"zhuyichashouduanxin", @"#CCCCCC")];
                  
                  _leftTime = 30;
                  _forgetPasswordButton.backgroundColor = [UIColor colorWithHexString:@""];
                  _forgetPasswordButton.enabled = NO;
                  
                  self.timer= [NSTimer scheduledTimerWithTimeInterval:1
                                                               target:self
                                                             selector:@selector(changeButtonName)
                                                             userInfo:nil
                                                              repeats:YES];
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

- (void)hideKeyboard {
    [_usernameTextField resignFirstResponder];
    [_usernameTextField resignFirstResponder];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
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
    
    return isShould;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    CGRect frame = textField.frame;
//    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);//键盘高度216
//    
//    NSTimeInterval animationDuration = 0.30f;
//    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//    [UIView setAnimationDuration:animationDuration];
//    
//    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
//    if(offset > 0)
//        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
//    
//    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
//    self.view.frame =CGRectMake(0, [AppConstants uiNavigationBarHeight], self.view.frame.size.width, self.view.frame.size.height);
}


@end
