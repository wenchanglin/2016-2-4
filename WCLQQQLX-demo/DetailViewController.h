//
//  DetailViewController.h
//  WCLQQQLX-demo
//
//  Created by wen on 16/7/1.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController
@property(nonatomic,strong)NSString * name;
@property(nonatomic,strong)NSString * mainimageView;
@property(nonatomic,strong)NSString * detailStr;
@property(nonatomic,strong)NSString * videoUrl;
@property(nonatomic,strong)NSString * caiLiaoStr;
@property(nonatomic,strong)NSString * formulaId;
@property(nonatomic,strong)NSString * shareUrl;
@property(nonatomic,strong)NSString * steps;
///点击的下标
@property(nonatomic)NSInteger index;
@end
