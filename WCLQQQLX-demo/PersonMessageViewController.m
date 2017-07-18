//
//  PersonMessageViewController.m
//  歌力思
//
//  Created by greenis on 16/8/2.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "PersonMessageViewController.h"
#import "FSMediaPicker.h"
#import "ChangePasswordViewController.h"
#import "BindingViewController.h"
#import "OSSService.h"
@interface PersonMessageViewController ()<UIActionSheetDelegate,FSMediaPickerDelegate>
@property (strong, nonatomic) UIImage                       *selectedImage;
@property (strong, nonatomic) NSString                      *uploadImageUrl;
@property (strong, nonatomic) UILabel                       *usernameLabel;
@property (strong, nonatomic) UIButton                      *changePasswordButton;//修改密码
@property (strong, nonatomic) UIButton                      *bindingButton;//忘记
@property (strong, nonatomic) UIButton                      *logoutButton;//
@property (strong, nonatomic) OSSClient *client;
@property(nonatomic,strong)NSString * AccessKeyId;
@property(nonatomic,strong)NSString * AccessKeySecret;
@property(nonatomic,strong)NSString * securityToken;
@property(nonatomic,strong)NSString * endPoint;
@end

@implementation PersonMessageViewController
{
    UIButton * _mainImgButton;//主图片
    UIImageView * _sexImg;//性别图片
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor= [UIColor whiteColor];
    [self initNavigationBar];
    [self initViews];
}
-(void)initOSSClient
{
    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:_AccessKeyId secretKeyId:_AccessKeySecret securityToken:_securityToken];
    _client = [[OSSClient alloc] initWithEndpoint:_endPoint credentialProvider:credential];
}
-(void)initNavigationBar
{
    self.navigationItem.title = NSLocalizedStringCN(@"gerenxinxi", @"");
    //设置导航栏的返回按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = item;
    //更改导航栏的返回图标"<"的颜色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"#CCCCCC"];
}
-(void)initViews
{
    _mainImgButton = [[UIButton alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-100)/2, 94, 100, 100)];
    [self.view addSubview:_mainImgButton];
    _mainImgButton.layer.masksToBounds = YES;
    _mainImgButton.layer.cornerRadius = 50;
    _mainImgButton.layer.borderColor = [UIColor colorWithHexString:@"#CCCCCC"].CGColor;
    _mainImgButton.layer.borderWidth =2;
    if ([[AppConstants userInfo].avatarURL hasPrefix:@"http:"])
    {
        [_mainImgButton setBackgroundImageWithURL:[NSURL URLWithString:[AppConstants userInfo].avatarURL] forState:UIControlStateNormal options:1];
    }
    else
    {
        [_mainImgButton setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [AppConstants httpImageHeader], [AppConstants userInfo].avatarURL]]  forState:UIControlStateNormal options:1];
    }
    if ([[AppConstants userInfo].avatarURL isEqual: @""]) {
        [_mainImgButton setBackgroundImage:[UIImage imageNamed:@"placeholder.jpg"] forState:UIControlStateNormal];
    }
    [_mainImgButton addTarget:self action:@selector(photoBtn) forControlEvents:UIControlEventTouchUpInside];
    _usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-100)/2, CGRectGetMaxY(_mainImgButton.frame)+5, 100, 30)];
    _usernameLabel.font = [UIFont boldSystemFontOfSize:16];
    _usernameLabel.textColor = [UIColor blackColor];
    _usernameLabel.text = [AppConstants userInfo].nickname;
    _usernameLabel.textAlignment = NSTextAlignmentCenter;
    _usernameLabel.numberOfLines = 0;
    
    [self.view addSubview:_usernameLabel];
    
    _sexImg = [[UIImageView alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width- 20) / 2 , CGRectGetMaxY(_usernameLabel.frame)+5, 20, 20)];
    [self.view addSubview:_sexImg];
    UIImage *genderImage;
    
    if ([[AppConstants userInfo].sex isEqualToString:@"男"]) {
        genderImage = [UIImage imageNamed:@"male.png"];
    }
    else if ([[AppConstants userInfo].sex isEqualToString:@"女"]) {
        genderImage = [UIImage imageNamed:@"female.png"];
    }
    else {
        genderImage = [UIImage imageNamed:@"male.png"];
    }
    _sexImg.image = genderImage;
    _changePasswordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _changePasswordButton.layer.cornerRadius = 3;
    [_changePasswordButton setTitle:NSLocalizedStringCN(@"xiugaimima", @"") forState:UIControlStateNormal];
    _changePasswordButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [_changePasswordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_changePasswordButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_changePasswordButton addTarget:self action:@selector(changePassword) forControlEvents:UIControlEventTouchUpInside];
    _changePasswordButton.backgroundColor = [UIColor colorWithHexString:@"#FFCC33"];
    [self.view addSubview:_changePasswordButton];
    _changePasswordButton.frame = CGRectMake(30, CGRectGetMaxY(_sexImg.frame) + 30, [UIScreen mainScreen].bounds.size.width - 60, 40);
    
    _bindingButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _bindingButton.layer.cornerRadius = 3;
    [_bindingButton setTitle:NSLocalizedStringCN(@"binding", @"") forState:UIControlStateNormal];
    _bindingButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [_bindingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_bindingButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_bindingButton addTarget:self action:@selector(binding) forControlEvents:UIControlEventTouchUpInside];
    _bindingButton.backgroundColor = [UIColor colorWithHexString:@"#FFCC33"];
    [self.view addSubview:_bindingButton];
    _bindingButton.frame = CGRectMake(30, CGRectGetMaxY(_changePasswordButton.frame) + 10,[UIScreen mainScreen].bounds.size.width - 60, 40);
    
    _logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _logoutButton.layer.cornerRadius = 3;
    [_logoutButton setTitle:NSLocalizedStringCN(@"tuichudenglu", @"") forState:UIControlStateNormal];
    _logoutButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [_logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_logoutButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    _logoutButton.backgroundColor = [UIColor colorWithHexString:@"#FFCC33"];
    [self.view addSubview:_logoutButton];
    _logoutButton.frame = CGRectMake(30, CGRectGetMaxY(_bindingButton.frame) + 10,[UIScreen mainScreen].bounds.size.width - 60, 40);

}

- (void)changePassword {
    ChangePasswordViewController *cpvc = [[ChangePasswordViewController alloc] init];
    
    cpvc.view.backgroundColor = [AppConstants backgroundColor];
    
    cpvc.navigationItem.title = NSLocalizedStringCN(@"xiugaimima", @"");
    
    [self.navigationController pushViewController:cpvc animated:YES];
}

- (void)binding {
    NSLog(@"binding");
    
    BindingViewController *bvc = [[BindingViewController alloc] init];
    
    bvc.view.backgroundColor = [AppConstants backgroundColor];
    
    bvc.navigationItem.title = NSLocalizedStringCN(@"binding", @"");
    
    [self.navigationController pushViewController:bvc animated:YES];
}
- (void)logout {
    [AppConstants clearUserInfo];
    
    [ProgressHUD showSuccess:NSLocalizedStringCN(@"tuichuchenggong", @"")];
    
    [NSThread detachNewThreadSelector:@selector(timedPop) toTarget:self withObject:nil];
}

- (void)timedPop
{
    @autoreleasepool
    {
        NSTimeInterval sleep = 1.0;
        
        [NSThread sleepForTimeInterval:sleep];
        [self logoutSuccess];
    }
}

- (void)logoutSuccess {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LogoutSuccess" object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    });
}



-(void)photoBtn
{
    UIActionSheet * actionsheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedStringCN(@"quxiao", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedStringCN(@"xiangji", @""),NSLocalizedStringCN(@"xiangce", @""), nil];
    [actionsheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    FSMediaPicker *mediaPicker = [[FSMediaPicker alloc] init];
    mediaPicker.delegate = self;
    switch (buttonIndex) {
        case 0:
        {
            [mediaPicker takePhotoFromCamera];//从相机
        }
            break;
        case 1:
        {
            [mediaPicker takePhotoFromPhotoLibrary];//从相册
        }
            break;
        default:
            break;
    }
}

-(void)mediaPicker:(FSMediaPicker *)mediaPicker didFinishWithMediaInfo:(NSDictionary *)mediaInfo
{
    _selectedImage = mediaInfo.editedImage;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploadSuccess) name:@"changeImageUploadSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploadFail) name:@"changeImageUploadFail" object:nil];
    
    [ProgressHUD show:NSLocalizedStringCN(@"zhengzaishangchuantupian", @"")];
    
    NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(uploadImage)
                                                   object:nil];
    [myThread start];

}
-(void)uploadImage
{
    UIImage * image = _selectedImage;
    UIImage * uploadImage = [self compressImage:image toMaxFileSize:300];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
   // NSString *urlString = [NSString stringWithFormat:@"%@interaction/image/upload/index.ashx", [AppConstants httpHeader]];
     NSString *urlString = [NSString stringWithFormat:@"%@interaction/image/query/ali/oss/certificate/index.ashx", [AppConstants httpHeader]];
        NSDictionary *parameters = @{@"AccessToken":[AppConstants userInfo].accessToken,@"Ext":@"jpg"};
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        OSSPutObjectRequest * put = [OSSPutObjectRequest new];
        if ([[responseObject objectForKey:@"ok"]intValue]==1) {
            NSDictionary * aliCertificate = [responseObject objectForKey:@"AliOSSImageCertificate"];
            NSLog(@"令牌 %@",aliCertificate);
            _AccessKeyId = [aliCertificate objectForKey:@"AccessKeyId"];
            _AccessKeySecret =[aliCertificate objectForKey:@"AccessKeySecret"];
            _securityToken = [aliCertificate objectForKey:@"SecurityToken"];
            NSDictionary * aliObject = [responseObject objectForKey: @"AliOSSImageObject"];
            NSLog(@"ali:%@",aliObject);
            _endPoint =[NSString stringWithFormat:@"http://%@",aliObject[@"Endpoint"]];
            put.bucketName = [aliObject objectForKey:@"bucketName"];
            put.objectKey = [aliObject objectForKey:@"imageUrl"];
        }
        else if ([[responseObject objectForKey:@"errno"] isEqualToString:@"4401"])
        {
            [AppConstants relogin:^(BOOL success) {
                if (success) {
                    [self uploadImage];
                }
                else
                {
                    [AppConstants notice2ManualRelogin];
                }
                
            }];

        }
         [self initOSSClient];
        NSData * data = UIImageJPEGRepresentation(uploadImage, 1);
        put.uploadingData = data; // 直接上传NSData
        OSSTask * putTask = [_client putObject:put];
       [putTask continueWithBlock:^id _Nullable(OSSTask * _Nonnull task) {
           if (!task.error) {
               NSLog(@"upload object success!");
               OSSPutObjectResult * result = task.result;
               NSLog(@"Result - requestId: %@", result.requestId);
               NSString * nst = [NSString stringWithFormat:@"%@/%@",[AppConstants httpChinaAndEnglishForHead],put.objectKey];
               _uploadImageUrl = nst;
               [[NSNotificationCenter defaultCenter] postNotificationName:@"changeImageUploadSuccess" object:nil];
           }
           else {
               
               NSLog(@"upload object failed, error: %@" , task.error);
               [[NSNotificationCenter defaultCenter] postNotificationName:@"changeImageUploadFail" object:nil];
           }
           return nil;
       }];
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"false urlString = %@", urlString);
        //        NSLog(@"Error: %@", error);
               [[NSNotificationCenter defaultCenter] postNotificationName:@"changeImageUploadFail" object:nil];
    }];
}
-(UIImage *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize
{
    //压缩
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length]/1000 > maxFileSize && compression > maxCompression) {
        NSLog(@"compress");
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    return compressedImage;
}
- (void)imageUploadSuccess {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeImageUploadSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeImageUploadFail" object:nil];
    
    NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(changeUserImage)
                                                   object:nil];
    [myThread start];
}
- (void)changeUserImage {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@authentication/user/avatar/custom/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"AccessToken":[AppConstants userInfo].accessToken, @"AvatarPic":_uploadImageUrl};
    
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation,id responseObject) {
        //        NSLog(@"success urlString = %@", urlString);
        //        NSLog(@"Success: %@", responseObject);
        
        if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
            [self getOriginUserInfo];
        }
        else if ([[responseObject objectForKey:@"errno"] isEqualToString:@"4401"]) {
            [AppConstants relogin:^(BOOL success){
                if (success) {
                    [self changeUserImage];
                }
                else {
                    [AppConstants notice2ManualRelogin];
                }
            }];
        }
        else {
            [ProgressHUD showSuccess:NSLocalizedStringCN(@"xiugaitouxiangshibai", @"")];
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
              //              NSLog(@"success urlString = %@", urlString);
              //              NSLog(@"Success: %@", responseObject);
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  /*
                   [AppConstants setCurrentOImageUrl:[[responseObject objectForKey:@"avatarPic"] objectForKey:@"avatarURL"]];
                   [AppConstants setCurrentOName:[responseObject objectForKey:@"nickname"]];
                   [AppConstants setCurrentOGender:[responseObject objectForKey:@"sex"]];
                   [AppConstants setCurrentOLocation:[[responseObject objectForKey:@"address"] objectForKey:@"city"]];
                   */
                  
                  [AppConstants userInfo].avatarURL = [[responseObject objectForKey:@"avatarPic"] objectForKey:@"avatarURL"];
                  
                  [AppConstants saveUserInfo];
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if ([[AppConstants userInfo].avatarURL hasPrefix:@"http:"]) {
                          [_mainImgButton setBackgroundImageWithURL:[NSURL URLWithString:[AppConstants userInfo].avatarURL] forState:UIControlStateNormal placeholder:[UIImage imageNamed:@"icon.png"]];
                      }
                      else {
                          [_mainImgButton setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [AppConstants httpChinaAndEnglishForHead], [AppConstants userInfo].avatarURL]] forState:UIControlStateNormal placeholder:[UIImage imageNamed:@"icon.png"]];
                      }
                  });
                  
                  [ProgressHUD showSuccess:NSLocalizedStringCN(@"xiugaitouxiangchenggong", @"")];
                  
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"changeImage" object:nil];
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
                  NSLog(@"local 获取个人信息失败");
              }
              
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"false urlString = %@", urlString);
              NSLog(@"Error: %@", error);
          }];
}
- (void)imageUploadFail {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"imageUploadSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"imageUploadFail" object:nil];
    
    [ProgressHUD showError:NSLocalizedStringCN(@"shangchuantupianshibai", @"")];
}

- (void)mediaPickerDidCancel:(FSMediaPicker *)mediaPicker
{
    NSLog(@"%s",__FUNCTION__);
}
@end
