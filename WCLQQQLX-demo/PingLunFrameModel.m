//
//  PingLunFrameModel.m
//  歌力思
//
//  Created by greenis on 16/8/29.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "PingLunFrameModel.h"

@implementation PingLunFrameModel
-(void)setModel:(CommentsPersonModel *)model
{
    _model = model;
    CGSize titleSize = [model.content boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} context:nil].size ;
    _contentF = CGRectMake(30, 85, [UIScreen mainScreen].bounds.size.width-60, titleSize.height + 25);
   
    _cellHeight = CGRectGetMaxY(_contentF) + 12;
}
@end
