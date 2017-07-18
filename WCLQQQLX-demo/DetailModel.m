//
//  DetailModel.m
//  WCLQQQLX-demo
//
//  Created by wen on 16/7/1.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "DetailModel.h"

@implementation DetailModel

- (instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

@end
