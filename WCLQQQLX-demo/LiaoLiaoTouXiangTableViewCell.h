//
//  LiaoLiaoTouXiangTableViewCell.h
//  歌力思
//
//  Created by likaifeng on 16/8/19.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiaoLiaoGuangGaoDetailModel.h"
@interface LiaoLiaoTouXiangTableViewCell : UITableViewCell
@property(nonatomic,strong)LiaoLiaoGuangGaoDetailModel * model;
@property(nonatomic,strong)UIImageView * headImageView;
@property(nonatomic,strong)UILabel * xname;
@property(nonatomic,strong)UILabel * DateLabel;
@property(nonatomic,strong)UILabel * commentLabel;
@property(nonatomic,strong)UIButton * commentBtn;
@property(nonatomic,strong)UIButton * shouChangBtn;
@property(nonatomic)BOOL isFav;
@property (nonatomic) BOOL                          isLikeable;
//@property (nonatomic,strong)UIImageView *headImages;
//@property (nonatomic,strong)UILabel *Btitle;
@end
