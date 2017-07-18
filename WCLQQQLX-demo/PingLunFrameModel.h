//
//  PingLunFrameModel.h
//  歌力思
//
//  Created by greenis on 16/8/29.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommentsPersonModel.h"
@interface PingLunFrameModel : NSObject
@property (nonatomic, strong) CommentsPersonModel *model;

//标题
@property (nonatomic,assign,readonly) CGRect contentF;

//cell高度
@property (nonatomic, assign,readonly)CGFloat cellHeight;
@end
