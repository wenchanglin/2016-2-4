//
//  JiangLiaoCollectionReusableView.m
//  歌力思
//
//  Created by greenis on 16/9/5.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "JiangLiaoCollectionReusableView.h"

@implementation JiangLiaoCollectionReusableView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createHeader];
    }
    return self;
}
-(void)createHeader
{
    _headImage = [[UIImageView alloc]init];
    _headImage.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width/690*460);
    [self addSubview:_headImage];
    _titles = [[UILabel alloc]initWithFrame:CGRectMake(2, CGRectGetMaxY(_headImage.frame)+10, [UIScreen mainScreen].bounds.size.width-20, 30)];
    _titles.numberOfLines =0;
    [self addSubview:_titles];
    

}



@end
