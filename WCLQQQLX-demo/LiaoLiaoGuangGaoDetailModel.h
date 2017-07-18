//
//  LiaoLiaoGuangGaoDetailModel.h
//  歌力思
//
//  Created by greenis on 16/8/3.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiaoLiaoGuangGaoDetailModel : NSObject

@property(nonatomic,assign)NSInteger  id;
@property(nonatomic,assign)NSInteger  click_degree;

@property(nonatomic,strong)NSString * add_time;
@property(nonatomic,strong)NSString *avatar;
@property(nonatomic,strong)NSString *comment;
@property(nonatomic,assign)NSInteger comment_degree;
@property(nonatomic,assign)NSInteger hot_degree;
@property(nonatomic,strong)NSString * content;
@property(nonatomic,strong)NSString * image1URL ;
@property(nonatomic,strong)NSString * image2URL;
@property(nonatomic,strong)NSString * image3URL;
@property(nonatomic,strong)NSString * image4URL ;
@property(nonatomic,strong)NSString * image5URL;
@property(nonatomic,strong)NSString * image6URL;
@property(nonatomic,strong)NSString * image7URL ;
@property(nonatomic,strong)NSString * image8URL;
@property(nonatomic,strong)NSString * image9URL;
@property(nonatomic,strong)NSString * img_url;
@property(nonatomic,assign)NSInteger  isThumbsup;
@property(nonatomic,strong)NSString * nickName;
@property(nonatomic,strong)NSString * thumb_image1URL ;
@property(nonatomic,strong)NSString * thumb_image2URL;
@property(nonatomic,strong)NSString * thumb_image3URL ;
@property(nonatomic,strong)NSString * thumb_image4URL;
@property(nonatomic,strong)NSString * thumb_image5URL;
@property(nonatomic,strong)NSString * thumb_image6URL;
@property(nonatomic,strong)NSString * thumb_image7URL ;
@property(nonatomic,strong)NSString * thumb_image8URL;
@property(nonatomic,strong)NSString * thumb_image9URL;
@property(nonatomic,strong)NSString * thumbsup_degree;
@property(nonatomic,assign)NSInteger  userId;
@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSString * addtime;

+(LiaoLiaoGuangGaoDetailModel *)modelWith:(NSDictionary *)dic;
@end
