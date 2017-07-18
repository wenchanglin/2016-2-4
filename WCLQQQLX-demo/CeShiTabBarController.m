//
//  CeShiTabBarController.m
//  Greenis
//
//  Created by greenis on 16/10/8.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "CeShiTabBarController.h"
#import "IMViewController.h"
#import "QunViewController.h"
#import "AppDelegate.h"
#import "WCLNavigationController.h"
@implementation CeShiTabBarController
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // extern NSString *NTESCustomNotificationCountChanged;
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCustomNotifyChanged:) name:NTESCustomNotificationCountChanged object:nil];
    NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
    selectTextAttrs [NSForegroundColorAttributeName] = [UIColor colorWithHexString:@"#FFCC33"];
    
    IMViewController * im = [[IMViewController alloc]init];
    WCLNavigationController * navigationIM =[[WCLNavigationController alloc]initWithRootViewController:im];
    navigationIM.tabBarItem.image = [[UIImage imageNamed:@"tabbar_3"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navigationIM.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_s3"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [navigationIM.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    navigationIM.tabBarItem.title = NSLocalizedStringCN(@"单聊", @"");
    
    QunViewController * home = [[QunViewController alloc]init];
    WCLNavigationController * navigation =[[WCLNavigationController alloc]initWithRootViewController:home];

    navigation.tabBarItem.image = [[UIImage imageNamed:@"tabbar_1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navigation.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_s1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [navigation.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    //navigation.tabBarController.tabBar.tintColor = [UIColor colorWithHexString:@"#FFCC33"];
    navigation.tabBarItem.title = NSLocalizedStringCN(@"群聊", @"");
    
    
//    KitchenViewController * kitch = [[KitchenViewController alloc]init];
//    WCLNavigationController * navigationVC =[[WCLNavigationController alloc]initWithRootViewController:kitch];
//    navigationVC.tabBarItem.image = [[UIImage imageNamed:@"tabbar_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    navigationVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_s2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    [navigationVC.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
//    // navigationVC.tabBarController.tabBar.tintColor = [UIColor colorWithHexString:@"#FFCC33"];
//    navigationVC.tabBarItem.title = NSLocalizedStringCN(@"chufang", @"");
   
    //    QunViewController  * qun = [[QunViewController alloc]init];
    //    UINavigationController * navigationQun =[[UINavigationController alloc]initWithRootViewController:qun];
    //    navigationQun.tabBarItem.image = [[UIImage imageNamed:@"tabbar_1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //    navigationQun.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_s1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //    [navigationQun.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    //    //navigationCT.tabBarController.tabBar.tintColor = [UIColor colorWithHexString:@"#FFCC33"];
    //    navigationQun.tabBarItem.title = NSLocalizedStringCN(@"群组", @"");
    
//    ChatViewController * chat = [[ChatViewController alloc]init];
//    WCLNavigationController * navigationCT =[[WCLNavigationController alloc]initWithRootViewController:chat];
//    navigationCT.tabBarItem.image = [[UIImage imageNamed:@"tabbar_3"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    navigationCT.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_s3"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    [navigationCT.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
//    //navigationCT.tabBarController.tabBar.tintColor = [UIColor colorWithHexString:@"#FFCC33"];
//    navigationCT.tabBarItem.title = NSLocalizedStringCN(@"liaoliao", @"");
//    
//    
//    MyViewController * my = [[MyViewController alloc]init];
//    WCLNavigationController * navigationMC =[[WCLNavigationController alloc]initWithRootViewController:my];
//    navigationMC.tabBarItem.image = [[UIImage imageNamed:@"tabbar_4"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    navigationMC.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_s4"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    navigationMC.tabBarItem.title = NSLocalizedStringCN(@"wode", @"");
//    [navigationMC.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    //  navigationMC.tabBarController.tabBar.tintColor = [UIColor colorWithHexString:@"#FFCC33"];
    //c.2第二种方式
    self.viewControllers=@[navigationIM,navigation];
}

@end
