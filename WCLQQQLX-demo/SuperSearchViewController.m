//
//  SuperSearchViewController.m
//  歌力思
//
//  Created by wen on 16/7/21.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "SuperSearchViewController.h"
#import "JiangLiaoViewController.h"
#import "YiZuiDouViewController.h"
#import "YangLeDuoViewController.h"
#import "QiShuiViewController.h"
#import "FanDianViewController.h"
#import "ZhengWenModel.h"
#import "ZhengWenTableViewCell.h"
#import "DetailViewController.h"
#import "XiaWuTeaViewController.h"
@interface SuperSearchViewController ()

@end

@implementation SuperSearchViewController
{
    NSMutableArray *_datasource;//存放热门搜索的数组
    NSMutableArray *_articleidArrays; //6分按钮的id数组
    NSMutableArray *_zhaiyaoArrays;
    NSMutableArray * _middleScrollImg;//中间滚动条图片
    NSMutableArray * _middleScrollTitle;//中间滚动条汉字
    UIButton *_getDataFailButton;//失败的button
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [ProgressHUD dismiss];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedStringCN(@"shipufenlei", @"");
    _datasource = [NSMutableArray array];
    _middleScrollImg = [NSMutableArray array];
    _middleScrollTitle = [NSMutableArray array];
    _articleidArrays = [NSMutableArray array];
    _zhaiyaoArrays = [NSMutableArray array];
    [self requestData];
}
//获取5个热门分类
- (void)requestData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    NSString *urlString = [NSString stringWithFormat:@"%@resource/article/frontpage/list/index.ashx", [AppConstants httpHeader]];
    NSDictionary *parameters = @{@"page":@"1", @"pageSize":@"10"};
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"success scrollview = %@", urlString);
              NSLog(@"Success: %@", responseObject);
//              [_middleScrollImg removeAllObjects];
//              [_middleScrollTitle removeAllObjects];
//              [_articleidArrays removeAllObjects];
//              [_zhaiyaoArrays removeAllObjects];
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  NSArray *articles = [responseObject objectForKey:@"articles"];
                  for (NSDictionary * dic in articles) {
                      [_middleScrollImg addObject:dic[@"ImgUrl"]];
                      [_middleScrollTitle addObject:dic[@"title"]];
                      [_articleidArrays addObject: dic[@"articleid"]];
                      [_zhaiyaoArrays addObject: dic[@"zhaiyao"]];
                  }
                  NSLog(@"Imgurl:%@,title:%@ id:%@ zhaiyao:%@",_middleScrollImg,_middleScrollTitle,_articleidArrays,_zhaiyaoArrays);
                  
                  [self createViewControllers];
                  NSLog(@"_middleScrollTitle:%zd",_middleScrollTitle.count);
              }
              else if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 0) {
                  NSLog(@"获取列表失败 %@", urlString);
                  
                  [self getDataFail];
              }
              
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"false urlString = %@", urlString);
              NSLog(@"Error: %@", error);
              
              [self getDataFail];
          }];
}

- (void)getDataFail {
    [_getDataFailButton removeFromSuperview];
    [ProgressHUD showError:NSLocalizedStringCN(@"jiazaishibai", @"")];
    _getDataFailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_getDataFailButton setImage:[UIImage imageNamed:@"reload.png"] forState:UIControlStateNormal];
    [_getDataFailButton addTarget:self action:@selector(reloadAllData) forControlEvents:UIControlEventTouchUpInside];
    _getDataFailButton.frame = CGRectMake((self.view.frame.size.width-160)/2, (self.view.frame.size.height-160)/2, 160, 160);
    [self.view addSubview:_getDataFailButton];
}
-(void)reloadAllData
{
    [_getDataFailButton removeFromSuperview];
    NSLog(@"加载失败");
    [self requestData];
}

-(void)createViewControllers
{
    if (_articleidArrays.count==3) {
        JiangLiaoViewController * xigua = [[JiangLiaoViewController alloc]init];
        xigua.articleid = _articleidArrays[0];
        xigua.title = _middleScrollTitle[0];
        xigua.ImgUrl =_middleScrollImg[0] ;
        xigua.zhaiyao =_zhaiyaoArrays[0] ;
        YiZuiDouViewController * bangbing = [[YiZuiDouViewController alloc]init];
        bangbing.articleid = _articleidArrays[1];
        bangbing.title = _middleScrollTitle[1];
        bangbing.ImgUrl =_middleScrollImg[1] ;
        bangbing.zhaiyao =_zhaiyaoArrays[1] ;
        YangLeDuoViewController * mangguo = [[YangLeDuoViewController alloc]init];
        mangguo.articleid = _articleidArrays[2];
        mangguo.title = _middleScrollTitle[2];
        mangguo.ImgUrl =_middleScrollImg[2] ;
        mangguo.zhaiyao =_zhaiyaoArrays[2] ;
        float statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        float navigationHeight = self.navigationController.navigationBar.frame.size.height;
        YSLContainerViewController * containerVC = [[YSLContainerViewController alloc]initWithControllers:@[xigua,bangbing,mangguo] topBarHeight:statusHeight+navigationHeight parentViewController:self];
        containerVC.delegate = self;
        containerVC.menuItemFont = [UIFont systemFontOfSize:12];
        containerVC.menuItemTitleColor = [UIColor colorWithHexString:@"#808080"];
        containerVC.menuItemSelectedTitleColor = [UIColor colorWithHexString:@"#f0c960"];
        containerVC.menuBackGroudColor = [UIColor colorWithHexString:@"#2b2b2b"];
        containerVC.menuIndicatorColor = [UIColor colorWithHexString:@"#f0c960"];
        [self.view addSubview:containerVC.view];
    }
    else if (_articleidArrays.count==2)
    {
        JiangLiaoViewController * xigua = [[JiangLiaoViewController alloc]init];
        xigua.articleid = _articleidArrays[0];
        xigua.title = _middleScrollTitle[0];
        xigua.ImgUrl =_middleScrollImg[0] ;
        xigua.zhaiyao =_zhaiyaoArrays[0] ;
        YiZuiDouViewController * bangbing = [[YiZuiDouViewController alloc]init];
        bangbing.articleid = _articleidArrays[1];
        bangbing.title = _middleScrollTitle[1];
        bangbing.ImgUrl =_middleScrollImg[1] ;
        bangbing.zhaiyao =_zhaiyaoArrays[1] ;
        float statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        float navigationHeight = self.navigationController.navigationBar.frame.size.height;
        YSLContainerViewController * containerVC = [[YSLContainerViewController alloc]initWithControllers:@[xigua,bangbing] topBarHeight:statusHeight+navigationHeight parentViewController:self];
        containerVC.delegate = self;
        containerVC.menuItemFont = [UIFont systemFontOfSize:12];
        containerVC.menuItemTitleColor = [UIColor colorWithHexString:@"#808080"];
        containerVC.menuItemSelectedTitleColor = [UIColor colorWithHexString:@"#f0c960"];
        containerVC.menuBackGroudColor = [UIColor colorWithHexString:@"#2b2b2b"];
        containerVC.menuIndicatorColor = [UIColor colorWithHexString:@"#f0c960"];
        [self.view addSubview:containerVC.view];
    }
    else if (_articleidArrays.count==4)
    {
        JiangLiaoViewController * xigua = [[JiangLiaoViewController alloc]init];
        xigua.articleid = _articleidArrays[0];
        xigua.title = _middleScrollTitle[0];
        xigua.ImgUrl =_middleScrollImg[0] ;
        xigua.zhaiyao =_zhaiyaoArrays[0] ;
        YiZuiDouViewController * bangbing = [[YiZuiDouViewController alloc]init];
        bangbing.articleid = _articleidArrays[1];
        bangbing.title = _middleScrollTitle[1];
        bangbing.ImgUrl =_middleScrollImg[1] ;
        bangbing.zhaiyao =_zhaiyaoArrays[1] ;
        YangLeDuoViewController * mangguo = [[YangLeDuoViewController alloc]init];
        mangguo.articleid = _articleidArrays[2];
        mangguo.title = _middleScrollTitle[2];
        mangguo.ImgUrl =_middleScrollImg[2] ;
        mangguo.zhaiyao =_zhaiyaoArrays[2] ;
        QiShuiViewController * nailao = [[QiShuiViewController alloc]init];
        nailao.articleid = _articleidArrays[3];
        nailao.title = _middleScrollTitle[3];
        nailao.ImgUrl =_middleScrollImg[3] ;
        nailao.zhaiyao =_zhaiyaoArrays[3] ;
        float statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        float navigationHeight = self.navigationController.navigationBar.frame.size.height;
        YSLContainerViewController * containerVC = [[YSLContainerViewController alloc]initWithControllers:@[xigua,bangbing,mangguo,nailao] topBarHeight:statusHeight+navigationHeight parentViewController:self];
        containerVC.delegate = self;
        containerVC.menuItemFont = [UIFont systemFontOfSize:12];
        containerVC.menuItemTitleColor = [UIColor colorWithHexString:@"#808080"];
        containerVC.menuItemSelectedTitleColor = [UIColor colorWithHexString:@"#f0c960"];
        containerVC.menuBackGroudColor = [UIColor colorWithHexString:@"#2b2b2b"];
        containerVC.menuIndicatorColor = [UIColor colorWithHexString:@"#f0c960"];
        [self.view addSubview:containerVC.view];

    }
    else if (_articleidArrays.count==5)
    {
        JiangLiaoViewController * xigua = [[JiangLiaoViewController alloc]init];
        xigua.articleid = _articleidArrays[0];
        xigua.title = _middleScrollTitle[0];
        xigua.ImgUrl =_middleScrollImg[0] ;
        xigua.zhaiyao =_zhaiyaoArrays[0] ;
        YiZuiDouViewController * bangbing = [[YiZuiDouViewController alloc]init];
        bangbing.articleid = _articleidArrays[1];
        bangbing.title = _middleScrollTitle[1];
        bangbing.ImgUrl =_middleScrollImg[1] ;
        bangbing.zhaiyao =_zhaiyaoArrays[1] ;
        YangLeDuoViewController * mangguo = [[YangLeDuoViewController alloc]init];
        mangguo.articleid = _articleidArrays[2];
        mangguo.title = _middleScrollTitle[2];
        mangguo.ImgUrl =_middleScrollImg[2] ;
        mangguo.zhaiyao =_zhaiyaoArrays[2] ;
        QiShuiViewController * nailao = [[QiShuiViewController alloc]init];
        nailao.articleid = _articleidArrays[3];
        nailao.title = _middleScrollTitle[3];
        nailao.ImgUrl =_middleScrollImg[3] ;
        nailao.zhaiyao =_zhaiyaoArrays[3] ;
        FanDianViewController * xuegao = [[FanDianViewController alloc]init];
        xuegao.articleid = _articleidArrays[4];
        xuegao.title = _middleScrollTitle[4];
        xuegao.ImgUrl =_middleScrollImg[4] ;
        xuegao.zhaiyao =_zhaiyaoArrays[4] ;
        float statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        float navigationHeight = self.navigationController.navigationBar.frame.size.height;
        YSLContainerViewController * containerVC = [[YSLContainerViewController alloc]initWithControllers:@[xigua,bangbing,mangguo,nailao,xuegao] topBarHeight:statusHeight+navigationHeight parentViewController:self];
        containerVC.delegate = self;
        containerVC.menuItemFont = [UIFont systemFontOfSize:12];
        containerVC.menuItemTitleColor = [UIColor colorWithHexString:@"#808080"];
        containerVC.menuItemSelectedTitleColor = [UIColor colorWithHexString:@"#f0c960"];
        containerVC.menuBackGroudColor = [UIColor colorWithHexString:@"#2b2b2b"];
        containerVC.menuIndicatorColor = [UIColor colorWithHexString:@"#f0c960"];
        [self.view addSubview:containerVC.view];
    }
    
    else
    {
    JiangLiaoViewController * xigua = [[JiangLiaoViewController alloc]init];
    xigua.articleid = _articleidArrays[0];
    xigua.title = _middleScrollTitle[0];
    xigua.ImgUrl =_middleScrollImg[0] ;
    xigua.zhaiyao =_zhaiyaoArrays[0] ;
    YiZuiDouViewController * bangbing = [[YiZuiDouViewController alloc]init];
    bangbing.articleid = _articleidArrays[1];
    bangbing.title = _middleScrollTitle[1];
    bangbing.ImgUrl =_middleScrollImg[1] ;
    bangbing.zhaiyao =_zhaiyaoArrays[1] ;
    YangLeDuoViewController * mangguo = [[YangLeDuoViewController alloc]init];
    mangguo.articleid = _articleidArrays[2];
    mangguo.title = _middleScrollTitle[2];
    mangguo.ImgUrl =_middleScrollImg[2] ;
    mangguo.zhaiyao =_zhaiyaoArrays[2] ;
    QiShuiViewController * nailao = [[QiShuiViewController alloc]init];
    nailao.articleid = _articleidArrays[3];
    nailao.title = _middleScrollTitle[3];
    nailao.ImgUrl =_middleScrollImg[3] ;
    nailao.zhaiyao =_zhaiyaoArrays[3] ;
    FanDianViewController * xuegao = [[FanDianViewController alloc]init];
    xuegao.articleid = _articleidArrays[4];
    xuegao.title = _middleScrollTitle[4];
    xuegao.ImgUrl =_middleScrollImg[4] ;
    xuegao.zhaiyao =_zhaiyaoArrays[4] ;
    XiaWuTeaViewController * xiawu = [[XiaWuTeaViewController alloc]init];
    xiawu.articleid = _articleidArrays[5];
    xiawu.title = _middleScrollTitle[5];
    xiawu.ImgUrl =_middleScrollImg[5] ;
    xiawu.zhaiyao =_zhaiyaoArrays[5] ;
    // ContainerView
    float statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    float navigationHeight = self.navigationController.navigationBar.frame.size.height;
    YSLContainerViewController * containerVC = [[YSLContainerViewController alloc]initWithControllers:@[xigua,bangbing,mangguo,nailao,xuegao,xiawu] topBarHeight:statusHeight+navigationHeight parentViewController:self];
    containerVC.delegate = self;
    containerVC.menuItemFont = [UIFont systemFontOfSize:12];
   containerVC.menuItemTitleColor = [UIColor colorWithHexString:@"#808080"];
    containerVC.menuItemSelectedTitleColor = [UIColor colorWithHexString:@"#f0c960"];
    containerVC.menuBackGroudColor = [UIColor colorWithHexString:@"#2b2b2b"];
    containerVC.menuIndicatorColor = [UIColor colorWithHexString:@"#f0c960"];
    [self.view addSubview:containerVC.view];
    }
}
-(void)containerViewItemIndex:(NSInteger)index currentController:(UIViewController *)controller
{
    [controller viewWillAppear:YES];
}

@end
