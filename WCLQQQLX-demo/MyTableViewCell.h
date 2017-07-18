//
//  MyTableViewCell.h
//  歌力思
//
//  Created by greenis on 16/8/16.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiaoLiaoErJiFrameModel.h"
@interface MyTableViewCell : UITableViewCell
@property(nonatomic,strong)UILabel * nameLabel;
@property(nonatomic,strong)UIImageView * headImageView;
@property(nonatomic,strong)LiaoLiaoErJiFrameModel * LiaoLiaoFrameModel;
@property(nonatomic,strong)UILabel * dateLabel;
@property(nonatomic,strong)UILabel * commentsLabel;
@property(nonatomic,strong)UILabel * noCommentLabel;
@end
