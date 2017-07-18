//
//  UrlModel.m
//  WCLQQQLX-demo
//
//  Created by 千锋 on 16/6/1.
//  Copyright © 2016年 千锋. All rights reserved.
//

#import "MyModel.h"

@implementation MyModel
//封装一个+方法，返回数据模型本身 方便VC来调用里面的各种属性

-(instancetype)initWithDic:(NSDictionary *)dict
{
    if (self = [super init]) {
        //KVC将字典的键值对--对应赋值给我们需要的字符串
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
@end
