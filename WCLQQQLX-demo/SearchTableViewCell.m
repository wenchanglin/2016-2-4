//
//  SearchTableViewCell.m
//  歌力思
//
//  Created by likaifeng on 16/8/31.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "SearchTableViewCell.h"

@implementation SearchTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createCell];
    }
    return self;
}
-(void)setModel:(ZhengWenModel *)model
{
    _model = model;
    NSString * url = [NSString stringWithFormat:@"%@%@",[AppConstants httpChinaAndEnglishForHead],model.ImgUrl];
    [_titleImageView sd_setImageWithURL:[NSURL URLWithString:url]];
    _name.text = model.FormulaName;
    //_sucName.text = model.Introduction;
    
}
-(void)createCell
{
    //图像
    _titleImageView  = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width /  533 * 400)];
    _titleImageView.layer.cornerRadius = 5;
    _titleImageView.layer.masksToBounds = YES;
    _titleImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _titleImageView.layer.borderWidth = 0.7;
    _titleImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:_titleImageView];
    //如果图像有点击事件,请在这里加一个按钮
    //名字
    _name = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleImageView.frame)-30,[UIScreen mainScreen].bounds.size.width, 30)];
    _name.font = [UIFont systemFontOfSize:16.0f];
    _name.textAlignment = NSTextAlignmentCenter;
    _name.textColor = [UIColor blackColor];
    // _name.backgroundColor = [UIColor colorWithWhite:0.7f alpha:0.6f];
    [self.contentView addSubview:_name];
    //    _sucName  = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(_name.frame)+5, [UIScreen mainScreen].bounds.size.width-10, 30)];
    //    _sucName.font = [UIFont systemFontOfSize:14.0f];
    //    _sucName.textColor = [UIColor whiteColor];
    //    _sucName.shadowColor = [UIColor colorWithWhite:0.1f alpha:0.8f];
    //    _sucName.numberOfLines = 1;
    //
    //    [self.contentView addSubview:_sucName];
    
}

@end
