//
//  PostViewController.m
//  SmartKitchen
//
//  Created by LICAN LONG on 15/12/1.
//  Copyright © 2015年 LICAN LONG. All rights reserved.
//

#import "PostViewController.h"
#import "UIPlaceHolderTextView.h"
#import "Masonry.h"
#import "AppConstants.h"
#import "PostPhotoBrowserViewController.h"
#import "LocalImageViewController.h"
#import "MyViewController.h"
#import "AFNetworking.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "OSSService.h"
#import "ProgressHUD.h"





@interface PostViewController () <UITextViewDelegate, LocalImageViewControllerDelegate, UIScrollViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIScrollView                      *verticalScrollView;
@property (strong, nonatomic) UIView                            *verticalScrollViewContainer;
@property (strong, nonatomic) NSMutableArray                    *images;
@property (strong, nonatomic) NSMutableArray                    *imageViews;
@property (strong, nonatomic) UIPlaceHolderTextView             *textView;
@property (strong, nonatomic) LocalImageViewController          *localImageViewController;
@property (strong, nonatomic) UIView                            *imagesContainer;
@property (strong, nonatomic) UIView                            *lastView;
@property (strong, nonatomic) UIView                            *rightView;
@property (strong, nonatomic) UIImageView                       *addImageView;
@property (strong, nonatomic) NSMutableDictionary               *uploadImageUrls;
@property (strong, nonatomic) NSString                          *ID;
@property (strong, nonatomic) NSString                          *prefix;
@property (strong, nonatomic) OSSClient *client;
@property(nonatomic,strong)NSString * AccessKeyId;
@property(nonatomic,strong)NSString * AccessKeySecret;
@property(nonatomic,strong)NSString * securityToken;
@property(nonatomic,strong)NSString * endPoint;
@property(nonatomic,strong)NSMutableArray * TokenArray;
@property(nonatomic,strong)NSMutableArray * picArray;
@end

@implementation PostViewController

-(instancetype)initWithImages:(NSMutableArray*)images andPrefix:(NSString*)prefix andID:(NSString *)ID{
    self = [super init];
    if (self) {
        _images = [[NSMutableArray alloc] initWithCapacity:10];
        _imageViews = [[NSMutableArray alloc] initWithCapacity:10];
        _ID  = ID;
        _prefix = prefix;
        NSLog(@"id = %@", _ID);
        
        _images = images;
        
        _uploadImageUrls = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < 9; i++) {
            [_uploadImageUrls setObject:@"" forKey:[NSString stringWithFormat:@"imageUrl%d", i]];
        }
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [ProgressHUD dismiss];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _TokenArray = [NSMutableArray array];
    _picArray = [NSMutableArray array];
    [self initNavigationBar];
    [self initVerticalScrollView];
    [self initTextView];
    [self initImagesView];
    
}
-(void)initOSSClient
{
    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:_AccessKeyId secretKeyId:_AccessKeySecret securityToken:_securityToken];
    _client = [[OSSClient alloc] initWithEndpoint:_endPoint credentialProvider:credential];
}
- (void)initNavigationBar {
    self.navigationItem.title = NSLocalizedStringCN(@"fabiaoliaoliao", @"");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringCN(@"tuichu", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(exit)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringCN(@"send", @"") style:UIBarButtonItemStylePlain target:self action:@selector(sendButtonPress)];
}

- (void)exit {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringCN(@"tishi", @"") message:NSLocalizedStringCN(@"shifoutuichubianji", @"") delegate:self cancelButtonTitle:NSLocalizedStringCN(@"quxiao", @"") otherButtonTitles:NSLocalizedStringCN(@"queding", @""),nil];
    [alert show];
}

#pragma marks -- UIAlertView Delegate
//根据被点击按钮的索引处理点击事件
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)sendButtonPress {
    if ([_images count] == 0 && _textView.text.length == 0) {
        [_textView resignFirstResponder];
        [ProgressHUD showError:NSLocalizedStringCN(@"shuodianshenmeba", @"")];
        
        return;
    }
    else if ([_images count] == 0 && _textView.text.length != 0) {
        [_textView resignFirstResponder];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendPostSuccess) name:@"sendPostSuccess" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendPostFail) name:@"sendPostFail" object:nil];
        [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploadSuccess) name:@"imageUploadSuccess" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploadFail) name:@"imageUploadFail" object:nil];
        [self send];
        
        [ProgressHUD show:NSLocalizedStringCN(@"zhengzaifabiaoliaoliao", @"")];
        
        return;
    }
//    else if ([_images count]!=0 && _textView.text.length ==0)
//    {
//        [_textView resignFirstResponder];
//        NSThread* myThread = [[NSThread alloc] initWithTarget:self
//                                                     selector:@selector(uploadImage)
//                                                       object:nil];
//        [myThread start];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploadSuccess) name:@"imageUploadSuccess" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendPostSuccess) name:@"sendPostSuccess" object:nil];
//        [ProgressHUD show:NSLocalizedStringCN(@"zhengzaifabiaoliaoliao", @"")];
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    else{
    
        NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                     selector:@selector(uploadImage)
                                                       object:nil];
        [myThread start];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploadSuccess) name:@"imageUploadSuccess" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendPostSuccess) name:@"sendPostSuccess" object:nil];
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendPostFail) name:@"sendPostFail" object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUploadFail) name:@"imageUploadFail" object:nil];
        
        [_textView resignFirstResponder];
        
        [ProgressHUD show:NSLocalizedStringCN(@"zhengzaifabiaoliaoliao", @"")];
        [self.navigationController popViewControllerAnimated:YES];
    }
//}

- (void)send {
    NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(sendPost)
                                                   object:nil];
    [myThread start];
}

- (void)imageUploadSuccess {
    NSLog(@"imageUploadSuccess");
    
    for (int i = 0; i < [_images count]; i++) {
        if ([[_uploadImageUrls objectForKey:[NSString stringWithFormat:@"imageUrl%d", i]] isEqualToString:@""]) {
            return;
        }
    }
    
    NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(sendPost)
                                                   object:nil];
    [myThread start];
}

- (void)sendPost {
    NSLog(@"sendPost");
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@interaction/forum/post/index.ashx", [AppConstants httpHeader]];
    
    NSLog(@"CategroyId = %@", _ID);
    
    NSDictionary *parameters = @{@"AccessToken":[AppConstants userInfo].accessToken, @"CategroyId":_ID, @"Image":@"", @"Image1URL":[_uploadImageUrls objectForKey:@"imageUrl0"], @"Image2URL":[_uploadImageUrls objectForKey:@"imageUrl1"], @"Image3URL":[_uploadImageUrls objectForKey:@"imageUrl2"], @"Image4URL":[_uploadImageUrls objectForKey:@"imageUrl3"], @"Image5URL":[_uploadImageUrls objectForKey:@"imageUrl4"], @"Image6URL":[_uploadImageUrls objectForKey:@"imageUrl5"], @"Image7URL":[_uploadImageUrls objectForKey:@"imageUrl6"], @"Image8URL":[_uploadImageUrls objectForKey:@"imageUrl7"], @"Image9URL":[_uploadImageUrls objectForKey:@"imageUrl8"], @"Content":[NSString stringWithFormat:@"%@%@", _prefix, _textView.text]};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"success urlString = %@", urlString);
              NSLog(@"Success: %@", responseObject);
              
              if ([[responseObject objectForKey:@"ok"] intValue] == 1) {
                  [AppConstants setJustPostANewPost:YES];
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"sendPostSuccess" object:nil];
              }
              else if ([[responseObject objectForKey:@"errno"] isEqualToString:@"4401"]) {
                  [AppConstants relogin:^(BOOL success){
                      if (success) {
                          [self sendPost];
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"sendPostSuccess" object:nil];
                      }
                      else {
                          [AppConstants notice2ManualRelogin];
                      }
                  }];
              }
              else {
                  [AppConstants setJustPostANewPost:NO];
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"sendPostFail" object:nil];
              }
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"false urlString = %@", urlString);
              NSLog(@"Error: %@", error);
              [AppConstants setJustPostANewPost:NO];
              [[NSNotificationCenter defaultCenter] postNotificationName:@"sendPostFail" object:nil];
          }];
}

- (void)imageUploadFail {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sendPostFail" object:nil];
}

- (void)sendPostSuccess {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sendPostSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sendPostFail" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"imageUploadSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"imageUploadFail" object:nil];
    [self faSongCGong];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"liaoliaofabiaochenggong" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)faSongCGong
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringCN(@"tishi", @"") message:NSLocalizedStringCN(@"fabiaochenggong", @"") delegate:nil cancelButtonTitle:NSLocalizedStringCN(@"quxiao", @"") otherButtonTitles:NSLocalizedStringCN(@"queding", @""),nil];
    [alert show];
}
- (void)sendPostFail {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sendPostSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sendPostFail" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"imageUploadSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"imageUploadFail" object:nil];
    [ProgressHUD showError:NSLocalizedStringCN(@"fabiaoshibai", @"")];
}

- (void)uploadImage {
    for (int i = 0; i < [_images count]; i++) {
        
        if (![[_uploadImageUrls objectForKey:[NSString stringWithFormat:@"imageUrl%d", i]] isEqualToString:@""]) {
            NSLog(@"%d uploaded", i);
            continue;
        }
        
        NSLog(@"%d not upload", i);
        [NSThread sleepForTimeInterval:0.2];
        UIImage *image = [_images objectAtIndex:i];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        manager.securityPolicy = securityPolicy;
        
        //原来的 NSString *urlString = [NSString stringWithFormat:@"%@interaction/image/upload/index.ashx", [AppConstants httpHeader]];
        NSString *urlString = [NSString stringWithFormat:@"%@interaction/image/query/ali/oss/certificate/index.ashx", [AppConstants httpHeader]];
        NSDictionary *parameters = @{@"AccessToken":[AppConstants userInfo].accessToken,@"Ext":@"jpg"};
        
        [manager POST:urlString parameters:parameters
              success:^(AFHTTPRequestOperation *operation,id responseObject) {
//                  NSLog(@"success urlString = %@", urlString);
                 NSLog(@"阿里云token%dSuccess: %@", i,responseObject);
//                  NSLog(@"%d upload success", i);
                  
                  OSSPutObjectRequest * put = [OSSPutObjectRequest new];
                
                  if ([[responseObject objectForKey:@"ok"]intValue]==1)
                  {
                      
                      NSDictionary * aliCertificate = [responseObject objectForKey:@"AliOSSImageCertificate"];
                      NSLog(@"令牌%d %@",i,aliCertificate);
                      _AccessKeyId = [aliCertificate objectForKey:@"AccessKeyId"];
                      _AccessKeySecret =[aliCertificate objectForKey:@"AccessKeySecret"];
                      _securityToken = [aliCertificate objectForKey:@"SecurityToken"];
                    NSDictionary * aliObject = [responseObject objectForKey: @"AliOSSImageObject"];
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
                  NSData * data = UIImageJPEGRepresentation(image, 0.9);
                  put.uploadingData = data; // 直接上传NSData
                  OSSTask * putTask = [_client putObject:put];
                      [putTask continueWithBlock:^id(OSSTask *task) {
                          NSLog(@"objectKey: %@", put.objectKey);
//                          NSLog(@"bucketname:%@",put.bucketName);
//                           NSLog(@"图片数组%@",_picArray[i]);
                          if (!task.error) {
                                NSLog(@"upload object success!");
                            //  OSSPutObjectResult * result = task.result;
                           //   NSLog(@"Result - requestId: %@", result.requestId);
                              NSString * nst = [NSString stringWithFormat:@"%@/%@",[AppConstants httpChinaAndEnglishForHead],put.objectKey];
                              NSLog(@"wangzhi%d:%@",i,nst);
                              [_uploadImageUrls setObject:nst forKey:[NSString stringWithFormat:@"imageUrl%d", i]];
                              [[NSNotificationCenter defaultCenter] postNotificationName:@"imageUploadSuccess" object:nil];
                          } else {
                              
                              NSLog(@"upload object failed, error: %@" , task.error);
                              [[NSNotificationCenter defaultCenter] postNotificationName:@"imageUploadFail" object:nil];
                          }
                          return nil;
                        
                      }];
                  
            }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
                  NSLog(@"false urlString = %@", urlString);
                  NSLog(@"Error: %@", error);
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"imageUploadFail" object:nil];
              }];
    }
}

- (void)initVerticalScrollView {
    _verticalScrollView = [UIScrollView new];
    _verticalScrollView.backgroundColor = [UIColor whiteColor];
    _verticalScrollView.scrollsToTop = YES;
    _verticalScrollView.delegate = self;
    [self.view addSubview:_verticalScrollView];
    [_verticalScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _verticalScrollViewContainer = [UIView new];
    //    暗灰色
    _verticalScrollViewContainer.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:234.0/255.0 blue:232.0/255.0 alpha:1.0];
    [_verticalScrollView addSubview:_verticalScrollViewContainer];
    [_verticalScrollViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_verticalScrollView);
        make.width.equalTo(_verticalScrollView);
        make.height.mas_equalTo([AppConstants uiScreenHeight] - [AppConstants uiNavigationBarHeight] + 1);
    }];
}

- (void)initTextView {
    
    _textView = [[UIPlaceHolderTextView alloc] init]; //初始化大小并自动释放
    _textView.textColor = [UIColor blackColor];//设置textview里面的字体颜色
    _textView.font = [UIFont fontWithName:@"Arial" size:18.0];//设置字体名字和字体大小
    _textView.delegate = self;//设置它的委托方法
    _textView.backgroundColor = [UIColor whiteColor];//设置它的背景颜色
    _textView.returnKeyType = UIReturnKeyDefault;//返回键的类型
    _textView.keyboardType = UIKeyboardTypeDefault;//键盘类型
    _textView.scrollEnabled = YES;//是否可以拖动
    _textView.placeholder = NSLocalizedStringCN(@"saysomething", @"");
    _textView.placeholderColor = [UIColor lightGrayColor];
    
    [_verticalScrollView addSubview:_textView];//加入到整个页面中
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.and.right.equalTo(_verticalScrollView);
        make.height.mas_equalTo([AppConstants uiScreenHeight] / 3);
    }];
}
//添加的图片
- (void)initImagesView {
    _lastView = nil;
    _rightView = nil;
    
    NSInteger imageCount = [_images count];
    
    NSLog(@"imageCount = %ld", (long)imageCount);
    
    for (int i = 0; i <= imageCount; ++i)
    {
        UIImageView *subv = [[UIImageView alloc] init];
        subv.tag = i;
        
        if (i == imageCount) {
            //            加号图片
            subv.image = [UIImage imageNamed:@"postAddPic"];
        }
        else {
            subv.image = [_images objectAtIndex:i];
        }
        if (i==9) {
            [subv removeFromSuperview];
            return;
        }
        
        if (i == 3) {
            _rightView = subv;
        }
        
        //                subv.delegate = self;
        //        subv.layer.cornerRadius = 3;
        [_verticalScrollView addSubview:subv];
        
        [subv mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i % 4 == 0) {
                make.left.equalTo(_verticalScrollView).with.offset(5);
            }
            else {
                make.left.equalTo(_lastView.mas_right).with.offset(5);
            }
            
            int row = i / 4;
            make.top.equalTo(_textView.mas_bottom).with.offset(row * (([AppConstants uiScreenWidth] / 4 - 5) + 5) + 10);
            make.width.mas_equalTo([AppConstants uiScreenWidth] / 4 - 5);
            make.height.mas_equalTo([AppConstants uiScreenWidth] / 4 - 5);
        }];
        
        _lastView = subv;
        
        subv.userInteractionEnabled = YES;
        UITapGestureRecognizer *contentImageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentImageTaped:)];
        [subv addGestureRecognizer:contentImageTap];
        
        subv.contentMode = UIViewContentModeScaleAspectFill;
        subv.clipsToBounds = YES;
        
        [_imageViews addObject:subv];
    }
}

- (void)contentImageTaped:(UITapGestureRecognizer *)recognizer
{
    UIView *viewT = [recognizer view];
    NSInteger tag = viewT.tag;
    
    if (tag == [_images count]) {
        _localImageViewController = [[LocalImageViewController alloc] init];
        _localImageViewController.maxPhotoNumber = 9 - [_images count];
        _localImageViewController.delegate = self;
        _localImageViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:_localImageViewController animated:YES];
    }
    else {
        NSLog(@"here");
        
        PostPhotoBrowserViewController *photoBrowserViewController = [[PostPhotoBrowserViewController alloc] initWithImages:_images isUrl:NO andIndex:tag];
        
        [self.navigationController pushViewController:photoBrowserViewController animated:YES];
        
        //    [self.navigationController presentViewController:photoBrowserViewController animated:YES completion:nil];
    }
}

#pragma mark - LocalImageViewControllerDelegate delegate
//获取选择的图片
- (void)getSelectImage:(NSArray *)imageArr
{
    //    是个数组
    while ([_imageViews count] != 0) {
        [[_imageViews lastObject] removeFromSuperview];
        [_imageViews removeLastObject];
    }
    
    //    int oldImageCount = (int)[_images count];
    int newImageCount = (int)[imageArr count];
    for (int i = 0; i < newImageCount; i++) {
        [_images addObject:[imageArr objectAtIndex:i]];
    }
    
    _lastView = nil;
    _rightView = nil;
    
    NSInteger imageCount = [_images count];
    
    NSLog(@"imageCount = %ld", (long)imageCount);
    
    for (int i = 0; i <= imageCount; ++i)
    {
        UIImageView *subv = [[UIImageView alloc] init];
        subv.tag = i;
        
        if (i == imageCount && imageCount < 9) {
            subv.image = [UIImage imageNamed:@"postAddPic"];
        }
        else if (i == 9) {
            return;
        }
        else {
            subv.image = [_images objectAtIndex:i];
        }
        
        
        if (i == 3) {
            _rightView = subv;
        }
        
        //                subv.delegate = self;
        //        subv.layer.cornerRadius = 3;
        [self.view addSubview:subv];
        
        [subv mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i % 4 == 0) {
                make.left.equalTo(self.view).with.offset(5);
            }
            else {
                make.left.equalTo(_lastView.mas_right).with.offset(5);
            }
            
            int row = i / 4;
            make.top.equalTo(_textView.mas_bottom).with.offset(row * (([AppConstants uiScreenWidth] / 4 - 5) + 5) + 10);
            make.width.mas_equalTo([AppConstants uiScreenWidth] / 4 - 5);
            make.height.mas_equalTo([AppConstants uiScreenWidth] / 4 - 5);
        }];
        
        _lastView = subv;
        
        subv.userInteractionEnabled = YES;
        UITapGestureRecognizer *contentImageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentImageTaped:)];
        [subv addGestureRecognizer:contentImageTap];
        
        subv.contentMode = UIViewContentModeScaleAspectFill;
        subv.clipsToBounds = YES;
        
        [_imageViews addObject:subv];
    }
    
    _localImageViewController.delegate = nil;
}

#pragma mark - UIScrollView delegate
//回收键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_textView resignFirstResponder];
}

#pragma mark - UITextView delegate
//textView截取到140个字符
- (void)textViewDidChange:(UITextView *)textView {
    NSInteger number = [textView.text length];
    if (number > 140) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringCN(@"tishi", @"") message:NSLocalizedStringCN(@"xiaoyu140", @"") delegate:self cancelButtonTitle:NSLocalizedStringCN(@"wozhidaole", @"") otherButtonTitles:nil];
        [alert show];
        //        直接截取到140
        textView.text = [textView.text substringToIndex:140];
        number = 140;
    }
}

- (void)dealloc {
    [_images removeAllObjects];
    [_imageViews removeAllObjects];
    
    NSLog(@"dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
