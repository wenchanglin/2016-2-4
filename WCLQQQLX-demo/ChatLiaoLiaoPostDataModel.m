//
//  ChatLiaoLiaoPostDataModel.m
//  SmartKitchen
//
//  Created by LICAN LONG on 15/11/23.
//  Copyright © 2015年 LICAN LONG. All rights reserved.
//

#import "ChatLiaoLiaoPostDataModel.h"

@implementation ChatLiaoLiaoPostDataModel
//封装一个+方法，返回数据模型本身 方便VC来调用里面的各种属性
+(ChatLiaoLiaoPostDataModel *)modelWith:(NSDictionary *)dic
{
    return [[ChatLiaoLiaoPostDataModel alloc]initWithDic:dic];
}
-(instancetype)initWithDic:(NSDictionary *)dict
{
    if (self = [super init]) {
        //KVC将字典的键值对--对应赋值给我们需要的字符串
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
@end

@implementation ChatLiaoLiaoPostDatas

@end