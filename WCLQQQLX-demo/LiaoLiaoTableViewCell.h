//
//  LiaoLiaoTableViewCell.h
//  歌力思
//
//  Created by greenis on 16/8/17.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiaoLiaoGuangGaoDetailModel.h"
@interface LiaoLiaoTableViewCell : UITableViewCell
@property(nonatomic,strong)LiaoLiaoGuangGaoDetailModel * model;
@property(nonatomic,strong)UIButton * headImageView;
@property(nonatomic,strong)UILabel * xname;
@property(nonatomic,strong)UILabel * DateLabel;
@property(nonatomic,strong)UILabel * commentLabel;
@property(nonatomic,strong)UIButton * commentBtn;
@property(nonatomic,strong)UIButton * shouChangBtn;
@property(nonatomic,strong)UIView * fenGeXian;
@property(nonatomic)BOOL isFav;
@property (nonatomic) BOOL                          isLikeable;
@end
