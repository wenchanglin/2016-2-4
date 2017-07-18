//
//  MyLiaoLiaoTableViewCell.m
//  歌力思
//
//  Created by greenis on 16/8/10.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "MyLiaoLiaoTableViewCell.h"
#import "DetailViewController.h"
#import "PostPhotoBrowserViewController.h"
#import "LiaoLiaoErJiViewController.h"
@implementation MyLiaoLiaoTableViewCell
{
    CGRect _tmpRect;
    NSMutableArray * _mArray;
    NSMutableArray * _nArray;
    NSMutableArray * _shoucDatas;
    NSMutableArray * _userId;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self= [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
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
-(void)setModel:(LiaoLiaoGuangGaoDetailModel *)model
{
    _model = model;
    if ([model.avatar hasPrefix:@"http"]) {
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"headplace"]];
    }
    else
    {
        NSString * str0 = [NSString stringWithFormat:@"%@%@",[AppConstants httpChinaAndEnglishForHead],model.avatar];
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:str0] placeholderImage:[UIImage imageNamed:@"headplace"]];
    }

    
    
    _xname.text = model.nickName;
    _DateLabel.text = model.addtime;
    
    UIFont *fnt = [UIFont systemFontOfSize:15];
    _commentLabel.font = fnt;
    _commentLabel.numberOfLines = 0;
    // _commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    // iOS7中用以下方法替代过时的iOS6中的sizeWithFont:constrainedToSize:lineBreakMode:方法
    _tmpRect = [model.content boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt,NSFontAttributeName, nil] context:nil];
    CGFloat contentH = _tmpRect.size.height;
    if (![model.content isEqualToString:@""]) {
        
        _commentLabel.frame =CGRectMake(30, CGRectGetMaxY(_DateLabel.frame)+10, [UIScreen mainScreen].bounds.size.width-50, contentH+20);
        _commentLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    }
    else
    {
        contentH =30;
        _commentLabel.frame =CGRectMake(30, CGRectGetMaxY(_DateLabel.frame)+10, [UIScreen mainScreen].bounds.size.width-50, contentH);
        
    }
    
    
    _commentLabel.attributedText =  [self emojiString:model.content];
    _mArray = [NSMutableArray array];
    _nArray = [NSMutableArray array];
    
    if (![model.image1URL isEqualToString:@""]) {
        [_mArray addObject:model.image1URL];
    }
    if (![model.image2URL isEqualToString:@""]) {
        [_mArray addObject:model.image2URL];
    }
    if (![model.image3URL isEqualToString:@""]) {
        [_mArray addObject:model.image3URL];
    }
    if (![model.image4URL isEqualToString:@""]) {
        [_mArray addObject:model.image4URL];
    }if (![model.image5URL isEqualToString:@""]) {
        [_mArray addObject:model.image5URL];
    }if (![model.image6URL isEqualToString:@""]) {
        [_mArray addObject:model.image6URL];
    }
    if (![model.image7URL isEqualToString:@""]) {
        [_mArray addObject:model.image7URL];
    }
    if (![model.image8URL isEqualToString:@""]) {
        [_mArray addObject:model.image8URL];
    }
    if (![model.image9URL isEqualToString:@""]) {
        [_mArray addObject:model.image9URL];
    }
    
#pragma mark - 判断图片个数
    if (_mArray.count==1) {
        UIImageView * button1=[[UIImageView alloc]init];
        button1.frame = CGRectMake(30, CGRectGetMaxY(_commentLabel.frame)+5, 5+(([UIScreen mainScreen].bounds.size.width-60)/3*2), 5+(([UIScreen mainScreen].bounds.size.width-60)/3*2));
        [self.contentView addSubview:button1];
        button1.tag = 10;
        button1.contentMode = UIViewContentModeScaleAspectFit;
        NSLog(@"1张图片:%@",_mArray);
        if ([_mArray[0] hasPrefix:@"http"]){
            NSString * str1 = [NSString stringWithFormat:@"%@%@",_mArray[0],SuoLueTuSuxffix];
            //  NSLog(@"图片1个1:%@",str1);
            [button1 sd_setImageWithURL:[NSURL URLWithString:str1] placeholderImage:[UIImage imageNamed:@"headplace"]];
        }
        else
        {
            NSString * str1 = [NSString stringWithFormat:@"%@%@%@",[AppConstants httpChinaAndEnglishForHead],_mArray[0],SuoLueTuSuxffix];
            //   NSLog(@"图片1个2:%@",str1);
            [button1 sd_setImageWithURL:[NSURL URLWithString:str1] placeholderImage:[UIImage imageNamed:@"headplace"]];
        }
        button1.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapgust = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapgesture:)];
        [button1 addGestureRecognizer:tapgust];
        _shouChangBtn.frame = CGRectMake(30, CGRectGetMaxY(button1.frame)+10, 80, 30);
        NSString * shouc = [NSString stringWithFormat:@"%@",model.thumbsup_degree];
        [_shouChangBtn setTitle:shouc forState:UIControlStateNormal];
        [_shouChangBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        UIImageView * shoucImg = [[UIImageView alloc]init];
        shoucImg.image = [UIImage imageNamed:@"zan"];
        [_shouChangBtn setImage:[self scaleToSize:shoucImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_shouChangBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        _commentBtn.frame = CGRectMake(CGRectGetMaxX(_shouChangBtn.frame)+20,CGRectGetMaxY(button1.frame)+10,80,30);
        NSString * str =[NSString stringWithFormat:@"%zd",model.comment_degree];
        [_commentBtn setTitle:str forState:UIControlStateNormal];
        [_commentBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        
        UIImageView * liaoImg = [[UIImageView alloc]init];
        liaoImg.image = [UIImage imageNamed:@"liuyan"];
        [_commentBtn setImage:[self scaleToSize:liaoImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    
    }
    else if (_mArray.count==2)
    {
        UIImageView *button2;
        // NSLog(@"2张图片:%@",_mArray);
        for (int i=0; i<_mArray.count; i++)
        {
            button2  =[[UIImageView alloc]init];
            button2.userInteractionEnabled = YES;
            button2.frame = CGRectMake(30+i*(([UIScreen mainScreen].bounds.size.width-60)/2+5), CGRectGetMaxY(_commentLabel.frame)+5, ([UIScreen mainScreen].bounds.size.width-60)/2, ([UIScreen mainScreen].bounds.size.width-60)/2);
            [self.contentView addSubview:button2];
            button2.contentMode = UIViewContentModeScaleAspectFit;
            if ([_mArray[i] hasPrefix:@"http"]) {
                NSString * str2 = [NSString stringWithFormat:@"%@%@",_mArray[i],SuoLueTuSuxffix];
                //   NSLog(@"图片2个1:%@",str2);
                [button2 sd_setImageWithURL:[NSURL URLWithString:str2] placeholderImage:[UIImage imageNamed:@"headplace"]];
            }
            else
            {
                NSString * str2 = [NSString stringWithFormat:@"%@%@%@",[AppConstants httpChinaAndEnglishForHead],_mArray[i],SuoLueTuSuxffix];
                //    NSLog(@"图片2个2:%@",str2);
                [button2 sd_setImageWithURL:[NSURL URLWithString:str2] placeholderImage:[UIImage imageNamed:@"headplace"]];
            }
            button2.tag = i+2;
            button2.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapgust = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapgesture:)];
            [button2 addGestureRecognizer:tapgust];
            
        }
        _shouChangBtn.frame = CGRectMake(30, CGRectGetMaxY(button2.frame)+10, 80, 30);
        NSString * shouc = [NSString stringWithFormat:@"%@",model.thumbsup_degree];
        [_shouChangBtn setTitle:shouc forState:UIControlStateNormal];
        [_shouChangBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        UIImageView * shoucImg = [[UIImageView alloc]init];
        shoucImg.image = [UIImage imageNamed:@"zan"];
        [_shouChangBtn setImage:[self scaleToSize:shoucImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_shouChangBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        _commentBtn.frame = CGRectMake(CGRectGetMaxX(_shouChangBtn.frame)+20,CGRectGetMaxY(button2.frame)+10,80,30);
        NSString * str =[NSString stringWithFormat:@"%zd",model.comment_degree];
        [_commentBtn setTitle:str forState:UIControlStateNormal];
        [_commentBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        UIImageView * liaoImg = [[UIImageView alloc]init];
        liaoImg.image = [UIImage imageNamed:@"liuyan"];
        [_commentBtn setImage:[self scaleToSize:liaoImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
       
    }
    else if (_mArray.count==3)
    {
        UIImageView *button3;
        for (int i=0; i<_mArray.count; i++) {
            button3  =[[UIImageView alloc]init];
            button3.frame = CGRectMake(30+(i%3)*(([UIScreen mainScreen].bounds.size.width-60)/3+5), CGRectGetMaxY(_commentLabel.frame)+5, ([UIScreen mainScreen].bounds.size.width-60)/3, ([UIScreen mainScreen].bounds.size.width-60)/3);
            [self.contentView addSubview:button3];
            button3.contentMode = UIViewContentModeScaleAspectFit;
            if ([_mArray[i] hasPrefix:@"http"]) {
                NSString * str3 = [NSString stringWithFormat:@"%@%@",_mArray[i],SuoLueTuSuxffix];
                //     NSLog(@"图片3个1:%@",str3);
                [button3 sd_setImageWithURL:[NSURL URLWithString:str3] placeholderImage:[UIImage imageNamed:@"headplace"]];
            }
            else
            {
                NSString * str3 = [NSString stringWithFormat:@"%@%@%@",[AppConstants httpChinaAndEnglishForHead],_mArray[i],SuoLueTuSuxffix];
                //    NSLog(@"图片3个2:%@",str3);
                [button3 sd_setImageWithURL:[NSURL URLWithString:str3] placeholderImage:[UIImage imageNamed:@"headplace"]];
            }
            button3.tag = i+3;
            button3.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapgust = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapgesture:)];
            [button3 addGestureRecognizer:tapgust];
        }
        _shouChangBtn.frame = CGRectMake(30, CGRectGetMaxY(button3.frame)+10, 80, 30);
        NSString * shouc = [NSString stringWithFormat:@"%@",model.thumbsup_degree];
        [_shouChangBtn setTitle:shouc forState:UIControlStateNormal];
        [_shouChangBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        UIImageView * shoucImg = [[UIImageView alloc]init];
        shoucImg.image = [UIImage imageNamed:@"zan"];
        [_shouChangBtn setImage:[self scaleToSize:shoucImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_shouChangBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        _commentBtn.frame = CGRectMake(CGRectGetMaxX(_shouChangBtn.frame)+20,CGRectGetMaxY(button3.frame)+10,80,30);
        NSString * str =[NSString stringWithFormat:@"%zd",model.comment_degree];
        [_commentBtn setTitle:str forState:UIControlStateNormal];
        [_commentBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        
        UIImageView * liaoImg = [[UIImageView alloc]init];
        liaoImg.image = [UIImage imageNamed:@"liuyan"];
        [_commentBtn setImage:[self scaleToSize:liaoImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
       
    }
    else if (_mArray.count==4)
    {
        UIImageView * button4;
        for (int i=0; i<_mArray.count; i++) {
            button4  = [[UIImageView alloc]initWithFrame:CGRectMake(30+(i%3)*(([UIScreen mainScreen].bounds.size.width-60)/3+5), CGRectGetMaxY(_commentLabel.frame)+10+(([UIScreen mainScreen].bounds.size.width-60)/3+5)*(i/3), ([UIScreen mainScreen].bounds.size.width-60)/3, ([UIScreen mainScreen].bounds.size.width-60)/3)];
            [self.contentView addSubview:button4];
            button4.contentMode = UIViewContentModeScaleAspectFit;
            if ([_mArray[i] hasPrefix:@"http"]) {
                NSString * str4 = [NSString stringWithFormat:@"%@%@",_mArray[i],SuoLueTuSuxffix];
                //     NSLog(@"图片4个1:%@",str4);
                [button4 sd_setImageWithURL:[NSURL URLWithString:str4] placeholderImage:[UIImage imageNamed:@"headplace"]];
            }
            else
            {
                NSString * str4 = [NSString stringWithFormat:@"%@%@%@",[AppConstants httpChinaAndEnglishForHead],_mArray[i],SuoLueTuSuxffix];
                //     NSLog(@"图片4个2:%@",str4);
                [button4 sd_setImageWithURL:[NSURL URLWithString:str4] placeholderImage:[UIImage imageNamed:@"headplace"]];
            }
            button4.tag = i+4;
            button4.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapgust = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapgesture:)];
            [button4 addGestureRecognizer:tapgust];
            
        }
        _shouChangBtn.frame = CGRectMake(30, CGRectGetMaxY(button4.frame)+10, 80, 30);
        NSString * shouc = [NSString stringWithFormat:@"%@",model.thumbsup_degree];
        [_shouChangBtn setTitle:shouc forState:UIControlStateNormal];
        [_shouChangBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        UIImageView * shoucImg = [[UIImageView alloc]init];
        shoucImg.image = [UIImage imageNamed:@"zan"];
        [_shouChangBtn setImage:[self scaleToSize:shoucImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_shouChangBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        
        _commentBtn.frame = CGRectMake(CGRectGetMaxX(_shouChangBtn.frame)+20,CGRectGetMaxY(button4.frame)+10,80,30);
        NSString * str =[NSString stringWithFormat:@"%zd",model.comment_degree];
        [_commentBtn setTitle:str forState:UIControlStateNormal];
        [_commentBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        
        UIImageView * liaoImg = [[UIImageView alloc]init];
        liaoImg.image = [UIImage imageNamed:@"liuyan"];
        [_commentBtn setImage:[self scaleToSize:liaoImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        
        [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
       
    }
    else if (_mArray.count ==5)
    {
        UIImageView * button5 ;
        for (int i=0; i<_mArray.count; i++) {
            button5  = [[UIImageView alloc]initWithFrame:CGRectMake(30+(i%3)*(([UIScreen mainScreen].bounds.size.width-60)/3+5), CGRectGetMaxY(_commentLabel.frame)+10+(([UIScreen mainScreen].bounds.size.width-60)/3+5)*(i/3), ([UIScreen mainScreen].bounds.size.width-60)/3, ([UIScreen mainScreen].bounds.size.width-60)/3)];
            [self.contentView addSubview:button5];
            button5.contentMode = UIViewContentModeScaleAspectFit;
            if ([_mArray[i] hasPrefix:@"http"]) {
                NSString * str5 = [NSString stringWithFormat:@"%@%@",_mArray[i],SuoLueTuSuxffix];
                //     NSLog(@"图片5个1:%@",str5);
                [button5 sd_setImageWithURL:[NSURL URLWithString:str5] placeholderImage:[UIImage imageNamed:@"headplace"]];
            }
            else
            {
                NSString * str5 = [NSString stringWithFormat:@"%@%@%@",[AppConstants httpChinaAndEnglishForHead],_mArray[i],SuoLueTuSuxffix];
                //  NSLog(@"图片5个2:%@",str5);
                [button5 sd_setImageWithURL:[NSURL URLWithString:str5] placeholderImage:[UIImage imageNamed:@"headplace"]];
            }
            button5.tag = i+5;
            button5.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapgust = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapgesture:)];
            [button5 addGestureRecognizer:tapgust];
            
        }
        _shouChangBtn.frame = CGRectMake(30, CGRectGetMaxY(button5.frame)+10, 80, 30);
        
        NSString * shouc = [NSString stringWithFormat:@"%@",model.thumbsup_degree];
        [_shouChangBtn setTitle:shouc forState:UIControlStateNormal];
        [_shouChangBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        UIImageView * shoucImg = [[UIImageView alloc]init];
        shoucImg.image = [UIImage imageNamed:@"zan"];
        [_shouChangBtn setImage:[self scaleToSize:shoucImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_shouChangBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        _commentBtn.frame = CGRectMake(CGRectGetMaxX(_shouChangBtn.frame)+20,CGRectGetMaxY(button5.frame)+10,80,30);
        NSString * str =[NSString stringWithFormat:@"%zd",model.comment_degree];
        [_commentBtn setTitle:str forState:UIControlStateNormal];
        [_commentBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        
        UIImageView * liaoImg = [[UIImageView alloc]init];
        liaoImg.image = [UIImage imageNamed:@"liuyan"];
        [_commentBtn setImage:[self scaleToSize:liaoImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        
        [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
      
    }
    else if (_mArray.count==6)
    {
        UIImageView * button6;
        for (int i=0; i<_mArray.count; i++) {
            button6 = [[UIImageView alloc]initWithFrame:CGRectMake(30+(i%3)*(([UIScreen mainScreen].bounds.size.width-60)/3+5), CGRectGetMaxY(_commentLabel.frame)+10+(([UIScreen mainScreen].bounds.size.width-60)/3+5)*(i/3), ([UIScreen mainScreen].bounds.size.width-60)/3, ([UIScreen mainScreen].bounds.size.width-60)/3)];
            [self.contentView addSubview:button6];
            button6.contentMode = UIViewContentModeScaleAspectFit;
            if ([_mArray[i] hasPrefix:@"http"]) {
                NSString * str6 = [NSString stringWithFormat:@"%@%@",_mArray[i],SuoLueTuSuxffix];
                //  NSLog(@"图片6个1:%@",str6);
                [button6 sd_setImageWithURL:[NSURL URLWithString:str6] placeholderImage:[UIImage imageNamed:@"headplace"]];
            }
            else
            {
                NSString * str6 = [NSString stringWithFormat:@"%@%@%@",[AppConstants httpChinaAndEnglishForHead],_mArray[i],SuoLueTuSuxffix];
                //  NSLog(@"图片6个2:%@",str6);
                [button6 sd_setImageWithURL:[NSURL URLWithString:str6] placeholderImage:[UIImage imageNamed:@"headplace"]];
            }
            button6.tag = i+6;
            button6.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapgust = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapgesture:)];
            [button6 addGestureRecognizer:tapgust];
        }
        _shouChangBtn.frame = CGRectMake(30, CGRectGetMaxY(button6.frame)+10, 80, 30);
        NSString * shouc = [NSString stringWithFormat:@"%@",model.thumbsup_degree];
        [_shouChangBtn setTitle:shouc forState:UIControlStateNormal];
        [_shouChangBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        UIImageView * shoucImg = [[UIImageView alloc]init];
        shoucImg.image = [UIImage imageNamed:@"zan"];
        [_shouChangBtn setImage:[self scaleToSize:shoucImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_shouChangBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        _commentBtn.frame = CGRectMake(CGRectGetMaxX(_shouChangBtn.frame)+20,CGRectGetMaxY(button6.frame)+10,80,30);
        NSString * str =[NSString stringWithFormat:@"%zd",model.comment_degree];
        [_commentBtn setTitle:str forState:UIControlStateNormal];
        [_commentBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        UIImageView * liaoImg = [[UIImageView alloc]init];
        liaoImg.image = [UIImage imageNamed:@"liuyan"];
        [_commentBtn setImage:[self scaleToSize:liaoImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
      
    }
    else if (_mArray.count==7)
    {
        UIImageView * button7;
        for (int i=0; i<_mArray.count; i++) {
            button7  = [[UIImageView alloc]initWithFrame:CGRectMake(30+(i%3)*(([UIScreen mainScreen].bounds.size.width-60)/3+5), CGRectGetMaxY(_commentLabel.frame)+10+(([UIScreen mainScreen].bounds.size.width-60)/3+5)*(i/3), ([UIScreen mainScreen].bounds.size.width-60)/3, ([UIScreen mainScreen].bounds.size.width-60)/3)];
            [self.contentView addSubview:button7];
            button7.contentMode = UIViewContentModeScaleAspectFit;
            if ([_mArray[i] hasPrefix:@"http"]) {
                NSString * str7 = [NSString stringWithFormat:@"%@%@",_mArray[i],SuoLueTuSuxffix];
                //NSLog(@"图片7个1:%@",str7);
                [button7 sd_setImageWithURL:[NSURL URLWithString:str7] placeholderImage:[UIImage imageNamed:@"headplace"]];
            }
            else
            {
                NSString * str7 = [NSString stringWithFormat:@"%@%@%@",[AppConstants httpChinaAndEnglishForHead],_mArray[i],SuoLueTuSuxffix];
                // NSLog(@"图片7个2:%@",str7);
                [button7 sd_setImageWithURL:[NSURL URLWithString:str7] placeholderImage:[UIImage imageNamed:@"headplace"]];
            }
            button7.tag = i+7;
            button7.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapgust = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapgesture:)];
            [button7 addGestureRecognizer:tapgust];
            
        }
        _shouChangBtn.frame = CGRectMake(30, CGRectGetMaxY(button7.frame)+10, 80, 30);
        NSString * shouc = [NSString stringWithFormat:@"%@",model.thumbsup_degree];
        [_shouChangBtn setTitle:shouc forState:UIControlStateNormal];
        [_shouChangBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        UIImageView * shoucImg = [[UIImageView alloc]init];
        shoucImg.image = [UIImage imageNamed:@"zan"];
        [_shouChangBtn setImage:[self scaleToSize:shoucImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_shouChangBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        _commentBtn.frame = CGRectMake(CGRectGetMaxX(_shouChangBtn.frame)+20,CGRectGetMaxY(button7.frame)+10,80,30);
        NSString * str =[NSString stringWithFormat:@"%zd",model.comment_degree];
        [_commentBtn setTitle:str forState:UIControlStateNormal];
        [_commentBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        
        UIImageView * liaoImg = [[UIImageView alloc]init];
        liaoImg.image = [UIImage imageNamed:@"liuyan"];
        [_commentBtn setImage:[self scaleToSize:liaoImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
       
    }
    else if (_mArray.count==8)
    {
        UIImageView * button8;
        for (int i=0; i<_mArray.count; i++) {
            button8 = [[UIImageView alloc]initWithFrame:CGRectMake(30+(i%3)*(([UIScreen mainScreen].bounds.size.width-60)/3+5), CGRectGetMaxY(_commentLabel.frame)+10+(([UIScreen mainScreen].bounds.size.width-60)/3+5)*(i/3), ([UIScreen mainScreen].bounds.size.width-60)/3, ([UIScreen mainScreen].bounds.size.width-60)/3)];
            [self.contentView addSubview:button8];
            button8.contentMode = UIViewContentModeScaleAspectFit;
            if ([_mArray[i] hasPrefix:@"http"]) {
                NSString * str8 = [NSString stringWithFormat:@"%@%@",_mArray[i],SuoLueTuSuxffix];
                // NSLog(@"图片8个1:%@",str8);
                [button8 sd_setImageWithURL:[NSURL URLWithString:str8] placeholderImage:[UIImage imageNamed:@"headplace"]];
            }
            else
            {
                NSString * str8 = [NSString stringWithFormat:@"%@%@%@",[AppConstants httpChinaAndEnglishForHead],_mArray[i],SuoLueTuSuxffix];
                //  NSLog(@"图片8个2:%@",str8);
                [button8 sd_setImageWithURL:[NSURL URLWithString:str8] placeholderImage:[UIImage imageNamed:@"headplace"]];
            }
            button8.tag = i+8;
            button8.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapgust = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapgesture:)];
            [button8 addGestureRecognizer:tapgust];
            
        }
        _shouChangBtn.frame = CGRectMake(30, CGRectGetMaxY(button8.frame)+10, 80, 30);
        
        NSString * shouc = [NSString stringWithFormat:@"%@",model.thumbsup_degree];
        [_shouChangBtn setTitle:shouc forState:UIControlStateNormal];
        [_shouChangBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        UIImageView * shoucImg = [[UIImageView alloc]init];
        shoucImg.image = [UIImage imageNamed:@"zan"];
        [_shouChangBtn setImage:[self scaleToSize:shoucImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_shouChangBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        
        _commentBtn.frame = CGRectMake(CGRectGetMaxX(_shouChangBtn.frame)+20,CGRectGetMaxY(button8.frame)+10,80,30);
        NSString * str =[NSString stringWithFormat:@"%zd",model.comment_degree];
        [_commentBtn setTitle:str forState:UIControlStateNormal];
        [_commentBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        
        UIImageView * liaoImg = [[UIImageView alloc]init];
        liaoImg.image = [UIImage imageNamed:@"liuyan"];
        [_commentBtn setImage:[self scaleToSize:liaoImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        
        
        [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        
    }
    else if (_mArray.count==9)
    {
        UIImageView * button9 ;
        for (int i=0; i<_mArray.count; i++) {
            button9  = [[UIImageView alloc]initWithFrame:CGRectMake(30+(i%3)*(([UIScreen mainScreen].bounds.size.width-60)/3+5), CGRectGetMaxY(_commentLabel.frame)+10+(([UIScreen mainScreen].bounds.size.width-60)/3+5)*(i/3), ([UIScreen mainScreen].bounds.size.width-60)/3, ([UIScreen mainScreen].bounds.size.width-60)/3)];
            [self.contentView addSubview:button9];
            button9.contentMode = UIViewContentModeScaleAspectFit;
            if ([_mArray[i] hasPrefix:@"http"]) {
                NSString * str9 = [NSString stringWithFormat:@"%@%@",_mArray[i],SuoLueTuSuxffix];
                //  NSLog(@"图片9个1:%@",str9);
                [button9 sd_setImageWithURL:[NSURL URLWithString:str9] placeholderImage:[UIImage imageNamed:@"headplace"]];
            }
            else
            {
                NSString * str9 = [NSString stringWithFormat:@"%@%@%@",[AppConstants httpChinaAndEnglishForHead],_mArray[i],SuoLueTuSuxffix];
                //   NSLog(@"图片9个2:%@",str9);
                [button9 sd_setImageWithURL:[NSURL URLWithString:str9] placeholderImage:[UIImage imageNamed:@"headplace"]];
            }
            button9.tag = i+9;
            button9.userInteractionEnabled = YES;
            UITapGestureRecognizer * tapgust = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapgesture:)];
            [button9 addGestureRecognizer:tapgust];
        }
        _shouChangBtn.frame = CGRectMake(30, CGRectGetMaxY(button9.frame)+10, 80, 30);
        
        NSString * shouc = [NSString stringWithFormat:@"%@",model.thumbsup_degree];
        [_shouChangBtn setTitle:shouc forState:UIControlStateNormal];
        [_shouChangBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        UIImageView * shoucImg = [[UIImageView alloc]init];
        shoucImg.image = [UIImage imageNamed:@"zan"];
        [_shouChangBtn setImage:[self scaleToSize:shoucImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_shouChangBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        _commentBtn.frame = CGRectMake(CGRectGetMaxX(_shouChangBtn.frame)+20,CGRectGetMaxY(button9.frame)+10,80,30);
        NSString * str =[NSString stringWithFormat:@"%zd",model.comment_degree];
        [_commentBtn setTitle:str forState:UIControlStateNormal];
        [_commentBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        
        UIImageView * liaoImg = [[UIImageView alloc]init];
        liaoImg.image = [UIImage imageNamed:@"liuyan"];
        [_commentBtn setImage:[self scaleToSize:liaoImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    }
    else
    {
        NSLog(@"图片个数为0");
        _shouChangBtn.frame = CGRectMake(30, CGRectGetMaxY(_commentLabel.frame)+5, 80, 30);
        
        NSString * shouc = [NSString stringWithFormat:@"%@",model.thumbsup_degree];
        [_shouChangBtn setTitle:shouc forState:UIControlStateNormal];
        [_shouChangBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        UIImageView * shoucImg = [[UIImageView alloc]init];
        shoucImg.image = [UIImage imageNamed:@"zan"];
        [_shouChangBtn setImage:[self scaleToSize:shoucImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_shouChangBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        _commentBtn.frame = CGRectMake(CGRectGetMaxX(_shouChangBtn.frame)+20,CGRectGetMaxY(_commentLabel.frame)+5,80,30);
        NSString * str =[NSString stringWithFormat:@"%zd",model.comment_degree];
        [_commentBtn setTitle:str forState:UIControlStateNormal];
        [_commentBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        
        UIImageView * liaoImg = [[UIImageView alloc]init];
        liaoImg.image = [UIImage imageNamed:@"liuyan"];
        [_commentBtn setImage:[self scaleToSize:liaoImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
        [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    }
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
-(void)tapgesture:(UITapGestureRecognizer *)tap
{
    if (_mArray.count==1)
    {
        NSLog(@"marray个数为1:%@",_mArray);
        PostPhotoBrowserViewController *photoBrowserViewController = [[PostPhotoBrowserViewController alloc] initWithImages:_mArray isUrl:YES andIndex:0];
        photoBrowserViewController.hidesBottomBarWhenPushed = YES;
        
        [self.window.rootViewController presentViewController: photoBrowserViewController animated:YES completion:nil];
    }
    else
    {
        
        NSLog(@"marray:%@",_mArray);
        PostPhotoBrowserViewController *photoBrowserViewController = [[PostPhotoBrowserViewController alloc] initWithImages:_mArray isUrl:YES andIndex:tap.view.tag];
        
        photoBrowserViewController.hidesBottomBarWhenPushed = YES;
        
        [self.window.rootViewController presentViewController: photoBrowserViewController animated:YES completion:nil];
    }
    
    
}


-(void)createUI
{
    
    _headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(30, 18, 60, 60)];
    [self.contentView addSubview:_headImageView];
    _headImageView.layer.cornerRadius =30;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.borderColor = [UIColor grayColor].CGColor;
    _headImageView.layer.borderWidth = 0.7;
    _headImageView.backgroundColor = [UIColor grayColor];
    _xname = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImageView.frame)+15, 20, 160, 20)];
    [self.contentView addSubview:_xname];
    _xname.textColor = [UIColor colorWithHexString:@"#FFCC33"];
    _xname.font = [UIFont systemFontOfSize:16];
    //日期
    _DateLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImageView.frame)+15, CGRectGetMaxY(_xname.frame)+1, 160, 30)];
    [self.contentView addSubview:_DateLabel];
    _DateLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    _DateLabel.font = [UIFont systemFontOfSize:12];
    // 高度H
    
    _commentLabel = [[UILabel alloc]init];
    
    [self.contentView addSubview:_commentLabel];
    _commentBtn = [[UIButton alloc]init];
    [self.contentView addSubview:_commentBtn];
    _shouChangBtn = [[UIButton alloc]init];
    [self.contentView addSubview:_shouChangBtn];
    
   }
@end
