//
//  SuperSearchViewController.h
//  歌力思
//
//  Created by wen on 16/7/21.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSLContainerViewController.h"
@interface SuperSearchViewController : UIViewController<YSLContainerViewControllerDelegate>

@property (nonatomic,strong) NSMutableArray *ImgUrl;
@property (nonatomic,strong) NSMutableArray *articleid;
@property (nonatomic,strong) NSMutableArray *zhaiyao;
@property (nonatomic,strong) NSMutableArray *naTitle;

@end
