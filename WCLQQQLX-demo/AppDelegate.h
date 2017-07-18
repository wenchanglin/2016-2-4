
#import <UIKit/UIKit.h>
#import "WCLTabBarController.h"
//#import "DDMenuController.h"
#import <sqlite3.h>
#import "ShareSheetModel.h"
#import "WeiboSDK.h"
#import "WCLTabBarController.h"
#import "BLEPort.h"
#import "UserInfoDataModel.h"
static NSString *appKey = @"90ccab36be509bfce97f7a53";
static NSString *channel = @"App Store";
static BOOL isProduction = FALSE;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
typedef enum {
    BTStatusNotReady = 0,
    BTStatusReady,
    BTStatusRunning,
    BTStatusDone
} BTMachineStatus;
typedef enum
{
    FirstYemian=0,
    SecondYemian = 1,
    ThirdYemian = 2,
    FourYemian = 3,
} YeMianStatus;
@property (strong, nonatomic) UIWindow *window;
//@property(nonatomic,strong)DDMenuController * ddMenuCotrol;
@property (nonatomic) sqlite3 *db;
@property (strong, nonatomic) NSString *httpAccessToken;
@property (nonatomic, assign) int WXErrCode;
@property (strong, nonatomic) NSMutableDictionary *AppInfoDic;
@property (strong, nonatomic) NSString *AppInfoPlistName;
@property (strong, nonatomic) NSString *WXCode;
@property (strong, nonatomic) NSString *WXAccessToken;
@property (strong, nonatomic) NSString *WXOpenid;
@property (strong, nonatomic) NSString *WXRefreshToken;
@property (strong, nonatomic) NSString *WXScope;
@property (strong, nonatomic) NSString *WXUnionid;
@property (strong, nonatomic) NSString *WXCity;
@property (strong, nonatomic) NSString *WXCountry;
@property (strong, nonatomic) NSString *WXHeadimgurl;
@property (strong, nonatomic) NSString *WXLanguage;
@property (strong, nonatomic) NSString *WXNickname;
@property (strong, nonatomic) NSString *WXProvince;
@property (strong, nonatomic) NSString *WXSex;
//蓝牙连接等
@property (nonatomic) BOOL              BTConnectStatus;
@property (nonatomic) BOOL              BTAvailable;
@property (nonatomic,strong) NSString          *BTRequestType;
@property (nonatomic) unsigned long     stepTotalTime;
@property (nonatomic,strong) NSString          *BTConnectedMachineName;
@property (nonatomic,strong) NSString          *BTConnectedMachineMac;
@property (strong, nonatomic) NSString  *BTCurrentRecipeImageName;
@property (strong, nonatomic) NSString  *BTCurrentRecipeName;
@property (assign, nonatomic) BTMachineStatus  BTStatus;
@property(nonatomic,assign)YeMianStatus yemian;
@property (nonatomic) BOOL              BTDownloadingSteps;

@property (strong, nonatomic) BLEPort  *currentBTPort;
@property (strong, nonatomic) WCLTabBarController *mainTabBarController;

@property (strong, nonatomic) NSString *QQAccessToken;
@property (strong, nonatomic) NSString *QQOpenId;
@property (strong, nonatomic) NSString *QQNickname;
@property (strong, nonatomic) NSString *QQImageUrl1;
@property (strong, nonatomic) NSString *QQImageUrl2;
@property (strong, nonatomic) NSString *QQCity;
@property (strong, nonatomic) NSString *QQGender;
@property (strong, nonatomic) NSString *QQProvince;
@property(nonatomic)NSInteger total;
@property (strong, nonatomic) NSString *originUsername;
@property (strong, nonatomic) NSString *originAccessToken;
@property (strong, nonatomic) NSString *currentOName;
@property (strong, nonatomic) NSString *currentOImageUrl;
@property (strong, nonatomic) NSString *currentOGender;
@property (strong, nonatomic) NSString *currentOLocation;

@property (strong, nonatomic) NSString *WeiboAccessToken;
@property (strong, nonatomic) NSString *WeiboRefreshToken;
@property (strong, nonatomic) NSString *WeiboUsername;
@property (strong, nonatomic) NSString *WeiboImageUrlHD;
@property (strong, nonatomic) NSString *WeiboImageUrlLarge;
@property (strong, nonatomic) NSString *WeiboCity;
@property (strong, nonatomic) NSString *WeiboDescription;
@property (strong, nonatomic) NSString *WeiboGender;
@property (strong, nonatomic) NSString *WeiboId;
@property (strong, nonatomic) NSString *WeiboLocation;

@property (strong, nonatomic) NSDictionary      *expressionDic;
@property (strong, nonatomic) NSMutableArray    *expressionNameArray;

@property (strong, nonatomic) NSMutableArray                    *HistoryIntroduceDataDics;
@property (strong, nonatomic) NSMutableArray                    *HistoryIntroduceDatas;
@property (strong, nonatomic) NSMutableArray                    *FavIntroduceDataDics;
@property (strong, nonatomic) NSMutableArray                    *FavIntroduceDatas;
@property (strong, nonatomic) NSRecursiveLock            *updatingPlistLock;
@property (nonatomic) BOOL                      downloadButtonPress2Pop;

@property (strong, nonatomic) NSArray           *shareSheetMenu;

@property (nonatomic) NSInteger         memeryCount;

@property (nonatomic) BOOL              justPostANewPost;

@property (strong, nonatomic) UserInfoDataModel *userInfo;

@property (nonatomic) BOOL              isPlayingVideo;



//微信,qq,微博第三方登录
@property (nonatomic) BOOL              WXLogin;
@property (nonatomic) BOOL              QQLogin;
@property (nonatomic) BOOL              WeiboLogin;



@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end

