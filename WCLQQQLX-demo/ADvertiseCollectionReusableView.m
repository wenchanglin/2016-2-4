//
//  ADvertiseCollectionReusableView.m
//  歌力思
//
//  Created by likaifeng on 16/9/6.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "ADvertiseCollectionReusableView.h"

@implementation ADvertiseCollectionReusableView



-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.headImage];
        [self addSubview:self.titles];
    }
    return self;
}

- (UIImageView *)headImage {
    if (!_headImage) {
        self.headImage = [[UIImageView alloc] init];
                         
        
    }
    return _headImage;
}
- (UILabel *)titles {
    if (!_titles) {
        self.titles = [[UILabel alloc] init];
        
    }
    return _titles;
}
@end
