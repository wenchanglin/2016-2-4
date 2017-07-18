//
//  WCLNavigationController.m
//  Greenis
//
//  Created by greenis on 16/10/8.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "WCLNavigationController.h"
#define MainBgColor [UIColor colorWithHexString:@"#080808"]

@implementation WCLNavigationController
- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        
//        [self.navigationItem setHidesBackButton:YES animated:NO];
//        self.navigationItem.titleView.hidden = YES;
        self.navigationBar.tintColor                    = MainBgColor;
        self.navigationBar.barTintColor                 = MainBgColor;
        self.navigationBar.titleTextAttributes          = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil];
        
    }
    
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
