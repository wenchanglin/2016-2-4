//
//  MyLiaoLiaoViewController.m
//  歌力思
//
//  Created by wen on 16/7/26.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "MyLiaoLiaoViewController.h"
#import "ChatLiaoLiaoPostDataModel.h"
#import "ZhengWenTableViewCell.h"
#import "LocalImageViewController.h"
#import "PostLiaoLiaoViewController.h"
#import "LiaoLiaoGuangGaoDetailModel.h"
#import "MyLiaoLiaoTableViewCell.h"
#import "LiaoLiaoErJiViewController.h"
#import "Masonry.h"
@interface MyLiaoLiaoViewController ()<UITableViewDelegate,UITableViewDataSource,LocalImageViewControllerDelegate>
@property (strong, nonatomic) UIButton                          *getDataFailButton;
@property (nonatomic) BOOL                                      isDataShow;
@property (strong, nonatomic) LocalImageViewController          *localImageViewController;
@property (nonatomic) BOOL                                      isAllowPush;
@property (strong, nonatomic) NSArray                           *selectedImages;
@property (nonatomic) BOOL                                      isPush;
@property (nonatomic) NSInteger                                 currentPage;
@property (strong, nonatomic) UILabel                           *noLiaoLiaoLabel;
@property (nonatomic, strong, nullable)UIView *currentView; //
@property (nonatomic, strong, nullable)NSArray *currentArray; //
@end

@implementation MyLiaoLiaoViewController
{
    UITableView * _tableView;
    NSMutableArray * _dataSource;
    NSMutableArray * _mArray;
    NSString * _liaoliaoId;
    NSInteger _index;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [ProgressHUD dismiss];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    //[_tableView reloadData];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
//    if (_isPush && _isAllowPush) {
//        _isAllowPush = NO;
//        _isPush = NO;
//        PostLiaoLiaoViewController *postViewController = [[PostLiaoLiaoViewController alloc] initWithImages:_selectedImages andPrefix:@"" andID:@""];
//        
//        _selectedImages = nil;
//        
//        [self.navigationController pushViewController:postViewController animated:YES];
//    }
//    
//    if ([AppConstants isJustPostANewPost]) {
//        [AppConstants setJustPostANewPost:NO];
//        [self reloadData];
//    }
}
//- (void)reloadData {
//    //_currentPage = 1;
//    
//    [self requestData];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(request) name:@"deleteLiaoLiao" object:nil];
    _dataSource= [NSMutableArray array];
   // [self initNavigationBar];
    _index =10;
    [self requestData];
    [self createTableView];
    [self header];//下拉刷新
    [self footer];//上拉加载
    
}
-(void)request
{
   //   [[NSNotificationCenter defaultCenter]removeObserver:self name:@"deleteLiaoLiao" object:nil];
    _index =10;
    [_tableView removeFromSuperview];
    
    [self createTableView];
    
    [self requestData];
   }
-(void)header
{
    __weak MyLiaoLiaoViewController *weakSelf = self;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _index = 10;
        [weakSelf requestData];
    }];
        
}
-(void)footer
{
    __weak MyLiaoLiaoViewController *weakSelf = self;
    _tableView.mj_footer = [MJRefreshBackNormalFooter  footerWithRefreshingBlock:^{
        _index += 10;
        [weakSelf requestData];
    }];

}
//- (void)initNavigationBar {
//    UIImage *postButtonImage = [UIImage imageNamed:@"edit"];
//    postButtonImage = [postButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:postButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(postButtonPress)];
//}
//- (void)postButtonPress {
//    
//    _isAllowPush = YES;
//    
//    _localImageViewController = [[LocalImageViewController alloc] init];
//    _localImageViewController.maxPhotoNumber = 9;
//    _localImageViewController.delegate = self;
//    
//    [self.navigationController pushViewController:_localImageViewController animated:YES];
//}
-(void)requestData
{
     [_dataSource removeAllObjects];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    NSString *urlString = [NSString stringWithFormat:@"%@interaction/forum/post/myself/list/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"AccessToken":[AppConstants userInfo].accessToken, @"page":@"1", @"pageSize":[NSString stringWithFormat:@"%ld",(long)_index]};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"success 我的聊聊 = %@", urlString);
              NSLog(@"Success: 我的聊聊%@", responseObject);
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  [_tableView.mj_header endRefreshing];
                  [_tableView.mj_footer endRefreshing];
                  
                  NSArray *posts = [responseObject objectForKey:@"posts"];
                  if ([posts count] == 0) {
                      
                      [self showNoLiaoLiao];
                      
                  }
                  else
                  {
                  for (NSDictionary * dic in posts)
                    {
                      LiaoLiaoGuangGaoDetailModel * model = [LiaoLiaoGuangGaoDetailModel modelWith:dic];
                      [_dataSource addObject:model];
                    }
                  }
                  
                  [_tableView reloadData];
              }
              else if ([[responseObject objectForKey:@"errno"] isEqualToString:@"4401"]) {
                  NSLog(@"myliaoliao 4401");
                  
                  [AppConstants relogin:^(BOOL success){
                      if (success) {
                          NSLog(@"myliaoliao getDataFromServer");
                          
                          [self requestData];
                      }
                      else {
                          NSLog(@"myliaoliao notice2ManualRelogin");
                          
                          [AppConstants notice2ManualRelogin];
                      }
                  }];
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

- (void)showNoLiaoLiao {
    _noLiaoLiaoLabel = [[UILabel alloc] init];
    _noLiaoLiaoLabel.text = NSLocalizedStringCN(@"meiyouliaoliao", @"");
    _noLiaoLiaoLabel.font = [UIFont fontWithName:@"Arial" size:18.0];
    
    [self.view addSubview:_noLiaoLiaoLabel];
    [_noLiaoLiaoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
    }];
    
    [ProgressHUD dismiss];
}
- (void)getDataFail {
    [_getDataFailButton removeFromSuperview];
    
    [ProgressHUD showError:NSLocalizedStringCN(@"jiazaishibai", @"")];
    
    if (_isDataShow == NO) {
        _getDataFailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_getDataFailButton setImage:[UIImage imageNamed:@"reload.png"] forState:UIControlStateNormal];
        [_getDataFailButton addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_getDataFailButton];
        
        [_getDataFailButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.centerY.equalTo(self.view);
            make.width.and.height.equalTo(@160);
        }];
    }
}
-(void)reloadData
{
    [_getDataFailButton removeFromSuperview];
    [_tableView removeFromSuperview];
    [self createTableView];
    [self requestData];
    
}
-(void)createTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section],(long)[indexPath row]];//以indexPath来唯一确定cell
    MyLiaoLiaoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //出列可重用的cell
    
    if(cell ==nil){
        
        cell = [[MyLiaoLiaoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
     LiaoLiaoGuangGaoDetailModel * model = _dataSource[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = model;
    return cell;
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
        
        return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/3*2)+40;
    }
    else if(_mArray.count==2)
    {
        return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/2)+40;
    }
    else if (_mArray.count==3)
    {
        return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/3)+40;
    }
    else if (_mArray.count>=4&&_mArray.count<=6)
    {
        return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/3)+(([UIScreen mainScreen].bounds.size.width-60)/3)+5+40;
    }
    else if (_mArray.count==0)
    {
        return 110+contentH+40;
    }
    else
    {
        return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/3)+(([UIScreen mainScreen].bounds.size.width-60)/3)+(([UIScreen mainScreen].bounds.size.width-60)/3)+5+40;
    }
    
}
#pragma mark - 协议方法 别删
- (void)getSelectImage:(NSArray *)imageArr
{
    
    NSLog(@"again?");
    
    _isPush = YES;
    _selectedImages = imageArr;
    
    _localImageViewController.delegate = nil;
}
#pragma mark -tableview delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LiaoLiaoGuangGaoDetailModel * model = _dataSource[indexPath.row];
    LiaoLiaoErJiViewController * some = [[LiaoLiaoErJiViewController alloc]init];
    some.navigationItem.title = NSLocalizedStringCN(@"liaoliaoxiangqing", @"");
    some.hidesBottomBarWhenPushed = YES;
    some.model = model;
    [self.navigationController pushViewController:some animated:YES];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
       LiaoLiaoGuangGaoDetailModel * model   = _dataSource[indexPath.row];
        _liaoliaoId = [NSString stringWithFormat:@"%zd",model.id];
            [self deleteLiaoLiao];
        
        } else if (editingStyle == UITableViewCellEditingStyleInsert) {
            
        }
}
- (void)deleteLiaoLiao {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    //        NSString *urlString = [NSString stringWithFormat:@"%@resource/article/frontpage/slide/list/index.ashx", [AppConstants httpHeader]];
    
    //        NSDictionary *parameters = @{@"page":@"1", @"pageSize":@"10"};
    
    NSString *urlString = [NSString stringWithFormat:@"%@interaction/forum/post/delete/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"AccessToken":[AppConstants userInfo].accessToken, @"PostId":_liaoliaoId};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              //                NSLog(@"success urlString = %@", urlString);
              //                NSLog(@"Success: %@", responseObject);
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  
                  [ProgressHUD showSuccess:NSLocalizedStringCN(@"shanchuliaoliaochenggong", @"")];
                 // [self.navigationController popViewControllerAnimated:YES];
                  [[NSNotificationCenter defaultCenter]postNotificationName:@"deleteLiaoLiao" object:nil];
                 
              }
              else if ([[responseObject objectForKey:@"errno"] isEqualToString:@"4401"]) {
                  [AppConstants relogin:^(BOOL success){
                      if (success) {
                          [self deleteLiaoLiao];
                           [[NSNotificationCenter defaultCenter]postNotificationName:@"deleteLiaoLiao" object:nil];
                      }
                      else {
                          [AppConstants notice2ManualRelogin];
                      }
                  }];
              }
              else if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 0) {
                  [ProgressHUD showSuccess:NSLocalizedStringCN(@"shanchuliaoliaoshibai", @"")];
                  [self.navigationController popViewControllerAnimated:YES];
//                  [_tableView reloadData];
              }
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"false urlString = %@", urlString);
              NSLog(@"Error: %@", error);
              
              [ProgressHUD showError:NSLocalizedStringCN(@"badNetwork", @"")];
          }];
}

@end
