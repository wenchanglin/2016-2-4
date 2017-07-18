//
//  LiaoLiaoTX2TableViewCell.h
//  歌力思
//
//  Created by likaifeng on 16/8/22.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiaoLiaoGuangGaoDetailModel.h"

@interface LiaoLiaoTX2TableViewCell : UITableViewCell
@property(nonatomic,strong)LiaoLiaoGuangGaoDetailModel * model;
@property (nonatomic,strong)UIImageView *headImages;
@property (nonatomic,strong)UILabel *Btitle;
@end
