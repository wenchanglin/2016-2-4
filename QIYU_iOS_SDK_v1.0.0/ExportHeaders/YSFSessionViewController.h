//
//  YSFSessionViewController.h
//  YSFSDK
//
//  Created by amao on 8/25/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//
#import <UIKit/UIKit.h>

@class YSFSource;

/**
 *  客服会话ViewController
 */
@interface YSFSessionViewController : UIViewController

/**
 *  会话窗口标题
 */
@property (nonatomic,copy)      NSString    *sessionTitle;

/**
 *  会话窗口来源
 */
@property (nonatomic,strong)    YSFSource   *source;
@end
