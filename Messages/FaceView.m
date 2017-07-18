//
//  ZBFaceView.m
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-13.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import "FaceView.h"
#import "Masonry.h"
#import "AppConstants.h"

#define NumPerLine 7
#define Lines    3
#define FaceSize  24
/*
** 两边边缘间隔
 */
#define EdgeDistance 20
/*
 ** 上下边缘间隔
 */
#define EdgeInterVal 5

@implementation FaceView

- (id)initWithIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        // 水平间隔
        CGFloat horizontalInterval = ([AppConstants uiScreenWidth]-NumPerLine*FaceSize -2*EdgeDistance)/(NumPerLine-1);
        
        // 上下垂直间隔
        CGFloat verticalInterval = (196 - 66 - 2*EdgeInterVal -Lines*FaceSize)/(Lines-1);
        
        for (int i = 0; i<Lines; i++)
        {
            for (int x = 0;x<NumPerLine;x++)
            {
                UIButton *expressionButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [self addSubview:expressionButton];
                
                [expressionButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self).with.offset(i*FaceSize +i*verticalInterval+EdgeInterVal);
                    make.left.equalTo(self).with.offset(x*FaceSize+EdgeDistance+x*horizontalInterval);
                    make.height.and.width.mas_equalTo(24);
                }];
                
//                NSLog(@"top = %f, left = %f", i*FaceSize +i*verticalInterval+EdgeInterVal, x*FaceSize+EdgeDistance+x*horizontalInterval);
                /*
                [expressionButton setFrame:CGRectMake(x*FaceSize+EdgeDistance+x*horizontalInterval,
                                                      i*FaceSize +i*verticalInterval+EdgeInterVal,
                                                      FaceSize,
                                                      FaceSize)];
                */
                if (i*7+x+1 ==21) {
                    [expressionButton setBackgroundImage:[UIImage imageNamed:@"DeleteEmoticonBtn_ios7@2x.png"]
                                                forState:UIControlStateNormal];
                    expressionButton.tag = 0;
        
                }else{
                    NSString *imageStr = [NSString stringWithFormat:@"Expression_%d@2x.png",(int)index*20+i*7+x+1];
//                    NSLog(@"imageStr = %@", imageStr);
                    [expressionButton setBackgroundImage:[UIImage imageNamed:imageStr]
                                                forState:UIControlStateNormal];
                    expressionButton.tag = 20*index+i*7+x+1;
              }
                [expressionButton addTarget:self
                                     action:@selector(faceClick:)
                           forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    return self;
}

- (void)faceClick:(UIButton *)button{

    NSString *faceName;
    BOOL isDelete;
    if (button.tag ==0){
        faceName = nil;
        isDelete = YES;
    }else{
        NSString *expressstring = [NSString stringWithFormat:@"Expression_%zd@2x.png",button.tag];
        NSString *plistStr = [[NSBundle mainBundle]pathForResource:@"expression" ofType:@"plist"];
        NSDictionary *plistDic = [[NSDictionary  alloc]initWithContentsOfFile:plistStr];
        
        for (int j = 0; j<[[plistDic allKeys]count]-1; j++)
        {
            if ([[plistDic objectForKey:[[plistDic allKeys]objectAtIndex:j]]
                 isEqualToString:[NSString stringWithFormat:@"%@",expressstring]])
            {
                faceName = [[plistDic allKeys]objectAtIndex:j];
            }
        }
        isDelete = NO;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelecteFace:andIsSelecteDelete:)]) {
        [self.delegate didSelecteFace:faceName andIsSelecteDelete:isDelete];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end