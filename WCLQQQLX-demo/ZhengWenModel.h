//
//  ZhengWenModel.h
//  WCLQQQLX-demo
//
//  Created by SuLong on 16/7/1.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZhengWenModel : NSObject

@property(nonatomic,strong)NSString * Effect;
@property(nonatomic,strong)NSString * FormulaID;
@property(nonatomic,strong)NSString* FormulaName;
@property(nonatomic,strong)NSString * ImgUrl;
@property(nonatomic,strong)NSString * Ingredients;
@property(nonatomic,strong)NSString * Introduction;
@property(nonatomic,strong)NSString *Steps;
@property(nonatomic,strong)NSString * UserNickName;
@property(nonatomic,strong)NSString * VideoUrl;
@property(nonatomic,strong)NSNumber * albums_total;
@property(nonatomic,strong)NSNull * comment_total;
@property(nonatomic,strong)NSString *share_url;
@property(nonatomic,strong)NSNull *friends_total;
@property(nonatomic,strong)NSNumber *  step_total;
@property(nonatomic,strong)NSNumber *  tags_total;
@property(nonatomic,strong)NSString * add_time;
@property(nonatomic,strong)NSNull * tools_list;
+(ZhengWenModel *)modelWith:(NSDictionary *)dic;
@end
