//
//  WCLTabBarController.m
//  WCLQQQLX-demo
//
//  Created by wen on 16/5/24.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "WCLTabBarController.h"
#import "HomeViewController.h"
#import "KitchenViewController.h"
#import "MyViewController.h"
#import "IMViewController.h"
#import "ChatViewController.h"
#import "CeShiTabBarController.h"
#import "AppDelegate.h"
#import "WCLNavigationController.h"
#define kFitWidth [UIScreen mainScreen].bounds.size.width/375
#define kFitHeight [UIScreen mainScreen].bounds.size.height/667
@interface WCLTabBarController ()
@property (nonatomic,assign) NSInteger sessionUnreadCount;

@property (nonatomic,assign) NSInteger systemUnreadCount;

@property (nonatomic,assign) NSInteger customSystemUnreadCount;


@end

@implementation WCLTabBarController

+(void)initialize
{
    //设置导航栏颜色
    [[UINavigationBar appearance]setBarTintColor:[UIColor  colorWithHexString:@"#080808"]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 49)];
    backView.backgroundColor = [UIColor blackColor];
    [[UITabBar appearance]setBarTintColor:[UIColor colorWithHexString:@"#080808"]];
    // 拿到整个导航控制器的外观
    UITabBarItem * item = [UITabBarItem appearance];
    NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
    selectTextAttrs [NSForegroundColorAttributeName] = [UIColor colorWithHexString:@"#FFCC33"];
    [item setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self addChildViewControllerWithClassName:[HomeViewController description] imageName:@"tabbar1" tilte:NSLocalizedStringCN(@"mifang", @"")];
    [self addChildViewControllerWithClassName:[KitchenViewController description] imageName:@"tabbar2" tilte:NSLocalizedStringCN(@"chufang", @"")];
    [self addChildViewControllerWithClassName:[ChatViewController description] imageName:@"tabbar3" tilte:NSLocalizedStringCN(@"liaoliao", @"")];
    [self addChildViewControllerWithClassName:[MyViewController description] imageName:@"tabbar4" tilte:NSLocalizedStringCN(@"wode", @"")];
}
-(void)addChildViewControllerWithClassName:(NSString *)className imageName:(NSString *)imageName tilte:(NSString *)title
{
    UIViewController * vc = [[NSClassFromString(className) alloc]init];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:vc];
    nav.tabBarItem.title =title;
    nav.tabBarItem.image = [UIImage imageNamed:imageName]   ;
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:[imageName stringByAppendingString:@"_press"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
     [self addChildViewController:nav];
}
@end
