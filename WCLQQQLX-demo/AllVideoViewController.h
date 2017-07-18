//
//  AllVideoViewController.h
//  歌力思
//
//  Created by wen on 16/7/18.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZhengWenModel.h"
@interface AllVideoViewController : UIViewController
@property(nonatomic,strong) ZhengWenModel * zhengWenModel;
@property(nonatomic,strong)NSArray * pictureIdArray;

@end
