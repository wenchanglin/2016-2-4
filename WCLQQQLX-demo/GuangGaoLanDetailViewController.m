
//
//  LiaoLiaoDetailViewController.m
//  歌力思
//
//  Created by greenis on 16/8/3.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "GuangGaoLanDetailViewController.h"
#import "LiaoLiaoGuangGaoDetailModel.h"
#import "LocalImageViewController.h"
#import "PostViewController.h"
#import "LiaoLiaoTableViewCell.h"
#import "ChatErJiViewController.h"
#import "LiaoLiaoTouXiangViewController.h"
#import "Masonry.h"
@interface GuangGaoLanDetailViewController ()<UITableViewDelegate,UITableViewDataSource,LocalImageViewControllerDelegate>
@property (strong, nonatomic) UIButton                          *getDataFailButton;
@property (nonatomic) BOOL                                      isDataShow;
@property (nonatomic) BOOL                                      isAllowPush;
@property (strong, nonatomic) LocalImageViewController          *localImageViewController;
@property (strong, nonatomic) NSArray                           *selectedImages;
@property (nonatomic) BOOL                                      isPush;



@end

@implementation GuangGaoLanDetailViewController
{
    UITableView * _tableView;
    NSMutableArray * _dataSource;
    NSMutableArray * _mArray;

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [ProgressHUD dismiss];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAllData) name:@"sendPostSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadaData) name:@"deleteLiaoLiao" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadaData) name:@"pinglunchenggong" object:nil];
    
    [_tableView reloadData];
    
}
- (void)viewDidAppear:(BOOL)animated {
    if (_isPush && _isAllowPush) {
        _isAllowPush = NO;
        _isPush = NO;
        PostViewController *postViewController = [[PostViewController alloc] initWithImages:_selectedImages andPrefix:[NSString stringWithFormat:@"#%@#", self.name] andID:self.picId];
        postViewController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:postViewController animated:YES];
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _dataSource = [NSMutableArray array];
    _mArray = [NSMutableArray array];
    [self initNavigationBar];
    [self createTableView];
    [self requestData];
    
}


-(void)reloadaData
{
    
    [_tableView removeFromSuperview];
    [_getDataFailButton removeFromSuperview];
    [self createTableView];
    [self requestData];
}
- (void)initNavigationBar {
    self.navigationItem.title = [NSString stringWithFormat:@"%@-%@", NSLocalizedStringCN(@"huati", @""), self.name];
    
    UIImage *postButtonImage = [UIImage imageNamed:@"edit"];
    postButtonImage = [postButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:postButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(postButtonPress)];
}

- (void)postButtonPress {
    
    if ([[AppConstants userInfo].accessToken isEqualToString:@""]) {
        
        [ProgressHUD showError:NSLocalizedStringCN(@"dengluzailiaoliao", @"")];
        
        return;
    }
    
    _isAllowPush = YES;
    
    _localImageViewController = [[LocalImageViewController alloc] init];
    _localImageViewController.maxPhotoNumber = 9;
    _localImageViewController.delegate = self;
    _localImageViewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:_localImageViewController animated:YES];
    
}
- (void)setupPickerView {
   
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
    
    NSString *urlString = [NSString stringWithFormat:@"%@interaction/forum/post/list/bytopicid/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"AccessToken":[AppConstants userInfo].accessToken, @"TopicId":self.picId, @"page":@"1", @"pageSize":@"50"};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
             // NSLog(@"success 公告栏详情urlString = %@", urlString);
            //NSLog(@"Success 公告栏详情: %@", responseObject);
             
              if  ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1)
              {
                  [_dataSource removeAllObjects];
                  NSArray *posts = [responseObject objectForKey:@"posts"];
                  
                  for (NSDictionary * dic in posts)
                  {
                      LiaoLiaoGuangGaoDetailModel * model = [LiaoLiaoGuangGaoDetailModel modelWith:dic];
                      [_dataSource addObject:model];
                  }
                  [_tableView reloadData];
                  [ProgressHUD dismiss];
              }
              else if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 0)
              {
                  NSLog(@"获取列表失败 %@", urlString);
                  [self getDataFail];
              }
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"false urlString = %@", urlString);
              NSLog(@"Error: %@", error);
              [self getDataFail];
          }];
    
}
#pragma mark -创建表格
-(void)createTableView
{
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-49-64) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource =self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
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
//加载所有数据
- (void)reloadAllData {
    [_tableView removeFromSuperview];
    [_getDataFailButton removeFromSuperview];
    [self createTableView];
    [self requestData];
}
#pragma mark - 表格协议
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
    LiaoLiaoGuangGaoDetailModel *mod = _dataSource[indexPath.row];
    cell.model = mod;
    cell.headImageView.tag = 500 + indexPath.row;
    [cell.headImageView addTarget:self action:@selector(handleHeadImageView:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (void)handleHeadImageView:(UIButton *)headImageView  {
    LiaoLiaoTouXiangViewController *touXiang = [[LiaoLiaoTouXiangViewController alloc] init];
    LiaoLiaoGuangGaoDetailModel * model = _dataSource[ headImageView.tag - 500];
    touXiang.userId =model.userId;
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatErJiViewController * chaterji = [[ChatErJiViewController alloc]init];
    LiaoLiaoGuangGaoDetailModel * model = _dataSource[indexPath.row];
    chaterji.model =model;
    chaterji.navigationItem.title = NSLocalizedStringCN(@"liaoliaoxiangqing", @"");
    chaterji.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chaterji animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
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
        return 110+contentH+60;
    }
    else
    {
        return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/3)+(([UIScreen mainScreen].bounds.size.width-60)/3)+(([UIScreen mainScreen].bounds.size.width-60)/3)+5+60;
    }
}
#pragma mark - LocalImageViewControllerDelegate delegate
- (void)getSelectImage:(NSArray *)imageArr
{
    NSLog(@"again?");
    
    _isPush = YES;
    _selectedImages = imageArr;
    
    _localImageViewController.delegate = nil;
}
@end
