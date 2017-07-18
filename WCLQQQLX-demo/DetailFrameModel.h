//
//  DetailFrameModel.h
//  歌力思
//
//  Created by likaifeng on 16/7/12.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DetailModel.h"
//@class DetailModel;

@interface DetailFrameModel : NSObject

@property (nonatomic, strong) DetailModel *model;

//标题
@property (nonatomic,assign,readonly) CGRect titleF;
//图片
@property (nonatomic, assign,readonly)CGRect imageF;
//cell高度
@property (nonatomic, assign,readonly)CGFloat cellHeight;

@end
