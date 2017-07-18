//
//  DetailModel.h
//  WCLQQQLX-demo
//
//  Created by wen on 16/7/1.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetailModel : NSObject
@property(nonatomic,strong)NSString * original_path;
@property(nonatomic,strong)NSString * remark;
@property(nonatomic,assign)NSInteger  sort_id;
@property(nonatomic,strong)NSString * thumb_path;

-(instancetype)initWithDic:(NSDictionary *)dic;
@end
