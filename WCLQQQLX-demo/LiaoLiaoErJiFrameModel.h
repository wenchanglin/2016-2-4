//
//  LiaoLiaoErJiFrameModel.h
//  歌力思
//
//  Created by greenis on 16/8/29.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyModel.h"
@interface LiaoLiaoErJiFrameModel : NSObject
@property(nonatomic,strong)MyModel * model;
//标题
@property (nonatomic,assign,readonly) CGRect contentF;

//cell高度
@property (nonatomic, assign,readonly)CGFloat cellHeight;
@end
