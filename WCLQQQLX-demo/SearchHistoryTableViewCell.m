//
//  SearchHistoryTableViewCell.m
//  歌力思
//
//  Created by likaifeng on 16/9/2.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "SearchHistoryTableViewCell.h"

@implementation SearchHistoryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void) createUI {
    _hiss = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 160, 30)];
    _hiss.font = [UIFont systemFontOfSize:12.0f];
    [self.contentView addSubview:_hiss];
    _arrow = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-27, CGRectGetMaxY(_hiss.frame) - 27, 20, 12)];
    [self.contentView addSubview:_arrow];
    _arrow.image = [UIImage imageNamed:@"jiantou.png"];
    _line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_hiss.frame) + 5, [UIScreen mainScreen].bounds.size.width, 1)];
    _line.backgroundColor = [UIColor colorWithHexString:@"#2d2d2d"];
    [self.contentView addSubview:_line];
}


@end
