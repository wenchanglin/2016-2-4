

#ifndef WCLInterface_h
#define WCLInterface_h
#define NSLocalizedStringCN(key, comment) \
(([[[NSLocale preferredLanguages] objectAtIndex:0] hasPrefix:@"zh-Hans"])?([[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]):([[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"]] localizedStringForKey:key value:@"" table:nil]))
/*
 #define NSLocalizedStrings(key, comment) \
 (([[[NSLocale preferredLanguages] objectAtIndex:0] hasPrefix:@"zh-Hans"])?([[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]):([[[NSLocale preferredLanguages] objectAtIndex:0] hasPrefix:@"en"])?([[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]):([[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"ko" ofType:@"lproj"]] localizedStringForKey:key value:@"" table:nil]))
 */
#import "AFNetWorking.h"
#import "UIImageView+WebCache.h"
#import "AppConstants.h"
#import "FileOperator.h"
#import "PlistEditor.h"
#import "ProgressHUD.h"
#import "UserInfoDataModel.h"
#import "YYKit.h"
#import "SSVideoPlayContainer.h"
#import "SSVideoPlayController.h"
#import<CoreData/CoreData.h>
#import "MJRefresh.h"
#import "XHWebImageAutoSize.h"
#define SuoLueTuSuxffix @"?x-oss-process=style/thumb300300"
#define QiYuAppId @"157d9f0d28954d3ebe13ddb71d0f0865"
//友盟APPkey
#define UManalyseAppKey @"57df516367e58ec2aa001a2c"
//友盟推送
#define UM_push_app_key @"57df516367e58ec2aa001a2c"
#define UM_push_app_secret @"w5n0cvkdrx6mujz1visyiifwkxzfnuw8"


////所有定义
#define IOS7            ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define UIScreenWidth                              [UIScreen mainScreen].bounds.size.width
#define UIScreenHeight                             [UIScreen mainScreen].bounds.size.height
#define UISreenWidthScale    320/UIScreenWidth 
//
//


#endif /* WCLInterface_h */
