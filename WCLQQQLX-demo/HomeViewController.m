
#import "HomeViewController.h"
#import "ProgressHUD.h"
#import "ZhengWenModel.h"
#import "ZhengWenTableViewCell.h"
#import "DetailViewController.h"
#import "SDCycleScrollView.h"
#import "AdvertiseMentViewController.h"
#import "TLAlertView.h"
#import "SuperSearchViewController.h"
#import "AllVideoViewController.h"
#import "ClassViewController.h"
#import "SearchViewController.h"
#import "Liulanjilu.h"
#import "AppDelegate.h"
#import "LoginBtn.h"
#import "FeedBackViewController.h"
#import "QYDemoBadgeView.h"
#import "YSFSDK.h"
#import "YSFSessionViewController.h"
#define Start_X 0          // 第一个按钮的X坐标
#define Start_Y imgScrollView.frame.size.height+5           // 第一个按钮的Y坐标
#define Width_Space 0        // 2个按钮之间的横间距
#define Height_Space 0      // 竖间距
#define Button_Height 30.0f    // 高
#define Button_Width [UIScreen mainScreen].bounds.size.width / 3     // 宽 110

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,SDCycleScrollViewDelegate,YSFConversationManagerDelegate>
@property (strong, nonatomic) UIButton                          *popButton;
@property (strong, nonatomic) UIWindow                          *window;
@property(nonatomic,strong) NSTimer  * timer;
@property (strong, nonatomic) YSFDemoBadgeView *badgeView;

@end

@implementation HomeViewController
{
    NSMutableArray * _dataSource;
    UISearchBar * _searchBar;
    UITableView * _tableView;
    NSMutableArray * _middleScrollImg;//中间滚动条图片
    NSMutableArray * _middleScrollTitle;//中间滚动条汉字
    UIView * view;//放头部view的空间
    Liulanjilu *_liulanjilu;
    NSManagedObjectContext *_managedObjectContext;
    NSMutableArray * _picArray;//装图片数据
    NSMutableArray * _titleArray;//存图片title
    NSMutableArray * _picIdArray;//装图片id
    NSMutableArray * _picZhaiYao;//装图片摘要
    UIButton *  _getDataFailButton;//加载失败显示的按钮
    NSMutableArray *_articleidArrays; //6分按钮的id数组
    NSMutableArray *_zhaiyaoArrays;
    NSInteger _index;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _window.hidden = NO;
    [MobClick beginLogPageView:@"homePage"];
    [[[YSFSDK sharedSDK] conversationManager] setDelegate:self];
    [self configBadgeView];
    //创建悬浮框
    // [self performSelector:@selector(createButton) withObject:nil afterDelay:4];
}

- (void)configBadgeView
{
    NSInteger count = [[[YSFSDK sharedSDK] conversationManager] allUnreadCount];
    [_badgeView setHidden:count == 0];
    NSString *value = count > 99 ? @"99+" : [NSString stringWithFormat:@"%zd",count];
    [_badgeView setBadgeValue:value];
}
-(void)onUnreadCountChanged:(NSInteger)count
{
    [self configBadgeView];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    if ([AppConstants downloadButtonPress2Pop]) {
        [AppConstants setDownloadButtonPress2Pop:NO];
        ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainTabBarController.selectedIndex =1;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _picArray = [NSMutableArray array];
    _dataSource =[NSMutableArray array];
    _middleScrollImg = [NSMutableArray array];
    _middleScrollTitle = [NSMutableArray array];
    _articleidArrays = [NSMutableArray array];
    _zhaiyaoArrays = [NSMutableArray array];
    _picIdArray = [NSMutableArray array];
    _picZhaiYao = [NSMutableArray array];
    _titleArray = [NSMutableArray array];
    [AppConstants YeMianSetStatus:FirstYemian];
    //    self.navigationItem.title = NSLocalizedStringCN(@"mifang", @"");
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"#CCCCCC"],NSFontAttributeName : [UIFont boldSystemFontOfSize:16]};
    //设置导航栏的返回按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = item;
    //更改导航栏的返回图标"<"的颜色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"#CCCCCC"];
    UIButton * buton = [[UIButton alloc]initWithFrame:CGRectMake(UIScreenWidth-30, 44,60, 20)];
    [buton setTitle:NSLocalizedStringCN(@"kefu", @"") forState:UIControlStateNormal];
    buton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    _badgeView = [[YSFDemoBadgeView alloc]initWithFrame:CGRectMake(30, -2, 20, 20)];
    [buton addSubview:_badgeView];
    [buton addTarget:self action:@selector(createButton) forControlEvents:UIControlEventTouchUpInside];
    [buton setTitleColor:[UIColor colorWithHexString:@"#FF4500"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:buton];
    [self initSearchButtons];
    _index = 10;
    //创建tableView
    [self createTableView];
    [self getIntroduceDataFromServer];
    [self getAdvertisementFromServer];
    //下拉刷新
    [self form];
    //上拉加载
    [self updown];
    //数据库
    _managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
}
#pragma mark - 客服
-(void)createButton
{
    YSFSource * source = [[YSFSource alloc]init];
    source.title = NSLocalizedStringCN(@"appname", @"");
    source.urlString = @"http://www.greenishome.com";
    YSFSessionViewController *vc = [[YSFSDK sharedSDK] sessionViewController];
    vc.sessionTitle = NSLocalizedStringCN(@"appname", @"");
    vc.source = source;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}


//下拉刷新
- (void)form {
    __weak HomeViewController *weakSelf = self;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        _index = 10;
        
        
        [weakSelf getIntroduceDataFromServer];
        [weakSelf getAdvertisementFromServer];
        
    }];

}
//上拉加载
- (void)updown {
    __weak HomeViewController *weakSelf = self;
    _tableView.mj_footer = [MJRefreshBackNormalFooter  footerWithRefreshingBlock:^{
        _index += 10;
        if (_index >= 50) {
            [ProgressHUD showError:NSLocalizedStringCN(@"nomorepost", @"")];
            [_tableView.mj_footer endRefreshing];
            return ;
        } else {
            [weakSelf getIntroduceDataFromServer];
        }
    }];
    
}

//请求广告栏数据
-(void)getAdvertisementFromServer
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    // [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
    // NSArray * array = @[@"飞行模式",@"无网络",@"3G/4G",@"WIFI"];
    //NSString * title = [NSString stringWithFormat:@"%@",array[status+1]];
    //NSString * message = [NSString stringWithFormat:@"手机当前是%@",array[status+1]];
    // TLAlertView * alertView = [[TLAlertView alloc]initWithTitle:title message:message buttonTitle:@"确认"];
    //        [alertView show];
    // }];
    //开始监听网络状态
    // [manager.reachabilityManager startMonitoring];
    
    NSString *urlString = [NSString stringWithFormat:@"%@resource/article/frontpage/slide/list/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"page":@"1", @"pageSize":@"10"};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              //   NSLog(@"ggurlString = %@", urlString);
              NSLog(@"ggSuccess: %@", responseObject);
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  NSArray *articles = [responseObject objectForKey:@"articles"];
                  [_picArray removeAllObjects];
                  [_titleArray removeAllObjects];
                  [_picIdArray removeAllObjects];
                  [_picZhaiYao removeAllObjects];
                  for (NSDictionary * dic in articles) {
                      NSString * picString = [NSString stringWithFormat:@"%@%@",[AppConstants httpChinaAndEnglishForHead],dic[@"ImgUrl"]];
                      [_picArray addObject:picString];
                      NSString * titleStr = [NSString stringWithFormat:@"%@",dic[@"title"]];
                      [_titleArray addObject:titleStr];
                      NSString *  picId = dic[@"articleid"];
                      [_picIdArray addObject:picId];
                      NSString * zhaiYao = dic[@"zhaiyao"];
                      [_picZhaiYao addObject:zhaiYao];
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
    [self getAdvertisementFromServer];
    [self getIntroduceDataFromServer];
}


//获取正文
-(void)getIntroduceDataFromServer
{
    [ProgressHUD show:NSLocalizedStringCN(@"loading", @"")];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@resource/formula/frontpage/list/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"page":@"1", @"pageSize":[NSString stringWithFormat:@"%ld",(long)_index]};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              [_tableView.mj_header endRefreshing];
              [_tableView.mj_footer endRefreshing];
              //清空数组
              [_dataSource removeAllObjects];
//              NSLog(@"success zhengwen urlString = %@", urlString);
//              NSLog(@"Success: %@", responseObject);
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  NSArray *articles = [responseObject objectForKey:@"formulas"];
                  for (NSDictionary * dict in articles) {
                      ZhengWenModel * model = [ZhengWenModel modelWith:dict];
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

-(void)createTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height  - 64 - 49) style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    // [_tableView registerClass:[ZhengWenTableViewCell class] forCellReuseIdentifier:@"cell"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}




#pragma mark - tableview协议
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section],(long)[indexPath row]];//以indexPath来唯一确定cell
    ZhengWenTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell ==nil){
        
        cell = [[ZhengWenTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    ZhengWenModel * model = _dataSource[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.name.highlightedTextColor = [UIColor colorWithHexString:@"#282828"];
    cell.model = model;
    cell.backgroundColor = [UIColor colorWithHexString:@"#1e1e1e"];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // [_window resignKeyWindow];
    _window.hidden = YES;
    ZhengWenModel * model = _dataSource [indexPath.row];
    DetailViewController * detail = [[DetailViewController alloc]init];
    
    detail.formulaId = model.FormulaID;
    detail.name = model.FormulaName;
    detail.mainimageView = model.ImgUrl;
    detail.detailStr = model.Introduction;//功效
    detail.caiLiaoStr = model.Ingredients;//材料
    detail.videoUrl = model.VideoUrl;//
    detail.steps = model.Steps;
    if (![model.share_url isEqualToString:@""]) {
        detail.shareUrl = model.share_url;
    } else {
        model.share_url = @"http://greenishome.com/";
        detail.shareUrl = model.share_url;
    }
    
    [MobClick event:@"Click" label:model.FormulaName];
    detail.hidesBottomBarWhenPushed = YES;
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Liulanjilu"];
    //
    NSArray * array = [[_managedObjectContext executeFetchRequest:request error:nil] mutableCopy];
    for (Liulanjilu * his in array) {
        if ([his.titleFirst isEqualToString:model.FormulaName]) {
            [self.navigationController pushViewController:detail animated:YES];
            return;
        }
    }
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Liulanjilu" inManagedObjectContext:_managedObjectContext];
    _liulanjilu = [[Liulanjilu alloc]initWithEntity:entity insertIntoManagedObjectContext:_managedObjectContext];
    
    //        self.history.index = @(self.index);
    _liulanjilu.imageliulan = model.ImgUrl;
    _liulanjilu.titleFirst = model.FormulaName;
    _liulanjilu.idss = model.FormulaID;
    _liulanjilu.titleSecond = model.Ingredients;
    _liulanjilu.gongxiao = model.Introduction;
    _liulanjilu.videoURL = model.VideoUrl;
    _liulanjilu.shareUrl = model.share_url;
    _liulanjilu.step = model.Steps;
    [_managedObjectContext save:nil];
    
    
    
    [self.navigationController pushViewController:detail animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIScreen mainScreen].bounds.size.width / 800  * 533+35;
  
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50+[UIScreen mainScreen].bounds.size.width / 800  * 533)];
    [self.view addSubview:view];
    view.userInteractionEnabled = YES;
    view.backgroundColor = [UIColor colorWithHexString:@"#1e1e1e"];
    //公告栏
    SDCycleScrollView *cycleScrollView2 = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width / 800  * 533) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cycleScrollView2.hidesForSinglePage = NO;
    cycleScrollView2.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    cycleScrollView2.titlesGroup = _titleArray;
    cycleScrollView2.currentPageDotColor = [UIColor whiteColor]; // 自定义分页控件小圆标颜色
    [view addSubview:cycleScrollView2];
    
    //         --- 模拟加载延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cycleScrollView2.imageURLStringsGroup = _picArray;
    });
    UIButton *button;
    for (int i = 0; i < 2; i++) {
        NSArray * nameArray = @[NSLocalizedStringCN(@"shipinzhuanqu", @""),NSLocalizedStringCN(@"shipufenlei", @"")];
        NSArray *imageArray = @[@"videoPlay",@"hotSearch"];
        
        button = [[UIButton alloc] initWithFrame:CGRectMake(i *[UIScreen mainScreen].bounds.size.width / 2 , CGRectGetMaxY(cycleScrollView2.frame) + 4, [UIScreen mainScreen].bounds.size.width / 2, 35)];
        [button setTitleColor:[UIColor colorWithHexString:@"#dedede"] forState:UIControlStateNormal];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        [button setTitle:nameArray[i] forState:UIControlStateNormal];
        UIImageView * liaoImg = [[UIImageView alloc]init];
        liaoImg.image = [UIImage imageNamed:imageArray[i]];
        [button setImage:[self scaleToSize:liaoImg.image size:CGSizeMake(20, 20)] forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
        button.tag = i + 1;
        [button addTarget:self action:@selector(threeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
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



-(void)threeBtnClick:(UIButton *)button
{
    switch (button.tag) {
        case 1:
        {
            NSLog(@"视频专区");
            AllVideoViewController * shipin = [[AllVideoViewController alloc]init];
            shipin.pictureIdArray = _picIdArray;
            [MobClick event:@"videoClick" label:[AppConstants userInfo].nickname durations:2];
            [self.navigationController pushViewController:shipin animated:YES];
        }
            break;
        case 2:
        {
            NSLog(@"热门搜索");
            SuperSearchViewController *searchViewController = [[SuperSearchViewController alloc] init];
            searchViewController.hidesBottomBarWhenPushed = YES;
            [MobClick event:@"hotSearchClick" label:[AppConstants userInfo].nickname durations:1];
            [self.navigationController pushViewController:searchViewController animated:YES];
        }
            break;
            //        case 3:
            //        {
            //            NSLog(@"我的收藏");
            //            CollectionViewController *collection = [[CollectionViewController alloc] init];
            //            ZhengWenModel * model = _dataSource [button.tag-3];
            //            collection.shareUrl = model.share_url;
            //            collection.detailStr = model.Introduction;
            //            collection.videoUrl = model.VideoUrl;
            //            collection.caiLiaoStr = model.Ingredients;
            //            collection.step = model.Steps;
            //            [self.navigationController pushViewController:collection animated:YES];
            //        }
            //            break;
        default:
            break;
    }
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 50 +[UIScreen mainScreen].bounds.size.width / 800  * 533;//260+
}
#pragma mark - 公告栏代理方法
/** 点击图片回调 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"gg--%zd",index);
    AdvertiseMentViewController * adver = [[AdvertiseMentViewController alloc]init];
    adver.pictureId = _picIdArray[index];
    adver.picture = _picArray[index];
    adver.picZhaiYao = _picZhaiYao[index];
    adver.name = _titleArray[index];
    [MobClick event:@"homeGG" label:[AppConstants userInfo].nickname durations:1];
    [self.navigationController pushViewController:adver animated:YES];
}

/** 图片滚动回调 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index
{
    //    NSLog(@"图片滚动:%zd",index);
}

#pragma mark - 创建右侧搜索button
-(void)initSearchButtons
{
    LoginBtn *search = [[LoginBtn alloc] initWithFrame:CGRectMake(0, 64, 537 / 2, 30)];
    self.navigationItem.titleView = search;
    [search setBackgroundImage:[UIImage imageNamed:@"search_textfield"] forState:UIControlStateNormal];
    search.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [search addTarget:self action:@selector(searchButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [search setTitle:NSLocalizedStringCN(@"sousuocaipu", @"") forState:UIControlStateNormal];
    [search setTitleColor:[UIColor colorWithHexString:@"#bebebe"] forState:UIControlStateNormal];
    
}

- (void)searchButtonPress {
    SearchViewController *searchViewController = [[SearchViewController alloc] init];
    [MobClick event:@"searchClick" label:[AppConstants userInfo].nickname durations:1];
//     searchViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewController animated:NO];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"viewdiddisappear");
    
}
//隐藏导航栏navigationbar和底部tabbar
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    NSLog(@"viewwilldisappear");
    [self.window resignKeyWindow];
    self.window = nil;
    [MobClick endLogPageView:@"homePage"];
    [ProgressHUD dismiss];
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    
    
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.y>0) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.tabBarController.tabBar.hidden = YES;
        _tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+10);
    }
    else
        
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.tabBarController.tabBar.hidden = NO;
        _tableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 49);
    }
}



@end
