
//
//  DetailFrameModel.m
//  歌力思
//
//  Created by likaifeng on 16/7/12.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "DetailFrameModel.h"

@implementation DetailFrameModel
- (void)setModel:(DetailModel *)model {
    if (_model != model) {
        _model = model;
        CGSize titleSize = [model.remark boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} context:nil].size ;
        _titleF = CGRectMake(30, 5, [UIScreen mainScreen].bounds.size.width-60, titleSize.height + 18);
        _imageF = CGRectMake(30, CGRectGetMaxY(_titleF)+1, [UIScreen mainScreen].bounds.size.width-60, ([UIScreen mainScreen].bounds.size.width-60)/800*533);
        _cellHeight = CGRectGetMaxY(_imageF) + 15;
    }
}

@end
