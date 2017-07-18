//
//  LoginBtn.m
//  CarFamily
//
//  Created by LZY on 16/8/27.
//  Copyright © 2016年 LZY. All rights reserved.
//

#import "LoginBtn.h"
#define kImageWH 30
@implementation LoginBtn
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.titleLabel.textAlignment = NSTextAlignmentCenter;
//        self.titleLabel.font = [UIFont systemFontOfSize:13];
//        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return self;
}
- (void)setHighlighted:(BOOL)highlighted {
    
}
//- (CGRect)titleRectForContentRect:(CGRect)contentRect {
//    return CGRectMake(0, kImageWH, contentRect.size.width, contentRect.size.height - kImageWH);
//}
//- (CGRect)imageRectForContentRect:(CGRect)contentRect {
//    
//    return CGRectMake((contentRect.size.width - kImageWH) / 2, 0, kImageWH, kImageWH);
//}
@end
