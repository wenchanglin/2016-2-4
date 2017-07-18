//
//  DetailTableViewCell.h
//  歌力思
//
//  Created by likaifeng on 16/7/8.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DetailFrameModel;

@interface DetailTableViewCell : UITableViewCell
@property (nonatomic,strong) UILabel *step;
@property (nonatomic,strong) UIImageView *image;
@property (nonatomic,strong) DetailFrameModel *frameModel;
@property(nonatomic,strong) UILabel * historyss;
@end
