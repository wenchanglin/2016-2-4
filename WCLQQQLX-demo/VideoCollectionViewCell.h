//
//  VideoCollectionViewCell.h
//  歌力思
//
//  Created by wen on 16/7/18.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZhengWenModel.h"
@interface VideoCollectionViewCell : UICollectionViewCell
@property(nonatomic,strong)ZhengWenModel * model;
@property(nonatomic,strong)UIImageView * videoImageView;
@property(nonatomic,strong)UIButton * playButton;
@property(nonatomic,strong)UILabel * videoName;

@end
