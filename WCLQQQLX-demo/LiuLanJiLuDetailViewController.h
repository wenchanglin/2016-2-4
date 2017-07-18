//
//  SearchResultsViewController.h
//  歌力思
//
//  Created by wen on 16/7/19.
//  Copyright © 2016年 wen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiuLanJiLuDetailViewController : UIViewController
@property(nonatomic,strong)NSString * name;
@property(nonatomic,strong)NSString * mainimageView;
@property(nonatomic,strong)NSString * detailStr;
@property(nonatomic,strong)NSString * videoUrl;
@property(nonatomic,strong)NSString * caiLiaoStr;
@property(nonatomic,strong)NSString * formulaId;
@property(nonatomic,strong)NSString * shareUrl;
@property (nonatomic,strong) NSString * step;

///点击的下标
@property(nonatomic)NSInteger index;
@end
