//
//  headerCollectionReusableView.m
//  歌力思
//
//  Created by wen on 16/7/18.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "HeaderCollectionReusableView.h"

@implementation HeaderCollectionReusableView
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self =[super initWithFrame:frame]) {
        [self createHeader];
    }
    return self;
}
-(void)createHeader
{
    _headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(2, 2, [UIScreen mainScreen].bounds.size.width-20, 30)];
    [self addSubview:_headerLabel];
    _headerLabel.font = [UIFont systemFontOfSize:13.0f];
    _headerLabel.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
   
}
@end
