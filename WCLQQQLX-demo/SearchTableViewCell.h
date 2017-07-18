//
//  SearchTableViewCell.h
//  歌力思
//
//  Created by likaifeng on 16/8/31.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZhengWenModel.h"


@interface SearchTableViewCell : UITableViewCell<UIActionSheetDelegate>

@property(nonatomic,strong)ZhengWenModel * model;
@property(nonatomic,strong)UIImageView * titleImageView;
@property(nonatomic,strong)UILabel * name;

@end
