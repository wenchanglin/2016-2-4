//
//  VideoCollectionViewCell.m
//  歌力思
//
//  Created by wen on 16/7/18.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "VideoCollectionViewCell.h"

@implementation VideoCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self== [super initWithFrame:frame]) {
        [self createUI];
        
    }
    return self;
}
-(void)setModel:(ZhengWenModel *)model
{
    _model = model;
    _videoName.text = model.FormulaName;
    NSString * videoImg = [NSString stringWithFormat:@"%@%@%@",[AppConstants httpChinaAndEnglishForHead],model.ImgUrl,SuoLueTuSuxffix];
   // NSLog(@"视频缩略图·:%@",videoImg);
    [_videoImageView sd_setImageWithURL:[NSURL URLWithString:videoImg] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    
}
-(void)createUI
{
    _videoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, ([UIScreen mainScreen].bounds.size.width / 2 - 20), ([UIScreen mainScreen].bounds.size.width / 2 - 20) / 800 * 533)];
    [self.contentView addSubview:_videoImageView];
    _videoImageView.userInteractionEnabled = YES;

    _videoName = [[UILabel alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(_videoImageView.frame), ([UIScreen mainScreen].bounds.size.width - 10) / 2, 40)];
    [self.contentView addSubview:_videoName];
//    _videoName.backgroundColor = [UIColor redColor];
    _videoName.font = [UIFont systemFontOfSize:12.0f];
//    _videoName.textAlignment = NSTextAlignmentCenter;
    _videoName.numberOfLines = 0;
    _videoName.textColor =[UIColor colorWithHexString:@"#b3b3b3"];
    
}
@end
