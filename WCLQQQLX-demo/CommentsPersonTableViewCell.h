//
//  PersonThreeTableViewCell.h
//  WCLQQQLX-demo
//
//  Created by wen on 16/6/6.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PingLunFrameModel.h"
@interface CommentsPersonTableViewCell : UITableViewCell
@property(nonatomic,strong)UILabel * nameLabel;
@property(nonatomic,strong)UIImageView * headImageView;
@property(nonatomic,strong)PingLunFrameModel * model;
@property(nonatomic,strong)UILabel * dateLabel;
@property(nonatomic,strong)UILabel * commentsLabel;
@property(nonatomic,strong)UIView * line;

@end
