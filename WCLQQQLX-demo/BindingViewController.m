//
//  BindingViewController.m
//  歌力思
//
//  Created by greenis on 16/8/2.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "BindingViewController.h"

@interface BindingViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) NSTimer      * timer;
@property (nonatomic) NSInteger   leftTime;
@property (nonatomic,strong)  UITextField  * phoneTextField;
@property (nonatomic,strong)  UITextField  * vCodeTextField;
@property(nonatomic,strong) UIButton * getVCodeButton;
@property(nonatomic,strong)UIButton * bindingButton;
@end

@implementation BindingViewController

- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    
    [ProgressHUD dismiss];
    
    [_timer invalidate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _leftTime = 0;
    [self initViews];
}
- (void)initViews {
    
    UIImageView *padingView1 = [[UIImageView alloc] initWithFrame:CGRectMake(40, 104, 25, 30)];
    [self.view addSubview:padingView1];
    padingView1.image = [UIImage imageNamed:@"mobile"];//iphone
    //手机号
    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(padingView1.frame)+10, 104, [UIScreen mainScreen].bounds.size.width-120, 30)];
    _phoneTextField.borderStyle = UITextBorderStyleNone;
    _phoneTextField.clearButtonMode = UITextFieldViewModeAlways;
    _phoneTextField.placeholder = NSLocalizedStringCN(@"shoujihao", @"");
   
    _phoneTextField.textColor = [UIColor colorWithHexString:@"#666666"];
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTextField.delegate = self;
    _phoneTextField.tag = 1;
    [self.view addSubview:_phoneTextField];
    UIView * view1 = [[UIView alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(padingView1.frame)+15, [UIScreen mainScreen].bounds.size.width-90, 1)];
    [self.view addSubview:view1];
    view1.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    UIImageView *padingView2 = [[UIImageView alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(view1.frame)+15, 25, 30)];
    [self.view addSubview:padingView2];
    padingView2.image = [UIImage imageNamed:@"newScode"];//scode
    
    //验证码文本框

    _vCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(padingView2.frame)+10, CGRectGetMaxY(view1.frame)+15, [UIScreen mainScreen].bounds.size.width-235, 30)];
    _vCodeTextField.borderStyle = UITextBorderStyleNone;
    _vCodeTextField.clearButtonMode = UITextFieldViewModeAlways;
    _vCodeTextField.placeholder = NSLocalizedStringCN(@"duanxinyanzhengma", @"");
    _vCodeTextField.textColor = [UIColor colorWithHexString:@"#666666"];
    _vCodeTextField.delegate = self;
    _vCodeTextField.tag = 2;
    
    [self.view addSubview:_vCodeTextField];
    //验证码
    _getVCodeButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_vCodeTextField.frame)+5, CGRectGetMaxY(view1.frame)+15, 105, 30)];
    [_getVCodeButton setTitle:NSLocalizedStringCN(@"huoquyanzhengma", @"") forState:UIControlStateNormal];
    _getVCodeButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [_getVCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_getVCodeButton addTarget:self action:@selector(getVCodeButtonPress) forControlEvents:UIControlEventTouchUpInside];
    _getVCodeButton.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:_getVCodeButton];
    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(_vCodeTextField.frame)+15, [UIScreen mainScreen].bounds.size.width-90, 1)];
    [self.view addSubview:view2];
    view2.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    
    _bindingButton = [[UIButton alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(view2.frame)+15, [UIScreen mainScreen].bounds.size.width-90, 35)];
    [_bindingButton setTitle:NSLocalizedStringCN(@"zhuce", @"") forState:UIControlStateNormal];
    _bindingButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [_bindingButton setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    [_bindingButton addTarget:self action:@selector(bindingButtonPress) forControlEvents:UIControlEventTouchUpInside];
    _bindingButton.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:_bindingButton];
    _bindingButton.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeOneCI:) name:UITextFieldTextDidChangeNotification object:_phoneTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeOneCI:) name:UITextFieldTextDidChangeNotification object:_vCodeTextField];
    
    NSLog(@"init view");
}

-(void)textFieldTextDidChangeOneCI:(NSNotification *)notification
{
    if (_phoneTextField.text.length != 0) {
        _getVCodeButton.enabled = YES;
        _getVCodeButton.backgroundColor = [UIColor colorWithHexString:@"#FFCC33"];
    }
    else {
        _getVCodeButton.enabled = NO;
        _getVCodeButton.backgroundColor = [UIColor grayColor];
    }
    
    if (_phoneTextField.text.length != 0 && _vCodeTextField.text.length != 0) {
        _bindingButton.enabled = YES;
        _bindingButton.backgroundColor = [UIColor colorWithHexString:@"#FFCC33"];
    }
    else {
        _bindingButton.enabled = NO;
        _bindingButton.backgroundColor = [UIColor grayColor];
    }
}

- (void)getVCodeButtonPress {
    
}

- (void)bindingButtonPress {
    [self hideKeyboard];
    
    [ProgressHUD show:NSLocalizedStringCN(@"zhucezhong", @"")];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@authentication/user/register/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{};
    
    //    NSDictionary *parameters = @{@"Userid": _usernameTextField.text, @"NickName" : _usernameTextField.text, @"Password" : _passwordTextField.text};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              //              NSLog(@"success urlString = %@", urlString);
              //              NSLog(@"Success: %@", responseObject);
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  
                  [AppConstants userInfo].accessToken = [responseObject objectForKey:@"AccessToken"];
                  [AppConstants userInfo].password = @"";//_passwordTextField.text;
                  [AppConstants userInfo].OAuthName = @"";
                  [AppConstants userInfo].openid = @"";
                  [AppConstants saveUserInfo];
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hideKeyboard];
}

- (void)hideKeyboard {
    [_phoneTextField resignFirstResponder];
    [_vCodeTextField resignFirstResponder];
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


@end
