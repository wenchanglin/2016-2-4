//
//  PersonThreeTableViewCell.m
//  WCLQQQLX-demo
//
//  Created by wen on 16/6/6.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "CommentsPersonTableViewCell.h"

@implementation CommentsPersonTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

-(void)setModel:(PingLunFrameModel *)model
{
    _model = model;
    _dateLabel.text = model.model.add_time;
    if([model.model.avatar hasPrefix:@"http"])
    {
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:model.model.avatar] placeholderImage:[UIImage imageNamed:@"headplace"]];
    }
    else
    {
        NSString * str0 = [NSString stringWithFormat:@"%@%@",[AppConstants httpChinaAndEnglishForHead],model.model.avatar];
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:str0] placeholderImage:[UIImage imageNamed:@"headplace"]];
    }
    _nameLabel.text = model.model.user_nick_name;

    self.commentsLabel.frame =model.contentF;
    
    _commentsLabel.numberOfLines = 0;
    _commentsLabel.font = [UIFont systemFontOfSize:14.0f];
    _commentsLabel.textColor = [UIColor colorWithHexString:@"#333333"];
   // self.commentsLabel.backgroundColor = [UIColor grayColor];
    self.commentsLabel.attributedText = [self emojiString:model.model.content];
    _line = [[UIView alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(self.commentsLabel.frame)+10, [UIScreen mainScreen].bounds.size.width -30, 1)];
    [self.contentView addSubview:_line];
    _line.backgroundColor = [UIColor colorWithHexString:@"#e6e6e6"];
}



- (NSMutableAttributedString*)emojiString:(NSString*)content {
    //1、创建一个可变的属性字符串
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:content];
    
    //2、通过正则表达式来匹配字符串
    
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]";//匹配表情
    
    NSError *error = nil;
    
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    
    if(!re) {
        return attributeString;
    }
    
    NSArray *resultArray = [re matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    
    //根据匹配范围来用图片进行相应的替换
    
    for(NSTextCheckingResult *match in resultArray) {
        
        //获取数组元素中得到range
        
        NSRange range = [match range];
        
        //获取原字符串中对应的值
        
        NSString *subStr = [content substringWithRange:range];
        
        NSArray *keyArray = [AppConstants expressionNameArray];
        NSDictionary *expressionDic = [AppConstants expressionDic];
        
        //        NSLog(@"------%@-----", expressionDic);
        
        for(int i =0; i < keyArray.count; i ++) {
            
            if([keyArray[i] isEqualToString:subStr]) {
                
                //face[i][@"png"]就是我们要加载的图片
                
                //新建文字附件来存放我们的图片,iOS7才新加的对象
                
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                
                //给附件添加图片
                
                textAttachment.image= [UIImage imageNamed:[expressionDic valueForKey:keyArray[i]]];
                
                //                NSLog(@"imagename = %@ key = %@ dic = %@", [expressionDic valueForKey:keyArray[i]], keyArray[i], expressionDic);
                
                //调整一下图片的位置,如果你的图片偏上或者偏下，调整一下bounds的y值即可
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                    textAttachment.bounds=CGRectMake(0, -5, textAttachment.image.size.width, textAttachment.image.size.height);
                }
                else {
                    textAttachment.bounds=CGRectMake(0, -5, textAttachment.image.size.width / 2, textAttachment.image.size.height / 2);
                }
                
                
                //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
                
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                
                //把图片和图片对应的位置存入字典中
                
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                
                [imageDic setObject:imageStr forKey:@"image"];
                
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                
                //把字典存入数组中
                
                [imageArray addObject:imageDic];
            }
        }
    }
    
    //4、从后往前替换，否则会引起位置问题
    
    for(int i = (int)imageArray.count-1; i >=0; i--) {
        
        NSRange range;
        
        [imageArray[i][@"range"] getValue:&range];
        
        //进行替换
        
        [attributeString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
        
    }
    
    return attributeString;
}


-(void)createUI
{
    //头像
    _headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(30, 20, 60, 60)];
    _headImageView.layer.cornerRadius =30;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _headImageView.layer.borderWidth = 0.7;
    [self.contentView addSubview:_headImageView];
    //姓名
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImageView.frame)+15, 25, [UIScreen mainScreen].bounds.size.width-50, 20)];
    [self.contentView addSubview:_nameLabel];
    _nameLabel.font = [UIFont systemFontOfSize:14.0f];
    _nameLabel.textColor = [UIColor blackColor];
    //日期
    _dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImageView.frame)+15, CGRectGetMaxY(_nameLabel.frame)+1, [UIScreen mainScreen].bounds.size.width-50, 20)];
    //_dateLabel.backgroundColor = [UIColor cyanColor];
    [self.contentView addSubview:_dateLabel];
    _dateLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    _dateLabel.font = [UIFont systemFontOfSize:12.0f];
     _commentsLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.headImageView.frame)+15, CGRectGetMaxY(self.dateLabel.frame)+1, [UIScreen mainScreen].bounds.size.width - 135, 50)];
     [self.contentView addSubview:_commentsLabel];
    
}
@end
