//
//  FooterCollectionReusableView.m
//  歌力思
//
//  Created by wen on 16/7/18.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "FooterCollectionReusableView.h"

@implementation FooterCollectionReusableView
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self =[super initWithFrame:frame]) {
        [self createHeader];
    }
    return self;
}
-(void)createHeader
{
    _footerLabel = [[UILabel alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-80)/2, 2, 80, 30)];
    [self addSubview:_footerLabel];
    _footerLabel.font = [UIFont systemFontOfSize:13.0f];
    _footerLabel.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
    _footerLabel.text  = @"没有更多";
}
@end
