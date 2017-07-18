
#import "AppDelegate.h"
#import "SubViewController.h"
#import "RootViewController.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "LeftViewController.h"
#import "RootViewController.h"
#import "WXApiManager.h"
#import "LoginViewController.h"
#import <AudioToolbox/AudioServices.h>
#import "JPUSHService.h"
#import <AdSupport/AdSupport.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#import "YSFSDK.h"
#import <AVFoundation/AVFoundation.h>

#import "UIView+TYLaunchAnimation.h"
#import "TYLaunchFadeScaleAnimation.h"
#import "UIImage+TYLaunchImage.h"
#import "TAdLaunchImageView.h"

//判断系统版本号
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
@interface AppDelegate ()<WeiboSDKDelegate,WXApiDelegate,JPUSHRegisterDelegate,UIAlertViewDelegate>
@property(nonatomic,strong) LoginViewController *loginviewController;
@property(nonatomic,strong) NSString *imageUrls;

@end

@implementation AppDelegate
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [TencentOAuth HandleOpenURL:url]||[WeiboSDK handleOpenURL:url delegate:self]||[WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [TencentOAuth HandleOpenURL:url] || [WeiboSDK handleOpenURL:url delegate:self]||[WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
    ;
}
/**
 这里处理新浪微博SSO授权进入新浪微博客户端后进入后台，再返回原来应用
 */

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    _userInfo = [[UserInfoDataModel alloc] init];
    _BTConnectStatus = NO;
    _currentBTPort = nil;
    _BTAvailable = NO;
    _BTDownloadingSteps = NO;
    _stepTotalTime = 0;
    _BTConnectedMachineName = @"";
    _BTConnectedMachineMac = @"";
    _BTCurrentRecipeImageName = @"";
    _BTCurrentRecipeName = @"";
    _BTStatus = BTStatusNotReady;
    _expressionNameArray = [[NSMutableArray alloc]initWithCapacity:1000];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    AVAudioSession *audionSession = [AVAudioSession sharedInstance];
    [audionSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audionSession setActive:YES error:nil];
    //SWIZZ_IT;
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(createRootVC) name:@"tabbar" object:nil];
    _window.backgroundColor = [UIColor whiteColor];
    [self initShareSheetModal];
    [self setFace];
    [self setAPNS:launchOptions];
    [self _setupAccount];
    [self _setupUMfenxi];
    
    
    NSUserDefaults * users = [NSUserDefaults standardUserDefaults];
    if ([users integerForKey:@"isLogin"]==0) {
        //第一次进入
        [self createRootViewCtrl2];
    }
    else
    {
        //第二次进入加载tabbar界面
        NSLog(@"不是第一次进入");
        [self createRootVC];
        
        
    }
    //创建广告页
    [self createads];
    [_window makeKeyAndVisible];
     [self _checkAppUpdate];
    [self initQiYu];
    _window.translatesAutoresizingMaskIntoConstraints = NO;
    [WXApi registerApp:[AppConstants WXAppID] withDescription:@"weixin"];
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:[AppConstants SINAAppKey]];
    _WXLogin = false;
    _QQLogin = false;
    _WeiboLogin = false;
    return YES;
}
- (NSString*)getPreferredLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    return preferredLang;
}
-(void)_checkAppUpdate
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString * URL = nil;
        if ([[self getPreferredLanguage] hasPrefix:@"zh-"]) {
            URL = @"https://itunes.apple.com/search?term=格丽思&country=cn&entity=software";
            URL = [URL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        }
        else //en-US 英文版
        {
        URL = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", [AppConstants AppID]];
        }
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:URL]];
        if (!data) {
            return ;
        }
        NSError *error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSLog(@"jsonDic%@",jsonDict);
        jsonDict = [jsonDict[@"results"] firstObject];
        
        if (!error && jsonDict) {
            NSString *newVersion =jsonDict[@"version"];
            NSString *nowVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
            
            NSString *dot = @".";
            NSString *whiteSpace = @"";
            int newV = [newVersion stringByReplacingOccurrencesOfString:dot withString:whiteSpace].intValue;
            int nowV = [nowVersion stringByReplacingOccurrencesOfString:dot withString:whiteSpace].intValue;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(newV > nowV)
                {
                    NSString * title = NSLocalizedStringCN(@"banbengengxing", @"");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:jsonDict[@"releaseNotes"] delegate:self cancelButtonTitle:NSLocalizedStringCN(@"quxiao", @"") otherButtonTitles:NSLocalizedStringCN(@"gengxin", @""),nil];
                    [alert show];
         
                }
                
            });
        }
    });
    
}
/**
 初始化七鱼客服
 */
-(void)initQiYu
{
    [[YSFSDK sharedSDK] registerAppId:QiYuAppId cerName:@"格丽思"];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        // 此处加入应用在app store的地址，方便用户去更新，一种实现方式如下：
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@?ls=1&mt=8", [AppConstants AppID]]];
        [[UIApplication sharedApplication] openURL:url];
    }

}

/**
 广告页
 */
-(void)createads
{
    TAdLaunchImageView *adLaunchImageView = [[TAdLaunchImageView alloc]initWithImage:[UIImage ty_getLaunchImage]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    NSString *urlString = [NSString stringWithFormat:@"%@resource/SplashScreen/first/index.ashx", [AppConstants httpHeader]];
    [manager POST:urlString parameters:nil  success:^(AFHTTPRequestOperation *operation,id responseObject) {
        //NSLog(@"success urlString = %@", urlString);
       // NSLog(@"Success: %@", responseObject);
        if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
            NSArray *pics = [responseObject objectForKey:@"pics"];
            NSString *imageUrl = [[pics objectAtIndex:0] objectForKey:@"url"];
            if (![imageUrl isEqualToString:@""]) {
                _imageUrls = [NSString stringWithFormat:@"http://%@%@",[AppConstants httpServerIP],imageUrl];
                NSLog(@"第一图%@",_imageUrls);
            }
            adLaunchImageView.URLString =_imageUrls;
        }
        else if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 0) {
            NSLog(@"获取列表失败 %@", urlString);
        }
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        NSLog(@"false urlString = %@", urlString);
        NSLog(@"Error: %@", error);
    }];
    // 显示imageView
    [adLaunchImageView showInWindowWithAnimation:[TYLaunchFadeScaleAnimation fadeAnimationWithDelay:4] completion:^(BOOL finished) {
        NSLog(@"finished");
    }];
    
    __typeof (self) __weak weakSelf = self;
    // 点击广告block
    [adLaunchImageView setClickedImageURLHandle:^(NSString *URLString) {
        [weakSelf pushAdViewCntroller];
        NSLog(@"clickedImageURLHandle");
    }];
}

-(void)pushAdViewCntroller
{
    NSLog(@"广告页点击事件");
    //    RootViewController * root = [[RootViewController alloc]init];
    //    WCLTabBarController *tabbBarVC = (WCLTabBarController *)self.window.rootViewController;
    //    UINavigationController *navVC = tabbBarVC.viewControllers.firstObject;
    //    [navVC pushViewController:root animated:YES];
}
- (void)setAPNS:(NSDictionary *) launchOptions {
  //  NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    //Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];  
#endif
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil]; 
    }
    else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)  categories:nil];
    }
    
    //Required
    // init Push(2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil  )
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    //advertisingId
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    
    
    
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        
        if(resCode == 0){
            
            NSLog(@"registrationID获取成功：%@",registrationID);
            
        }
        
        else{
            
            NSLog(@"registrationID获取失败，code：%d",resCode);
            
        }
        
    }];
    
    
    
    
    
}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
    [[YSFSDK sharedSDK] updateApnsToken:deviceToken];
    //      NSLog(@"设备的devivceToken  %@",[[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]  stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""]);
}
//实现注册apns失败接口
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
//添加处理apns通知回调方法

#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"收到信息:%@",userInfo);
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"收到信息并进入界面:%@",userInfo);
    }
    completionHandler();  // 系统要求执行这个方法
}
// Required, iOS 7 Support

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    [JPUSHService handleRemoteNotification:userInfo];
    
}
//已经进入后台
-(void)applicationDidEnterBackground:(UIApplication *)application
{
    
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    NSInteger count = [[[YSFSDK sharedSDK] conversationManager] allUnreadCount];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
}

//将要进入程序
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}
-(void)setFace
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"expression" ofType:@"plist"];
    _expressionDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    NSArray *keys = [_expressionDic allKeys];
    NSUInteger count = [keys count];
    for (int i = 0; i < count; i++)
    {
        NSString *key = [keys objectAtIndex: i];
        [_expressionNameArray addObject:key];
    }
    
}

-(void)_setupAccount
{
    if ([FileOperator fileExist:[AppConstants localFileUserInfo]]) {
        [AppConstants getUserInfoFromLocal];
    }
    
}
-(void)_setupUMfenxi
{
    // 开启
    [MobClick setAppVersion:XcodeAppVersion];
    UMConfigInstance.appKey = UManalyseAppKey;
    UMConfigInstance.channelId = nil;
    //UMConfigInstance.eSType = E_UM_GAME; //仅适用于游戏场景，应用统计不用设
    [MobClick startWithConfigure:UMConfigInstance];
    
    //[MobClick startWithAppkey:UManalyseAppKey reportPolicy:BATCH channelId:nil];
    [MobClick setBackgroundTaskEnabled:YES];
    
    [MobClick setEncryptEnabled:YES];
    [MobClick profileSignInWithPUID:[AppConstants userInfo].nickname];
    [MobClick profileSignInWithPUID:[AppConstants userInfo].nickname provider:@"WB"];
    [MobClick profileSignInWithPUID:[AppConstants userInfo].nickname provider:@"SINA"];
    [MobClick profileSignInWithPUID:[AppConstants userInfo].nickname provider:@"QQ"];
    
    
}
-(void)createRootVC
{
   
    //初始化主界面
    _mainTabBarController = [[WCLTabBarController alloc]init];
    //暂时不用，
    //_ddMenuCotrol = [[DDMenuController alloc]initWithRootViewController:_tabbar];
    //左侧滑
    //LeftViewController * leftvc = [[LeftViewController alloc]init];
    //UINavigationController * lvc = [[UINavigationController alloc]initWithRootViewController:leftvc];
    //_ddMenuCotrol.leftViewController = lvc;
    //    _window.rootViewController =self.ddMenuCotrol;
    _window.rootViewController=_mainTabBarController;
}

-(void)createRootViewCtrl2
{
    //进入登录引导页
    
    self.window.rootViewController = [[SubViewController alloc]init];
}

- (void)initShareSheetModal{
    NSLog(@"initShareSheetModal");
    
    ShareSheetModel *Model_1 = [[ShareSheetModel alloc]init];
    Model_1.icon = @"share_weibo";
    Model_1.icon_on = @"share_weibo";
    Model_1.title = NSLocalizedStringCN(@"xinlangweibo", @"");
    ShareSheetModel *Model_2 = [[ShareSheetModel alloc]init];
    Model_2.icon = @"share_weixin";
    Model_2.icon_on = @"share_weixin";
    Model_2.title = NSLocalizedStringCN(@"weixinhaoyou", @"");
    ShareSheetModel *Model_3 = [[ShareSheetModel alloc]init];
    Model_3.icon = @"share_pengyouquan";
    Model_3.icon_on = @"share_pengyouquan";
    Model_3.title = NSLocalizedStringCN(@"weixinpengyouquan", @"");
    ShareSheetModel *Model_4 = [[ShareSheetModel alloc]init];
    Model_4.icon = @"share_QQ";
    Model_4.icon_on = @"share_QQ";
    Model_4.title = NSLocalizedStringCN(@"QQhaoyou", @"");
    ShareSheetModel *Model_5 = [[ShareSheetModel alloc]init];
    Model_5.icon = @"share_Qzone";
    Model_5.icon_on = @"share_Qzone";
    Model_5.title = NSLocalizedStringCN(@"QQkongjian", @"");
    ShareSheetModel *Model_6 = [[ShareSheetModel alloc]init];
    Model_6.icon = @"";
    Model_6.icon_on = @"";
    Model_6.title = NSLocalizedStringCN(@"quxiao", @"");
    _shareSheetMenu = [[NSArray alloc]init];
    _shareSheetMenu = @[Model_1,Model_2,Model_3,Model_4,Model_5,Model_6];
    
}


-(void)onResp:(BaseReq *)resp
{
    /*
     ErrCode ERR_OK = 0(用户同意)
     ERR_AUTH_DENIED = -4（用户拒绝授权）
     ERR_USER_CANCEL = -2（用户取消）
     code    用户换取access_token的code，仅在ErrCode为0时有效
     state   第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
     lang    微信客户端当前语言
     country 微信用户当前国家信息
     */
    SendAuthResp *aresp = (SendAuthResp *)resp;
    _WXErrCode = aresp.errCode;
    if (aresp.errCode == 0) {
        _WXCode = aresp.code;
        [self getAccess_token];
    }
    else if (aresp.errCode == -2) {
        NSLog(@"cancel");
    }
    else if (aresp.errCode == -4) {
        NSLog(@"reject");
    }
}

-(void)getAccess_token
{
    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",[AppConstants WXAppID],[AppConstants WXAppSecret],_WXCode];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                _WXAccessToken = [dic objectForKey:@"access_token"];
                _WXOpenid = [dic objectForKey:@"openid"];
                _WXRefreshToken = [dic objectForKey:@"refresh_token"];
                _WXScope = [dic objectForKey:@"scope"];
                _WXUnionid = [dic objectForKey:@"unionid"];
                [self getUserInfo];
            }
        });
    });
}

-(void)getUserInfo
{
    // https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",_WXAccessToken,_WXOpenid];
    // NSLog(@"%@",url);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                NSLog(@"userinfo %@", dic);
                
                _WXCity = [dic objectForKey:@"city"];
                _WXCountry = [dic objectForKey:@"country"];
                _WXHeadimgurl = [dic objectForKey:@"headimgurl"];
                _WXLanguage = [dic objectForKey:@"language"];
                _WXNickname = [dic objectForKey:@"nickname"];
                _WXProvince = [dic objectForKey:@"province"];
                //                _WXSex = [dic objectForKey:@"sex"];
                
                if ([[dic objectForKey:@"sex"] intValue] == 1) {
                    _WXSex = @"男";
                }
                else if ([[dic objectForKey:@"sex"] intValue] == 2) {
                    _WXSex = @"女";
                }
                else {
                    _WXSex = @"";
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"WeixinAuthRequestDone" object:nil];
            }
        });
        
    });
    
}
//第三方程序向微信终端请求认证的消息结构
- (void)sendAuthRequest
{
    NSLog(@"第三方程序向微信终端请求认证的消息结构");
    
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
    req.state = @"weixin";
    [WXApi sendAuthReq:req viewController:_loginviewController delegate:self];
}

-(void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}
-(void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        /*        NSString *title = NSLocalizedStringCN(@"发送结果", nil);
         NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@", NSLocalizedStringCN(@"响应状态", nil), (int)response.statusCode, NSLocalizedStringCN(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedStringCN(@"原请求UserInfo数据", nil),response.requestUserInfo];
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
         message:message
         delegate:nil
         cancelButtonTitle:NSLocalizedStringCN(@"确定", nil)
         otherButtonTitles:nil];*/
        if (response.statusCode == 0) {
            WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
            NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
            if (accessToken)
            {
                [AppConstants setWeiboAccessToken:accessToken];
            }
            NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
            if (userID) {
                [AppConstants setWeiboId:userID];
                
                [PlistEditor alterPlist:@"AppInfo" addValue:userID forKey:@"WeiboId"];
                
                [AppConstants writeDic2File];
            }
            
            [ProgressHUD showSuccess:NSLocalizedStringCN(@"fenxiangchenggong", @"")];
        }
        else {
            [ProgressHUD showError:NSLocalizedStringCN(@"fenxiangshibai", @"")];
        }
        
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        /*
         NSString *title = NSLocalizedStringCN(@"认证结果", nil);
         NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.userId: %@\nresponse.accessToken: %@\n%@: %@\n%@: %@", NSLocalizedStringCN(@"响应状态", nil), (int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken],  NSLocalizedStringCN(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedStringCN(@"原请求UserInfo数据", nil), response.requestUserInfo];
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
         message:message
         delegate:nil
         cancelButtonTitle:NSLocalizedStringCN(@"确定", nil)
         otherButtonTitles:nil];
         
         [alert show];*/
        
        if (response.statusCode == 0) {
            [AppConstants setWeiboAccessToken:[(WBAuthorizeResponse *)response accessToken]];
            [AppConstants setWeiboId:[(WBAuthorizeResponse *)response userID]];
            [AppConstants setWeiboRefreshToken:[(WBAuthorizeResponse *)response refreshToken]];
            
            [PlistEditor alterPlist:@"AppInfo" addValue:[(WBAuthorizeResponse *)response userID] forKey:@"WeiboId"];
            
            [AppConstants writeDic2File];
            
            [ProgressHUD show:NSLocalizedStringCN(@"zhengzaidenglu", @"")];
            
            NSLog(@"获取用户信息");
            
            NSString*path = @"https://api.weibo.com/2/users/show.json";
            
            NSDictionary *params = @{@"access_token":[AppConstants WeiboAccessToken] ,@"uid":[AppConstants WeiboId], @"source":[AppConstants SINAAppKey]};
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
            
            [manager GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSLog(@"获取个人信息成功");
                
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                
                [AppConstants setWeiboUsername:[dic objectForKey:@"screen_name"]];
                [AppConstants setWeiboImageUrlHD:[dic objectForKey:@"avatar_hd"]];
                [AppConstants setWeiboImageUrlLarge:[dic objectForKey:@"avatar_large"]];
                [AppConstants setWeiboCity:[dic objectForKey:@"city"]];
                [AppConstants setWeiboDescription:[dic objectForKey:@"description"]];
                
                if ([[dic objectForKey:@"gender"] isEqualToString:@"m"]) {
                    [AppConstants setWeiboGender:@"男"];
                }
                else if ([[dic objectForKey:@"gender"] isEqualToString:@"f"]) {
                    [AppConstants setWeiboGender:@"女"];
                }
                else {
                    [AppConstants setWeiboGender:@""];
                }
                
                [AppConstants setWeiboLocation:[dic objectForKey:@"location"]];
                
                [PlistEditor alterPlist:@"AppInfo" addValue:[dic objectForKey:@"screen_name"] forKey:@"WeiboUsername"];
                [PlistEditor alterPlist:@"AppInfo" addValue:[dic objectForKey:@"avatar_hd"] forKey:@"WeiboImageUrlHD"];
                [PlistEditor alterPlist:@"AppInfo" addValue:[dic objectForKey:@"avatar_large"] forKey:@"WeiboImageUrlLarge"];
                [PlistEditor alterPlist:@"AppInfo" addValue:[dic objectForKey:@"city"] forKey:@"WeiboCity"];
                [PlistEditor alterPlist:@"AppInfo" addValue:[dic objectForKey:@"description"] forKey:@"WeiboDescription"];
                [PlistEditor alterPlist:@"AppInfo" addValue:[AppConstants WeiboGender] forKey:@"WeiboGender"];
                [PlistEditor alterPlist:@"AppInfo" addValue:[dic objectForKey:@"location"] forKey:@"WeiboLocation"];
                
                [AppConstants writeDic2File];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"weiboLoginRequest" object:nil];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [ProgressHUD showError:NSLocalizedStringCN(@"denglushibaiqingchongshi", @"")];
                NSLog(@"获取个人信息失败");
                
            }];
            
        }
        
    }
    else if ([response isKindOfClass:WBPaymentResponse.class])
    {
        NSString *title = NSLocalizedStringCN(@"支付结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.payStatusCode: %@\nresponse.payStatusMessage: %@\n%@: %@\n%@: %@", NSLocalizedStringCN(@"响应状态", nil), (int)response.statusCode,[(WBPaymentResponse *)response payStatusCode], [(WBPaymentResponse *)response payStatusMessage], NSLocalizedStringCN(@"响应UserInfo数据", nil),response.userInfo, NSLocalizedStringCN(@"原请求UserInfo数据", nil), response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedStringCN(@"确定", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    else if([response isKindOfClass:WBSDKAppRecommendResponse.class])
    {
        NSString *title = NSLocalizedStringCN(@"邀请结果", nil);
        NSString *message = [NSString stringWithFormat:@"accesstoken:\n%@\nresponse.StatusCode: %d\n响应UserInfo数据:%@\n原请求UserInfo数据:%@",[(WBSDKAppRecommendResponse *)response accessToken],(int)response.statusCode,response.userInfo,response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedStringCN(@"确定", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}









#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "lkf.fhrsthrghhfg" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"fhrsthrghhfg.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    //支持数据库升级，迁徙
    NSDictionary *options = @{NSInferMappingModelAutomaticallyOption:@YES,NSMigratePersistentStoresAutomaticallyOption:@YES};
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}





@end
