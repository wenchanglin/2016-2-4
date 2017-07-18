//
//  GuangGaoLanModel.h
//  WCLQQQLX-demo
//
//  Created by wen on 16/6/1.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentsPersonModel : NSObject
@property(nonatomic,strong)NSString * add_time;
@property(nonatomic,strong)NSString * avatar;
@property(nonatomic,strong)NSString * content;
@property(nonatomic,strong)NSString * reply_time;
@property(nonatomic,assign)NSInteger  is_reply;
@property(nonatomic,strong)NSString * reply_content;
@property(nonatomic,assign)NSInteger  user_id;
@property(nonatomic,assign)NSInteger  user_name;
@property(nonatomic,strong)NSString * user_nick_name;


-(instancetype)initWithDic:(NSDictionary *)dict;
@end
