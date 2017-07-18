//
//  UrlModel.h
//  WCLQQQLX-demo
//
//  Created by 千锋 on 16/6/1.
//  Copyright © 2016年 千锋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyModel : NSObject
@property(nonatomic,strong)NSString * addtime;
@property(nonatomic,strong)NSString * avatar;
@property(nonatomic,strong)NSString * content;
@property(nonatomic,strong)NSNumber * nickName;
@property(nonatomic,assign)NSInteger  userId;
@property(nonatomic,strong)NSNumber * userName;
-(instancetype)initWithDic:(NSDictionary *)dict;

@end
