//
//  DetailTableViewCell.m
//  歌力思
//
//  Created by likaifeng on 16/7/8.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "DetailTableViewCell.h"
#import "DetailFrameModel.h"
@interface  DetailTableViewCell()
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
@end

@implementation DetailTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.image];
        [self.contentView addSubview:self.step];
        [self.contentView addSubview:self.historyss];
    }
    return self;
}

- (UIImageView *)image {
    if (!_image) {
        self.image = [[UIImageView alloc] initWithFrame:CGRectMake(30, 62, kWidth, 230)];
    }
    return _image;
}
- (UILabel *)step {
    if (!_step) {
        self.step = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, kWidth - 20, 58)];
        self.step.numberOfLines = 0;
        //self.step.backgroundColor = [UIColor redColor];
        self.step.font = [UIFont systemFontOfSize:15];
    }
    return _step;
}

-(UILabel *)historyss
{
    if (!_historyss) {
        self.historyss = [[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-180)/2,10,180,45)];
        self.historyss.textAlignment = NSTextAlignmentCenter;
        self.historyss.font = [UIFont systemFontOfSize:12.0];
        self.historyss.textColor = [UIColor colorWithHexString:@"#f0c960"];
    }
    return _historyss;
}
-(void)setFrameModel:(DetailFrameModel *)frameModel {
    _frameModel = frameModel;
    self.step.text = [NSString stringWithFormat:@"%zd.%@",frameModel.model.sort_id,frameModel.model.remark];
    self.step.frame = frameModel.titleF;
    
    NSString * url = [NSString stringWithFormat:@"%@%@",[AppConstants httpVideoHeader],frameModel.model.original_path];
    [self.image sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    self.image.frame = frameModel.imageF;
}

@end
