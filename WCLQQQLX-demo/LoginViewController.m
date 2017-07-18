//
//  LoginViewController.m
//  歌力思
//
//  Created by wen on 16/7/25.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "LoginViewController.h"
#import "ForgetPasswordViewController.h"
#import "WXApiManager.h"
#import "WXApiRequestHandler.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "RegisterViewController.h"
#import "Masonry.h"
#define Start_X [UIScreen mainScreen].bounds.size.width / 3 -25        // 第一个按钮的X坐标
#define Start_Y _diSanFangLabel.frame.size.height+5           // 第一个按钮的Y坐标
#define Width_Space 30        // 2个按钮之间的横间距
#define Height_Space 0      // 竖间距
#define Button_Height 40    // 高
#define Button_Width 40     // 宽
@interface LoginViewController ()<WXApiManagerDelegate,TencentSessionDelegate,WBHttpRequestDelegate,WBHttpRequestDelegate,UITextFieldDelegate>
@property(nonatomic,strong)UIImageView * userImageView; //用户名图片
@property(nonatomic,strong)UIImageView * passWordImageView;//密码图片
@property (strong, nonatomic) UITextField                       *username;//用户名
@property (strong, nonatomic) UITextField                       *password;//密码
@property (nonatomic) BOOL                                      isRegisterSuccess;
@property (nonatomic, retain) TencentOAuth                      *oauth;
@property (strong, nonatomic) UIButton                          *loginButton;//登录按钮
@property (strong, nonatomic) UIButton                          *registerButton;//注册按钮
@property (strong, nonatomic) UILabel                           *usernameTipLabel;//用户名错误文字
@property (strong, nonatomic) UILabel                           *passwordTipLabel;//密码错误文字
@property (strong, nonatomic) UILabel                           *loginResultTipLabel;//登录错误文字
@property (nonatomic,strong) UILabel                             * diSanFangLabel;//第三方分割线
@property (strong, nonatomic) UIActivityIndicatorView           *spinner;
@property (nonatomic,strong) UIButton *forgetPassword;  //忘记密码
@end

@implementation LoginViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_isRegisterSuccess) {
        _isRegisterSuccess = NO;
        
        [self loginSuccess];
    }
}

- (void)loginSuccess {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    });
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [ProgressHUD dismiss];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor= [UIColor whiteColor];
    [WXApiManager sharedManager].delegate = self;
    [self initNavigationBar];
    [self initViews];
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiboLoginRequest) name:@"weiboLoginRequest" object:nil];
    NSString *appid = [AppConstants QQAppID];
    _oauth = [[TencentOAuth alloc] initWithAppId:appid
                                     andDelegate:self];
}
//创建UI界面
-(void)initViews
{
    UIImageView *user = [[UIImageView alloc] initWithFrame:CGRectMake(40, 104, 25, 30)];
    
    user.image = [UIImage imageNamed:@"user"];
    [self.view addSubview:user];
    //姓名
    _username = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(user.frame) + 10, 104, [UIScreen mainScreen].bounds.size.width-120 ,30)];
    
    [self.view addSubview:_username];
    _username.placeholder = NSLocalizedStringCN(@"account", @"");
    _username.clearButtonMode = UITextFieldViewModeAlways;
    _username.delegate = self;
   _username.textColor = [UIColor colorWithHexString:@"#666666"];
    UIView *xiantiao = [[UIView alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(user.frame)  + 15, [UIScreen mainScreen].bounds.size.width-90, 1)];
    
    xiantiao.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:xiantiao];
    
   
    //密码·
    UIImageView *password = [[UIImageView alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(xiantiao.frame) + 15, 25, 30)];
    password.image = [UIImage imageNamed:@"key"];
    [self.view addSubview:password];
    
    _password = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(password.frame) + 10, CGRectGetMaxY(xiantiao.frame) + 15 , [UIScreen mainScreen].bounds.size.width-120 , 30)];
    [self.view addSubview:_password];
    _password.textColor = [UIColor colorWithHexString:@"#666666"];
    _password.clearButtonMode = UITextFieldViewModeAlways;
    _password.placeholder = NSLocalizedStringCN(@"password", @"");
    _password.borderStyle = UITextBorderStyleNone;
    _password.secureTextEntry = YES;
    UIView *secondXianTiao = [[UIView alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(password.frame)+ 10, [UIScreen mainScreen].bounds.size.width-90, 1)];
    secondXianTiao.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:secondXianTiao];
    //登录
    _loginButton = [[UIButton alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(secondXianTiao.frame)+30, [UIScreen mainScreen].bounds.size.width-90, 35)];
    [_loginButton setTitle:NSLocalizedStringCN(@"denglu", @"") forState:UIControlStateNormal];
    _loginButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [_loginButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(loginButtonPress) forControlEvents:UIControlEventTouchUpInside];
    _loginButton.backgroundColor = [UIColor colorWithHexString:@"#FFCC33"];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:_loginButton];
    //注册
    _registerButton = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 120 - 20, CGRectGetMaxY(_loginButton.frame)+15, 120, 35)];
    _registerButton.layer.cornerRadius = 10;
    [_registerButton setTitle:NSLocalizedStringCN(@"likezhuce", @"") forState:UIControlStateNormal];
    _registerButton.titleLabel.font = [UIFont systemFontOfSize: 15.0];
    
    [_registerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_registerButton addTarget:self action:@selector(registerButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registerButton];
    UIView *thirdXianTiao = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2, CGRectGetMaxY(_loginButton.frame)+15 + 5, 1, 25)];
    thirdXianTiao.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self.view addSubview:thirdXianTiao];
    //    forgetpassword忘记密码
    self.forgetPassword = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 + 20, CGRectGetMaxY(_loginButton.frame)+15, 120, 35)];
    [self.view addSubview:self.forgetPassword];
    [self.forgetPassword setTitle:NSLocalizedStringCN(@"forgetpassword", @"") forState:UIControlStateNormal];
    self.forgetPassword.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.forgetPassword setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.forgetPassword addTarget:self action:@selector(forgotPassword) forControlEvents:UIControlEventTouchUpInside];
    
    //第三方 左白线
    UIView * leftChangYong = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_registerButton.frame)+40, ([UIScreen mainScreen].bounds.size.width-120)/2, 2)];
    leftChangYong.backgroundColor = [UIColor grayColor];
    //  [self.view addSubview:leftChangYong];
    //第三方登录
    _diSanFangLabel = [[UILabel alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-200)/2, CGRectGetMaxY(_registerButton.frame)+5, 200, 30)];
    [self.view addSubview:_diSanFangLabel];
    _diSanFangLabel.font = [UIFont systemFontOfSize:13];
    _diSanFangLabel.textColor = [UIColor grayColor];//
    _diSanFangLabel.textAlignment = NSTextAlignmentCenter;
    //    _diSanFangLabel.backgroundColor = [UIColor colorWithWhite:0.9f alpha:0.4f];
    _diSanFangLabel.text = NSLocalizedStringCN(@"disanfangdenglu", @"");
    //第三方 右白线
    UIView * rightChangYong = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_diSanFangLabel.frame), CGRectGetMaxY(_registerButton.frame)+40, ([UIScreen mainScreen].bounds.size.width+120)/2, 2)];
    rightChangYong.backgroundColor = [UIColor grayColor];
    // [self.view addSubview:rightChangYong];
    UIButton *button;
    for (int i=0; i<3; i++)
    {
        NSArray * imgArray = @[@"weixin",@"QQ",@"sina"];
        button = [[UIButton alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 180)/2 + i * (40 + 30), CGRectGetMaxY(_diSanFangLabel.frame) + 10, Button_Width, Button_Height)];
        [self.view addSubview:button];
        
        [button setImage:[UIImage imageNamed:imgArray[i]] forState:UIControlStateNormal];
        //        [button setImage:[UIImage imageNamed:imgPress[i]] forState:UIControlStateHighlighted];
        button.tag = i+1;
        button.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [button addTarget:self action:@selector(thirdBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    
}
#pragma mark - 第三份登录点击事件
-(void)thirdBtnClick:(UIButton *)button
{
    switch (button.tag) {
        case 1:
        {
            [self hideKeyboard];
            
            [WXApiRequestHandler sendAuthRequestScope:@"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact"
                                                State:@"xxx"
                                               OpenID:@""
                                     InViewController:self];
            
            
            
        }
            break;
        case 2:
        {
            NSLog(@"QQButtonPress");
            [self hideKeyboard];
            
            NSArray* permissions = [NSArray arrayWithObjects:
                                    kOPEN_PERMISSION_GET_USER_INFO,
                                    kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                    kOPEN_PERMISSION_ADD_ALBUM,
                                    kOPEN_PERMISSION_ADD_IDOL,
                                    kOPEN_PERMISSION_ADD_ONE_BLOG,
                                    kOPEN_PERMISSION_ADD_PIC_T,
                                    kOPEN_PERMISSION_ADD_SHARE,
                                    kOPEN_PERMISSION_ADD_TOPIC,
                                    kOPEN_PERMISSION_CHECK_PAGE_FANS,
                                    kOPEN_PERMISSION_DEL_IDOL,
                                    kOPEN_PERMISSION_DEL_T,
                                    kOPEN_PERMISSION_GET_FANSLIST,
                                    kOPEN_PERMISSION_GET_IDOLLIST,
                                    kOPEN_PERMISSION_GET_INFO,
                                    kOPEN_PERMISSION_GET_OTHER_INFO,
                                    kOPEN_PERMISSION_GET_REPOST_LIST,
                                    kOPEN_PERMISSION_LIST_ALBUM,
                                    kOPEN_PERMISSION_UPLOAD_PIC,
                                    kOPEN_PERMISSION_GET_VIP_INFO,
                                    kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                                    kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                                    kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO,
                                    nil];
            
            [_oauth authorize:permissions inSafari:NO];
        }
            break;
        case 3:
        {
            NSLog(@"SinaButtonPress");
            [self hideKeyboard];
            WBAuthorizeRequest *request = [WBAuthorizeRequest request];
            request.redirectURI = @"https://api.weibo.com/oauth2/default.html";
            request.scope = @"all";
            request.shouldShowWebViewForAuthIfCannotSSO = YES;
            request.userInfo = @{@"SSO_From": @"LoginViewController",
                                 @"Other_Info_1": [NSNumber numberWithInt:123],
                                 @"Other_Info_2": @[@"obj1", @"obj2"],
                                 @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
            [WeiboSDK sendRequest:request];
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - WX登录的事件
-(void)getAccess_token
{
    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",[AppConstants WXAppID],[AppConstants WXAppSecret],[AppConstants WXCode]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                [AppConstants setWXAccessToken:[dic objectForKey:@"access_token"]];
                [AppConstants setWXOpenid:[dic objectForKey:@"openid"]];
                [AppConstants setWXRefreshToken:[dic objectForKey:@"refresh_token"]];
                [AppConstants setWXScope:[dic objectForKey:@"scope"]];
                [AppConstants setWXUnionid:[dic objectForKey:@"unionid"]];
                
                [PlistEditor alterPlist:@"AppInfo" addValue:[dic objectForKey:@"openid"] forKey:@"WXOpenid"];
                [PlistEditor alterPlist:@"AppInfo" addValue:[dic objectForKey:@"scope"] forKey:@"WXScope"];
                [PlistEditor alterPlist:@"AppInfo" addValue:[dic objectForKey:@"unionid"] forKey:@"WXUnionid"];
                
                [self getUserInfo];
            }
        });
    });
}

-(void)getUserInfo
{
    // https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",[AppConstants WXAccessToken], [AppConstants WXOpenid]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                NSLog(@"userinfo %@", dic);
                
                [AppConstants setWXCity:[dic objectForKey:@"city"]];
                [AppConstants setWXCountry:[dic objectForKey:@"country"]];
                [AppConstants setWXHeadimgurl:[dic objectForKey:@"headimgurl"]];
                [AppConstants setWXLanguage:[dic objectForKey:@"language"]];
                [AppConstants setWXNickname:[dic objectForKey:@"nickname"]];
                [AppConstants setWXProvince:[dic objectForKey:@"province"]];
                
                //                _WXSex = [dic objectForKey:@"sex"];
                
                if ([[dic objectForKey:@"sex"] intValue] == 1) {
                    [AppConstants setWXSex:@"男"];
                }
                else if ([[dic objectForKey:@"sex"] intValue] == 2) {
                    [AppConstants setWXSex:@"女"];
                }
                else {
                    [AppConstants setWXSex:@""];
                }
                
                [PlistEditor alterPlist:@"AppInfo" addValue:[dic objectForKey:@"city"] forKey:@"WXCity"];
                [PlistEditor alterPlist:@"AppInfo" addValue:[dic objectForKey:@"country"] forKey:@"WXCountry"];
                [PlistEditor alterPlist:@"AppInfo" addValue:[dic objectForKey:@"headimgurl"] forKey:@"WXHeadimgurl"];
                [PlistEditor alterPlist:@"AppInfo" addValue:[dic objectForKey:@"language"] forKey:@"WXLanguage"];
                [PlistEditor alterPlist:@"AppInfo" addValue:[dic objectForKey:@"nickname"] forKey:@"WXNickname"];
                [PlistEditor alterPlist:@"AppInfo" addValue:[dic objectForKey:@"province"] forKey:@"WXProvince"];
                [PlistEditor alterPlist:@"AppInfo" addValue:[AppConstants WXSex] forKey:@"WXSex"];
                
                [AppConstants writeDic2File];
                
                [self updateUIAfterWeixinAuthRequestDone];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:@"WeixinAuthRequestDone" object:nil];
            }
        });
    });
}

- (void)updateUIAfterWeixinAuthRequestDone {
   
    
    if ([AppConstants AppDelegate].WXErrCode == 0) {
        
        [ProgressHUD show:NSLocalizedStringCN(@"dengluzhong", @"")];
        
        [self sendOAuthLoginRequest:[AppConstants WXOpenid] andOAuthName:@"WECHAT"];
    }
}
//第三方登录
- (void)WeiboLoginRequest {
    
    [ProgressHUD show:NSLocalizedStringCN(@"dengluzhong", @"")];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"weiboLoginRequest" object:nil];
    
    [self sendOAuthLoginRequest:[AppConstants WeiboId] andOAuthName:@"SINA"];
}

#pragma mark - 登录的事件
- (void)loginButtonPress {
    NSLog(@"loginButtonPress");
    [self hideKeyboard];
    [self clearLabels];
    
    if (_username.text.length == 0) {
        [self usernameInputWarning];
    }
    else if (_password.text.length == 0) {
        [self passwordInputWarning];
    }
    else {
        [self sendOriginLoginRequest];
    }
}

- (void)sendOriginLoginRequest {
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@authentication/user/login/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"UserId":_username.text, @"Password":_password.text};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"success urlString = %@", urlString);
              NSLog(@"Success: %@", responseObject);
              
              [_spinner stopAnimating];
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  NSLog(@"set accessToken");
                  
                  [AppConstants userInfo].accessToken = [responseObject objectForKey:@"AccessToken"];
                  [AppConstants userInfo].account = _username.text;
                  [AppConstants userInfo].password = _password.text;
                  [AppConstants userInfo].OAuthName = @"";
                  [AppConstants userInfo].openid = @"";
                  
                  [AppConstants saveUserInfo];
                  
                  [self getOriginUserInfo];
                  
              }
              else if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 0) {
                  [self wrongInputWarning];
                  [ProgressHUD showError:[responseObject objectForKey:@"errmsg"]];
              }
              
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              [_spinner stopAnimating];
              [self badNetworkWarning];
          }];
}

- (void)wrongInputWarning {
    _loginResultTipLabel = [[UILabel alloc] init];
    _loginResultTipLabel.font = [UIFont systemFontOfSize:14];
    _loginResultTipLabel.textColor = [UIColor colorWithHexString:@"#666666"];
    _loginResultTipLabel.text = NSLocalizedStringCN(@"loginusernamepasswordwrongtip", @"");
    
    [self.view addSubview:_loginResultTipLabel];
    
    [_loginResultTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_loginButton.mas_top).with.offset(-5);
        make.centerX.equalTo(self.view);
    }];
    
    _loginButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
    _loginResultTipLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations: ^{
                         _loginButton.transform = CGAffineTransformMakeScale(1, 1);
                         _loginResultTipLabel.transform = CGAffineTransformMakeScale(1, 1);
                     }completion:nil];
}

- (void)badNetworkWarning {
    _loginResultTipLabel = [[UILabel alloc] init];
    _loginResultTipLabel.font = [UIFont systemFontOfSize:14];
    _loginResultTipLabel.textColor = [UIColor redColor];
    _loginResultTipLabel.text = NSLocalizedStringCN(@"badNetwork", @"");
    
    [self.view addSubview:_loginResultTipLabel];
    
    [_loginResultTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_loginButton.mas_top).with.offset(-5);
        make.left.equalTo(_loginButton).with.offset(20);
    }];
    
    _loginButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
    _loginResultTipLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations: ^{
                         _loginButton.transform = CGAffineTransformMakeScale(1, 1);
                         _loginResultTipLabel.transform = CGAffineTransformMakeScale(1, 1);
                     }completion:nil];
}


-(void)clearLabels
{
    [_usernameTipLabel removeFromSuperview];
    [_passwordTipLabel removeFromSuperview];
    [_loginResultTipLabel removeFromSuperview];
}
-(void)usernameInputWarning
{
    _usernameTipLabel = [[UILabel alloc] init];
    _usernameTipLabel.font = [UIFont systemFontOfSize:14];
    _usernameTipLabel.textColor = [UIColor colorWithHexString:@"#666666"];
    
    _usernameTipLabel.text = NSLocalizedStringCN(@"loginusernametip", @"");
    [self.view addSubview:_usernameTipLabel];
    [_usernameTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_loginButton.mas_top).with.offset(-5);
        make.centerX.equalTo(self.view);
    }];
    _username.transform = CGAffineTransformMakeScale(0.8, 0.8);
    _usernameTipLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
    _userImageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations: ^{
                         _username.transform = CGAffineTransformMakeScale(1, 1);
                         _usernameTipLabel.transform = CGAffineTransformMakeScale(1, 1);
                         _userImageView.transform = CGAffineTransformMakeScale(1, 1);
                     }completion:nil];
    
}

-(void)passwordInputWarning
{
    _passwordTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, CGRectGetMaxY(_username.frame)+5, [UIScreen mainScreen].bounds.size.width-60, 30)];
    _passwordTipLabel.font = [UIFont systemFontOfSize:14];
    _passwordTipLabel.textColor = [UIColor colorWithHexString:@"#666666"];
    _passwordTipLabel.text = NSLocalizedStringCN(@"loginpasswordtip", @"");
    [self.view addSubview:_passwordTipLabel];
    [_passwordTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_loginButton.mas_top).with.offset(-5);
        make.centerX.equalTo(self.view);
    }];
    _password.transform = CGAffineTransformMakeScale(0.8, 0.8);
    _passwordTipLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
    _passWordImageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations: ^{
                         _password.transform = CGAffineTransformMakeScale(1, 1);
                         _passwordTipLabel.transform = CGAffineTransformMakeScale(1, 1);
                         _passWordImageView.transform = CGAffineTransformMakeScale(1, 1);
                     }completion:nil];
    
    
}
#pragma mark - 注册的事件
- (void)registerButtonPress {
    NSLog(@"registerButtonPress");
    [self hideKeyboard];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerSuccess) name:@"registerSuccess" object:nil];
    
    RegisterViewController *registerViewController = [[RegisterViewController alloc] init];
    
    [self.navigationController pushViewController:registerViewController animated:YES];
}
//通知的点击事件
- (void)registerSuccess {
    _isRegisterSuccess = YES;
}

- (void)sendOAuthLoginRequest:(NSString*)userid andOAuthName:(NSString*)OAuthName {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@authentication/oauth/login/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"OpenID":userid, @"OAuthName":OAuthName};
    
    NSLog(@"parameters = %@", parameters);
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"success urlString = %@", urlString);
              NSLog(@"Success: %@", responseObject);
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  NSLog(@"第三方登录成功 %@", urlString);
                  
                  [ProgressHUD showSuccess:NSLocalizedStringCN(@"dengluchenggong", @"")];
                  /*
                   [PlistEditor alterPlist:@"AppInfo" addValue:@"YES" forKey:@"isLogin"];
                   [PlistEditor alterPlist:@"AppInfo" addValue:OAuthName forKey:@"loginType"];
                   [PlistEditor alterPlist:@"AppInfo" addValue:userid forKey:@"openid"];
                   
                   [AppConstants writeDic2File];
                   
                   [AppConstants setOriginAccessToken:[responseObject objectForKey:@"AccessToken"]];*/
                  
                  [AppConstants userInfo].accessToken = [responseObject objectForKey:@"AccessToken"];
                  [AppConstants userInfo].account = @"";
                  [AppConstants userInfo].password = @"";
                  [AppConstants userInfo].OAuthName = OAuthName;
                  [AppConstants userInfo].openid = userid;
                  
                  [AppConstants saveUserInfo];
                  
                  [self getOriginUserInfo];
                  
                  //                  [self getoUserInfoWithOAuthName:OAuthName];
                  
                  //                  [self setLoginedInfo:OAuthName];
                  
                  [NSThread detachNewThreadSelector:@selector(timedPop) toTarget:self withObject:nil];
              }
              else if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 0) {
                  NSLog(@"第三方登录失败 %@", urlString);
                  
                  if ([OAuthName isEqualToString:@"WECHAT"]) {
                      [self sendOAuthRegisterRequest:[AppConstants WXOpenid] andOAuthName:OAuthName andNickName:[AppConstants WXNickname] andSex:[AppConstants WXSex] andMobile:[AppConstants WXMobile] andEmail:[AppConstants WXEmail] andBirthday:[AppConstants WXBirthday] andAvatarPicUrl:[AppConstants WXHeadimgurl] andProvince:[AppConstants WXProvince] andCity:[AppConstants WXCity] andAddress:[AppConstants WXAddress]];
                  }
                  else if ([OAuthName isEqualToString:@"QQ"]) {
                      [self sendOAuthRegisterRequest:[AppConstants QQOpenId] andOAuthName:OAuthName andNickName:[AppConstants QQNickname] andSex:[AppConstants QQGender] andMobile:@"" andEmail:@"" andBirthday:@"" andAvatarPicUrl:[AppConstants QQImageUrl2] andProvince:[AppConstants QQProvince] andCity:[AppConstants QQCity] andAddress:@""];
                  }
                  else if ([OAuthName isEqualToString:@"SINA"]) {
                      [self sendOAuthRegisterRequest:[AppConstants WeiboId] andOAuthName:OAuthName andNickName:[AppConstants WeiboUsername] andSex:[AppConstants WeiboGender] andMobile:@"" andEmail:@"" andBirthday:@"" andAvatarPicUrl:[AppConstants WeiboImageUrlHD] andProvince:@"" andCity:[AppConstants WeiboCity] andAddress:@""];
                  }
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

- (void)sendOAuthRegisterRequest:(NSString*)userid andOAuthName:(NSString*)OAuthName andNickName:(NSString*)nickname andSex:(NSString*)sex andMobile:(NSString*)mobile andEmail:(NSString*)email andBirthday:(NSString*)birth andAvatarPicUrl:(NSString*)avatarPicUrl andProvince:(NSString*)province andCity:(NSString*)city andAddress:(NSString*)address {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@authentication/oauth/register/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"OpenID":userid, @"OAuthName":OAuthName, @"NickName":nickname, @"Sex":sex, @"Mobile":mobile, @"Email":email, @"Birthday":birth,  @"AvatarPicUrl":avatarPicUrl,  @"Province":province,  @"City":city,  @"Address":address};
    
    NSLog(@"parameters = %@", parameters);
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"success urlString = %@", urlString);
              NSLog(@"Success: %@", responseObject);
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  NSLog(@"注册成功 %@", urlString);
                  
                  [AppConstants userInfo].accessToken = [responseObject objectForKey:@"AccessToken"];
                  
                  [AppConstants userInfo].account = @"";
                  [AppConstants userInfo].password = @"";
                  [AppConstants userInfo].OAuthName = OAuthName;
                  [AppConstants userInfo].openid = userid;
                  
                  [AppConstants saveUserInfo];
                  
                  [self getOriginUserInfo];
                  
              }
              else if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 0) {
                  NSLog(@"注册失败 %@", urlString);
                  
                  [ProgressHUD showError:NSLocalizedStringCN(@"denglushibai", @"")];
              }
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"false urlString = %@", urlString);
              NSLog(@"Error: %@", error);
              
              [ProgressHUD showError:NSLocalizedStringCN(@"badNetwork", @"")];
          }];
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
              NSLog(@"1success urlString = %@", urlString);
              NSLog(@"1Success: %@", responseObject);
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  [ProgressHUD showSuccess:NSLocalizedStringCN(@"dengluchenggong", @"")];
                  /*
                   [AppConstants setCurrentOImageUrl:[[responseObject objectForKey:@"avatarPic"] objectForKey:@"avatarURL"]];
                   [AppConstants setCurrentOName:[responseObject objectForKey:@"nickname"]];
                   [AppConstants setCurrentOGender:[responseObject objectForKey:@"sex"]];
                   [AppConstants setCurrentOLocation:[[responseObject objectForKey:@"address"] objectForKey:@"city"]];
                   */
                  
                  [AppConstants userInfo].userId = [responseObject objectForKey:@"userid"];
                  [AppConstants userInfo].nickname = [responseObject objectForKey:@"nickname"];
                  [AppConstants userInfo].sex = [responseObject objectForKey:@"sex"];
                  [AppConstants userInfo].mobile = [responseObject objectForKey:@"mobile"] ;
                  [AppConstants userInfo].avatarURL = [[responseObject objectForKey:@"avatarPic"] objectForKey:@"avatarURL"];
                  
                  [AppConstants saveUserInfo];
                  
                  [self loginSuccess];
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

#pragma mark - 初始化navigationBar
-(void)initNavigationBar
{
    self.navigationItem.title = NSLocalizedStringCN(@"denglu", @"");
}
- (void)forgotPassword {
    NSLog(@"forgotPassword");
    [self hideKeyboard];
    
    ForgetPasswordViewController *fpvc = [[ForgetPasswordViewController alloc] init];
    
    fpvc.view.backgroundColor = [AppConstants backgroundColor];
    
    fpvc.navigationItem.title = NSLocalizedStringCN(@"forgetpassword", @"");
    
    [self.navigationController pushViewController:fpvc animated:YES];
}
#pragma mark - 隐藏键盘
- (void)hideKeyboard {
    [_username resignFirstResponder];
    [_password resignFirstResponder];
}
#pragma mark - 点击任意地方回收键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self hideKeyboard];
}
#pragma mark WBHttpRequestDelegate

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    NSLog(@"weibo didfinish");
    
    NSString *title = nil;
    UIAlertView *alert = nil;
    
    title = NSLocalizedStringCN(@"收到网络回调", nil);
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:[NSString stringWithFormat:@"%@",result]
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedStringCN(@"确定", nil)
                             otherButtonTitles:nil];
    [alert show];
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error;
{
    NSLog(@"weibo didfail");
    
    NSString *title = nil;
    UIAlertView *alert = nil;
    
    title = NSLocalizedStringCN(@"请求异常", nil);
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:[NSString stringWithFormat:@"%@",error]
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedStringCN(@"确定", nil)
                             otherButtonTitles:nil];
    [alert show];
}
#pragma mark - WXApiDelegate
- (void)managerDidRecvGetMessageReq:(GetMessageFromWXReq *)req {
    // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
    NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
    NSString *strMsg = [NSString stringWithFormat:@"openID: %@", req.openID];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle
                                                    message:strMsg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    alert.tag = 1000;
    [alert show];
}

- (void)managerDidRecvShowMessageReq:(ShowMessageFromWXReq *)req {
    WXMediaMessage *msg = req.message;
    
    //显示微信传过来的内容
    WXAppExtendObject *obj = msg.mediaObject;
    
    NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
    NSString *strMsg = [NSString stringWithFormat:@"openID: %@, 标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%lu bytes\n附加消息:%@\n", req.openID, msg.title, msg.description, obj.extInfo, (unsigned long)msg.thumbData.length, msg.messageExt];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle
                                                    message:strMsg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)managerDidRecvLaunchFromWXReq:(LaunchFromWXReq *)req {
    WXMediaMessage *msg = req.message;
    
    //从微信启动App
    NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
    NSString *strMsg = [NSString stringWithFormat:@"openID: %@, messageExt:%@", req.openID, msg.messageExt];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle
                                                    message:strMsg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response {
    if (response.errCode == 0) {
        [ProgressHUD showSuccess:NSLocalizedStringCN(@"fenxiangchenggong", @"")];
    }
    else {
        [ProgressHUD showSuccess:NSLocalizedStringCN(@"fenxiangshibai", @"")];
    }
}

- (void)managerDidRecvAddCardResponse:(AddCardToWXCardPackageResp *)response {
    NSMutableString* cardStr = [[NSMutableString alloc] init];
    for (WXCardItem* cardItem in response.cardAry) {
        [cardStr appendString:[NSString stringWithFormat:@"cardid:%@ cardext:%@ cardstate:%u\n",cardItem.cardId,cardItem.extMsg,(unsigned int)cardItem.cardState]];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"add card resp"
                                                    message:cardStr
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)managerDidRecvAuthResponse:(SendAuthResp *)response {
    if (response.errCode == 0) {
        [AppConstants setWXCode:response.code];
        [self getAccess_token];
    }
    else if (response.errCode == -2) {
        [ProgressHUD showError:NSLocalizedStringCN(@"dengluquxiao", @"")];
    }
    else if (response.errCode == -4) {
        [ProgressHUD showError:NSLocalizedStringCN(@"denglujujue", @"")];
    }
    
    /*
     NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
     NSString *strMsg = [NSString stringWithFormat:@"code:%@,state:%@,errcode:%d", response.code, response.state, response.errCode];
     
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle
     message:strMsg
     delegate:self
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil, nil];
     [alert show];*/
}



#pragma mark - QQ Delegate
-(void)tencentDidLogin
{
    NSLog(@"tencentDidLogin");
    
    /*
     _labelTitle.text = @"登录完成";
     */
    if (_oauth.accessToken && 0 != [_oauth.accessToken length])
    {
        //  记录登录用户的OpenID、Token以及过期时间
        NSLog(@"accessToken = %@, openId = %@", _oauth.accessToken, _oauth.openId);
        
        [AppConstants setQQAccessToken:_oauth.accessToken];
        [AppConstants setQQOpenId:_oauth.openId];
        
        [PlistEditor alterPlist:@"AppInfo" addValue:_oauth.openId forKey:@"QQOpenId"];
        
        [AppConstants writeDic2File];
        
        [_oauth getUserInfo];
    }
    else
    {
        //        _labelAccessToken.text = @"登录不成功 没有获取accesstoken";
    }
}


-(void)tencentDidLogout
{
    
}
-(void)tencentDidNotNetWork
{
    
}
-(void)getUserInfoResponse:(APIResponse *)response
{
    NSLog(@"QQ API Response = %@", response.jsonResponse);
    
    [AppConstants setQQImageUrl1:[response.jsonResponse valueForKey:@"figureurl_qq_1"]];
    [AppConstants setQQImageUrl2:[response.jsonResponse valueForKey:@"figureurl_qq_2"]];
    [AppConstants setQQNickname:[response.jsonResponse valueForKey:@"nickname"]];
    [AppConstants setQQCity:[response.jsonResponse valueForKey:@"city"]];
    
    
    if ([[response.jsonResponse valueForKey:@"gender"] isEqualToString:@"男"])
    {
        [AppConstants setQQGender:@"男"];
    }
    else if ([[response.jsonResponse valueForKey:@"gender"] isEqualToString:@"女"]) {
        [AppConstants setQQGender:@"女"];
    }
    else {
        [AppConstants setQQGender:@""];
    }
    
    [AppConstants setQQProvince:[response.jsonResponse valueForKey:@"province"]];
    
    [ProgressHUD show:NSLocalizedStringCN(@"dengluzhong", @"")];
    
    [PlistEditor alterPlist:@"AppInfo" addValue:[response.jsonResponse valueForKey:@"figureurl_qq_1"] forKey:@"QQImageUrl1"];
    [PlistEditor alterPlist:@"AppInfo" addValue:[response.jsonResponse valueForKey:@"figureurl_qq_2"] forKey:@"QQImageUrl2"];
    [PlistEditor alterPlist:@"AppInfo" addValue:[response.jsonResponse valueForKey:@"nickname"] forKey:@"QQNickname"];
    [PlistEditor alterPlist:@"AppInfo" addValue:[response.jsonResponse valueForKey:@"city"] forKey:@"QQCity"];
    [PlistEditor alterPlist:@"AppInfo" addValue:[response.jsonResponse valueForKey:@"gender"] forKey:@"QQGender"];
    [PlistEditor alterPlist:@"AppInfo" addValue:[response.jsonResponse valueForKey:@"province"] forKey:@"QQProvince"];
    
    [AppConstants writeDic2File];
    
    [self sendOAuthLoginRequest:[AppConstants QQOpenId] andOAuthName:@"QQ"];
    
}
@end
