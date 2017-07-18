//
//  LiaoLiaoTX2TableViewCell.m
//  歌力思
//
//  Created by likaifeng on 16/8/22.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "LiaoLiaoTX2TableViewCell.h"

@implementation LiaoLiaoTX2TableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self= [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

- (void)setModel:(LiaoLiaoGuangGaoDetailModel *)model {
    _model = model;
    if([model.avatar hasPrefix:@"http"])
    {
        [_headImages sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"headplace"]];
    }
    else
    {
        NSString * str0 = [NSString stringWithFormat:@"%@%@",[AppConstants httpChinaAndEnglishForHead],model.avatar];
        [_headImages sd_setImageWithURL:[NSURL URLWithString:str0] placeholderImage:[UIImage imageNamed:@"headplace"]];
    }
    _Btitle.text = model.nickName;
}
-(void)createUI
{
    _headImages = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 60) / 2, 10, 60, 60)];
    _headImages.layer.cornerRadius =30;
    _headImages.layer.masksToBounds = YES;
    _headImages.layer.borderColor = [UIColor grayColor].CGColor;
    _headImages.layer.borderWidth = 0.7;
    _headImages.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:_headImages];
    _Btitle = [[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 200) /2, CGRectGetMaxY(_headImages.frame) + 5, 200, 30)];
    [self.contentView addSubview:_Btitle];
}



@end
