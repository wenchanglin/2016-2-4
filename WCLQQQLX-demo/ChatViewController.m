//
//  MyMapLineViewController.m
//  WCLQQQLX-demo
//
//  Created by wen on 16/5/24.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatLiaoLiaoPostDataModel.h"
#import "ZhengWenTableViewCell.h"
#import "SDCycleScrollView.h"
#import "GuangGaoLanDetailViewController.h"
#import "LiaoLiaoGuangGaoDetailModel.h"
#import "LiaoLiaoTableViewCell.h"
#import "ChatErJiViewController.h"
#import "LocalImageViewController.h"
#import "PostViewController.h"
#import "LiaoLiaoTouXiangViewController.h"
#import "Masonry.h"
#import "FeedBackViewController.h"
#import "ReMenTieZiViewController.h"
#import "GuanFangHuoDongViewController.h"
@interface ChatViewController ()<UITableViewDataSource,UITableViewDelegate,SDCycleScrollViewDelegate,LocalImageViewControllerDelegate>//SDCycleScrollViewDelegate
@property (strong, nonatomic) UIButton                          *getDataFailButton;
@property (nonatomic) BOOL                                      isDataShow;
@property (strong, nonatomic) LocalImageViewController          *localImageViewController;
@property (nonatomic) BOOL                                      isPush;
@property (nonatomic) BOOL                                      isAllowPush;
@property (strong, nonatomic) NSArray                           *selectedImages;
@property(strong,nonatomic) UITableView * tableView;


@end

@implementation ChatViewController
{
    NSMutableArray * _dataSource;
    NSMutableArray * _picArray;
    NSMutableArray * _picNameArray;
    NSMutableArray * _picIdArray;
    UIView * headView;
    NSMutableArray * _mArray;
    NSInteger _index;
    NSMutableArray * _reMenIDArray;
    NSMutableArray * _reMenPicArray;
    NSMutableArray * _reMenNameArray;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"LiaoTian"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAllData) name:@"sendPostSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(request) name:@"deleteLiaoLiao" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAllData) name:@"pinglunchenggong" object:nil];
    [_tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"LiaoTian"];
    [ProgressHUD dismiss];
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    
}
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.y>0) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.tabBarController.tabBar.hidden = YES;
        _tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
    }
    else
        
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.tabBarController.tabBar.hidden = NO;
        _tableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height -64 -49);
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //评论界面
    //        if (_isPush && _isAllowPush) {
    //            _isAllowPush = NO;
    //            _isPush = NO;
    //            PostViewController *postViewController = [[PostViewController alloc] initWithImages:_selectedImages andPrefix:@"" andID:@""];
    //
    //            _selectedImages = nil;
    //
    //            [self.navigationController pushViewController:postViewController animated:YES];
    //        }
    
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    [AppConstants YeMianSetStatus:ThirdYemian];
    //_index =10;
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView.tableHeaderView.height = 0;
    _dataSource= [NSMutableArray array];
    _picArray= [NSMutableArray array];
    _picNameArray= [NSMutableArray array];
    _picIdArray= [NSMutableArray array];
    _reMenIDArray = [NSMutableArray array];
    _reMenPicArray = [NSMutableArray array];
    _reMenNameArray = [NSMutableArray array];
    self.navigationItem.title = NSLocalizedStringCN(@"liaoliao", @"");
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"#CCCCCC"],NSFontAttributeName : [UIFont boldSystemFontOfSize:16]};
    //设置导航栏的返回按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = item;
    UIButton * buton = [[UIButton alloc]initWithFrame:CGRectMake(UIScreenWidth-90, 44, 80, 20)];
    [buton setTitle:NSLocalizedStringCN(@"lianxiwomen", @"") forState:UIControlStateNormal];
    buton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [buton addTarget:self action:@selector(createButton) forControlEvents:UIControlEventTouchUpInside];
    [buton setTitleColor:[UIColor colorWithHexString:@"#FF4500"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:buton];
    _index = 10;
    //更改导航栏的返回图标"<"的颜色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [self createTableView];
    [self requestAds];
    [self requestData];
    [self requestReMenID];//获取热门活动的id
    [self header];//下拉刷新
   
    
}
-(void)requestReMenID
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    NSString *urlString = [NSString stringWithFormat:@"%@interaction/forum/query/topic/list/activity/list/index.ashx", [AppConstants httpHeader]];
    NSDictionary *parameters = @{@"page" :@"1", @"pageSize" : @"10"};
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
            NSLog(@"success urlString = %@", urlString);
            NSLog(@"官方活动Success: %@", responseObject);
            [_reMenIDArray removeAllObjects];
            NSArray *topics = [responseObject objectForKey:@"Topics"];
            for (NSDictionary * dict in topics) {
                NSString * string = [NSString stringWithFormat:@"%@%@",[AppConstants httpChinaAndEnglishForHead],dict[@"img_url"]];
                [_reMenPicArray addObject:string];
                [_reMenNameArray addObject:dict[@"name"]];
                [_reMenIDArray addObject:dict[@"id"]];
            }
        }
        else if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 0)
        {
            NSLog(@"获取列表失败 %@", urlString);
            [self getDataFail];
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"false urlString = %@", urlString);
        NSLog(@"Error: %@", error);
        
        [self getDataFail];
    }];
}
-(void)createButton
{
    if ([[AppConstants userInfo].accessToken isEqualToString:@""]) {
        
        [ProgressHUD showError:NSLocalizedStringCN(@"dengluzaifankui", @"")];
        return;
    }
    FeedBackViewController * feedBack = [[FeedBackViewController alloc]init];
    [self.navigationController pushViewController:feedBack animated:YES];
    
}
-(void)header
{
    __weak ChatViewController *weakSelf = self;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _index = 10;
        [weakSelf requestAds];
    }];
    weakSelf.tableView.mj_header.automaticallyChangeAlpha = YES;
}


-(void)request
{
    
    [_tableView removeFromSuperview];
    [self createTableView];
    [self requestAds];
    [self requestData];
    [self header];
}
#pragma mark - 发表评论控件
//-(void)initNavigationBar
//{
//    self.navigationItem.title = NSLocalizedStringCN(@"liaoliao", @"");
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"#CCCCCC"],NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
//        UIImage *postButtonImage = [UIImage imageNamed:@"edit"];
//        postButtonImage = [postButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:postButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(postButtonPress)];
//}
//-(void)postButtonPress
//{
//        _isAllowPush = YES;
//        _localImageViewController = [[LocalImageViewController alloc] init];
//        _localImageViewController.maxPhotoNumber = 9;
//        _localImageViewController.delegate = self;
//        _localImageViewController.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:_localImageViewController animated:YES];
//
//
//}


-(void)requestAds
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@interaction/forum/topic/ad/query/list/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"page":@"1", @"pageSize":[NSString stringWithFormat:@"%zd",_index]};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
             // NSLog(@"success 聊聊公告栏= %@", urlString);
              //NSLog(@"Success: 聊聊公告栏数据%@", responseObject);
              [_tableView.mj_header endRefreshing];
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  NSArray *ADs = [responseObject objectForKey:@"ADs"];
                  
                  [_picArray removeAllObjects];
                  [_picNameArray removeAllObjects];
                  [_picIdArray removeAllObjects];
                  for (NSDictionary * dic in ADs) {
                      NSString * string = [NSString stringWithFormat:@"%@%@",[AppConstants httpChinaAndEnglishForHead],dic[@"img_url"]];
                      [_picArray addObject:string];
                      [_picNameArray addObject:dic[@"name"]];
                      [_picIdArray addObject:dic[@"id"]];
                  }
                  [_tableView reloadData];
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
-(void)requestData
{
    
    
    [_dataSource removeAllObjects];
    [ProgressHUD show:NSLocalizedStringCN(@"loading", @"")];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@interaction/forum/post/list/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"AccessToken":[AppConstants userInfo].accessToken, @"page":@"1", @"pageSize":@"50"};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
//              NSLog(@"chat urlString = %@", urlString);
//              NSLog(@"chat: %@", responseObject);
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                    [_dataSource removeAllObjects];
                  NSArray *posts = [responseObject objectForKey:@"posts"];
                  for (NSDictionary * dic in posts) {
                      LiaoLiaoGuangGaoDetailModel * model = [LiaoLiaoGuangGaoDetailModel modelWith:dic];
                      [_dataSource addObject:model];
                  }
                  
                  [_tableView reloadData];
                  [ProgressHUD dismiss];
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
    
    if (_isDataShow == NO) {
        _getDataFailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_getDataFailButton setImage:[UIImage imageNamed:@"reload.png"] forState:UIControlStateNormal];
        [_getDataFailButton addTarget:self action:@selector(reloadAllData) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_getDataFailButton];
        
        [_getDataFailButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.centerY.equalTo(self.view);
            make.width.and.height.equalTo(@160);
        }];
    }
}
-(void)reloadAllData
{
    [_getDataFailButton removeFromSuperview];
    [_tableView removeFromSuperview];
    [self createTableView];
    [self requestAds];
    [self requestData];
    [self requestReMenID];
    [self header];
}
-(void)createTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height -64) style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    
}
#pragma mark - 公告栏代理方法
-(void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"gg--%zd",index);
    GuangGaoLanDetailViewController * GuangGao = [[GuangGaoLanDetailViewController alloc]init];
    GuangGao.picId = _picIdArray[index];
    GuangGao.name = _picNameArray[index];
    [MobClick event:@"GGClick" label:[AppConstants userInfo].nickname durations:1];
    [self.navigationController pushViewController:GuangGao animated:YES];
}
/** 图片滚动回调 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index
{
    //    NSLog(@"图片滚动回调:%zd",index);
}


#pragma mark - 发表评论必须实现的协议方法 别删
- (void)getSelectImage:(NSArray *)imageArr
{
    
    NSLog(@"again?");
    
    _isPush = YES;
    _selectedImages = imageArr;
    
    _localImageViewController.delegate = nil;
}
#pragma mark - tableviewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section],(long)[indexPath row]];//以indexPath来唯一确定cell
    LiaoLiaoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //出列可重用的cell
    
    if(cell ==nil){
        
        cell = [[LiaoLiaoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    LiaoLiaoGuangGaoDetailModel * model = _dataSource[indexPath.row];
    cell.model = model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.headImageView.tag = 700+indexPath.row;
    [cell.headImageView addTarget:self action:@selector(touxiangClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    
}
-(void)touxiangClick:(UIButton *)button
{
    LiaoLiaoTouXiangViewController *touXiang = [[LiaoLiaoTouXiangViewController alloc] init];
    LiaoLiaoGuangGaoDetailModel * model = _dataSource[ button.tag - 700];
    touXiang.userId = model.userId;
    touXiang.hidesBottomBarWhenPushed = YES;
    touXiang.name = model.nickName;
    touXiang.headPic = model.avatar;
    if ([[AppConstants userInfo].accessToken isEqualToString:@""]) {
        [ProgressHUD showError:NSLocalizedStringCN(@"dengluzaichakan", @"")];
        //[self.navigationController popViewControllerAnimated:YES];
        return;
    }
    else
    {
        [self.navigationController pushViewController:touXiang animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiaoLiaoGuangGaoDetailModel * model = _dataSource[indexPath.row];
    _mArray =[NSMutableArray array];
    if (![model.image1URL isEqualToString:@""]) {
        [_mArray addObject:model.image1URL];
    }
    if (![model.image2URL isEqualToString:@""]) {
        [_mArray addObject:model.image2URL];
    }
    if (![model.image3URL isEqualToString:@""]) {
        [_mArray addObject:model.image3URL];
    }
    if (![model.image4URL isEqualToString:@""]) {
        [_mArray addObject:model.image4URL];
    }if (![model.image5URL isEqualToString:@""]) {
        [_mArray addObject:model.image5URL];
    }if (![model.image6URL isEqualToString:@""]) {
        [_mArray addObject:model.image6URL];
    }
    if (![model.image7URL isEqualToString:@""]) {
        [_mArray addObject:model.image7URL];
    }
    if (![model.image8URL isEqualToString:@""]) {
        [_mArray addObject:model.image8URL];
    }
    if (![model.image9URL isEqualToString:@""]) {
        [_mArray addObject:model.image9URL];
    }
    
    UIFont *fnt = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
    // iOS7中用以下方法替代过时的iOS6中的sizeWithFont:constrainedToSize:lineBreakMode:方法
    CGRect tmpRect = [model.content boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-20, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt,NSFontAttributeName, nil] context:nil];
    // 高度H
    CGFloat contentH = tmpRect.size.height;
    
    if (_mArray.count==1)
    {
        
        return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/3*2)+60;
    }
    else if(_mArray.count==2)
    {
        return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/2)+60;
    }
    else if (_mArray.count==3)
    {
        return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/3)+60;
    }
    else if (_mArray.count>=4&&_mArray.count<=6)
    {
        return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/3)+(([UIScreen mainScreen].bounds.size.width-60)/3)+5+60;
    }
    else if (_mArray.count==0)
    {
        return 110+contentH+40;
    }
    else
    {
        return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/3)+(([UIScreen mainScreen].bounds.size.width-60)/3)+(([UIScreen mainScreen].bounds.size.width-60)/3)+5+60;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [UIScreen mainScreen].bounds.size.width/800*533+50;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *  view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50+[UIScreen mainScreen].bounds.size.width/800*533)];
    view.userInteractionEnabled = YES;
    view.backgroundColor = [UIColor blackColor];
    SDCycleScrollView *cycleScrollView2 = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0,  view.bounds.size.width, [UIScreen mainScreen].bounds.size.width/800*533) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cycleScrollView2.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    cycleScrollView2.autoScrollTimeInterval = 6;
    cycleScrollView2.titlesGroup = _picNameArray;
    cycleScrollView2.hidesForSinglePage = NO;
    cycleScrollView2.currentPageDotColor = [UIColor whiteColor]; // 自定义分页控件小圆标颜色
    [view addSubview:cycleScrollView2];
    //         --- 模拟加载延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cycleScrollView2.imageURLStringsGroup = _picArray;
    });
    UIButton *button;
    for (int i = 0; i < 2; i++) {
        NSArray * nameArray = @[NSLocalizedStringCN(@"guanfanghuodong", @""),NSLocalizedStringCN(@"rementiezi", @"")];
        NSArray *imageArray = @[@"guanfang",@"rementiezi"];
        
        button = [[UIButton alloc] initWithFrame:CGRectMake(i *[UIScreen mainScreen].bounds.size.width / 2 , CGRectGetMaxY(cycleScrollView2.frame) + 6, [UIScreen mainScreen].bounds.size.width / 2, 35)];
        [button setTitleColor:[UIColor colorWithHexString:@"#dedede"] forState:UIControlStateNormal];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        [button setTitle:nameArray[i] forState:UIControlStateNormal];
        UIImageView * liaoImg = [[UIImageView alloc]init];
        liaoImg.image = [UIImage imageNamed:imageArray[i]];
        [button setImage:[self scaleToSize:liaoImg.image size:CGSizeMake(20, 20)] forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        button.tag = i + 10;
        [button addTarget:self action:@selector(twoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor colorWithHexString:@"#282828"];
        button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 1, CGRectGetMaxY(cycleScrollView2.frame) + 14, 1, 20)];
        [view addSubview:line];
        line.backgroundColor = [UIColor colorWithHexString:@"#3C3C3C"];
        [view addSubview:button];
    }
    return view;
    
}
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
-(void)twoBtnClick:(UIButton *)button
{
    switch (button.tag) {
        case 10:
        {
            NSLog(@"官方活动");
            GuanFangHuoDongViewController * guanfang = [[GuanFangHuoDongViewController alloc]init];
            guanfang.remenidArray = _reMenIDArray;
            guanfang.biaoTiName = _reMenNameArray[0];
            guanfang.headPic = _reMenPicArray[0];
            guanfang.hidesBottomBarWhenPushed = YES;
            [MobClick event:@"GuanFangHuoDong" label:[AppConstants userInfo].nickname durations:2];
            [self.navigationController pushViewController:guanfang animated:YES];
        }
            break;
        case 11:
        {
            NSLog(@"热门帖子");
            ReMenTieZiViewController * remen = [[ReMenTieZiViewController alloc]init];
            remen.hidesBottomBarWhenPushed = YES;
            [MobClick event:@"ReMenTieZi" label:[AppConstants userInfo].nickname durations:1];
            [self.navigationController pushViewController:remen animated:YES];
        }
            break;
          
        default:
            break;
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatErJiViewController * chaterji = [[ChatErJiViewController alloc]init];
    LiaoLiaoGuangGaoDetailModel * model = _dataSource[indexPath.row];
    chaterji.model =model;
    [MobClick event:@"chatClick" label:model.nickName];
    chaterji.navigationItem.title = NSLocalizedStringCN(@"liaoliaoxiangqing", @"");
    chaterji.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chaterji animated:YES];
}

@end
