//
//  MyMessageTableViewCell.m
//  歌力思
//
//  Created by greenis on 16/8/10.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "MyMessageTableViewCell.h"

@implementation MyMessageTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self= [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}
-(void)createUI
{
    _xname = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 160, 20)];
    _xname.font = [UIFont systemFontOfSize:14.0f];
    _xname.textColor = [UIColor colorWithHexString:@"#999999"];
    [self.contentView addSubview:_xname];
    _rightImgView = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-40, CGRectGetMaxY(_xname.frame)-15, 20, 12)];
    [self.contentView addSubview:_rightImgView];
    _fenGeXian = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_xname.frame)+15, [UIScreen mainScreen].bounds.size.width, 1)];
    [self.contentView addSubview:_fenGeXian];
    _fenGeXian.backgroundColor =[UIColor colorWithHexString:@"#F0F0F0"];
    
}
@end
