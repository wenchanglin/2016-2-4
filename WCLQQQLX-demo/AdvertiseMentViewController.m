//
//  AdvertiseMentViewController.m
//  歌力思
//
//  Created by wen on 16/7/12.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "AdvertiseMentViewController.h"
#import "ZhengWenModel.h"
#import "ZhengWenModel.h"
#import "ZhengWenTableViewCell.h"
#import "DetailViewController.h"
#import "VideoCollectionViewCell.h"
#import "ADvertiseCollectionReusableView.h"
@interface AdvertiseMentViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic)BOOL isDataShow;
@property(nonatomic)NSInteger  currentPage;
@property (nonatomic,strong) UIButton * getDataFailButton;
@property (nonatomic,strong) UICollectionView *collectionV;
@property (nonatomic) int formulas_total;

@end

@implementation AdvertiseMentViewController
{
    NSMutableArray * _dataSource;
    UITableView * _tableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _dataSource =[NSMutableArray array];
    _isDataShow = NO;
    _currentPage = 10;
    self.title = self.name;
    [self requestData];
     [self createCollectionView];
    //下拉刷新
    [self form];
    //上拉加载
    [self updown];

}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"GuangGaoVC"];
    // [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    [_messageInputView removeFromSuperview];
    //    [_faceView removeFromSuperview];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"GuangGaoVC"];
}
//下拉刷新
- (void)form {
    __weak AdvertiseMentViewController *weakSelf = self;
    self.collectionV.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _currentPage = 10;
        [weakSelf getDataFromServerWithPage:_currentPage];
    }];
}
//上拉加载
- (void)updown {
    __weak AdvertiseMentViewController *weakSelf = self;
    self.collectionV.mj_footer = [MJRefreshBackNormalFooter  footerWithRefreshingBlock:^{
        _currentPage += 10;
        if (_currentPage>=self.formulas_total) {
             [self.collectionV.mj_footer endRefreshing];
            [ProgressHUD showError:NSLocalizedStringCN(@"nomorepost", @"")];
            
            return ;
        }
       else
        {
        [weakSelf getDataFromServerWithPage:_currentPage];
        }
    }];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([AppConstants downloadButtonPress2Pop]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}
-(void)requestData
{
    [_getDataFailButton removeFromSuperview];
    [self getDataFromServerWithPage:_currentPage];
}
- (void)getDataFromServerWithPage:(NSInteger)page {
   [ProgressHUD show:NSLocalizedStringCN(@"loading", @"")];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@resource/article/detail/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"ArticleId":self.pictureId, @"page":@"1", @"pageSize":[NSString stringWithFormat:@"%zd",page]};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"success 广告栏详情urlString = %@", urlString);
              NSLog(@"Success:广告栏详情 %@", responseObject);
              NSLog(@"当前页 %ld",(long)page);
              NSLog(@"%@",self.pictureId);
              NSLog(@"%@",_dataSource);
              [_collectionV.mj_header endRefreshing];
              [_collectionV.mj_footer endRefreshing];
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  [_dataSource removeAllObjects];
                  self.formulas_total =[responseObject[@"total"]intValue];
                  NSArray *articles = [responseObject objectForKey:@"formulas"];
                  for (NSDictionary * dic in articles) {
                      ZhengWenModel * model = [ZhengWenModel modelWith:dic];
                      [_dataSource addObject:model];
                  }
                  
                  [self.collectionV reloadData];
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
    
   [ProgressHUD showError:NSLocalizedStringCN(@"jiazaishibai", @"")];
    [_getDataFailButton removeFromSuperview];
    if (_isDataShow == NO) {
        _getDataFailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_getDataFailButton setImage:[UIImage imageNamed:@"reload.png"] forState:UIControlStateNormal];
        [_getDataFailButton addTarget:self action:@selector(requestData) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_getDataFailButton];
        
        _getDataFailButton.frame  = CGRectMake(([UIScreen mainScreen].bounds.size.width-160)/2, ([UIScreen mainScreen].bounds.size.height-160)/2, 160, 160);
    }
}


-(void)createCollectionView
{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //更改item的大小
    layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / 2 - 10, ([UIScreen mainScreen].bounds.size.width / 2 ) / 800 * 533 + 35);
    
    layout.minimumInteritemSpacing = 5;
    
    //设置layout的代理
    //    layout.
    self.collectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-49-64) collectionViewLayout:layout];
    self.collectionV.backgroundColor = [UIColor colorWithHexString:@"#1e1e1e"];
    //将其添加到根视图上
    [self.view addSubview:self.collectionV];
    //设置UICollectionView的代理
    self.collectionV.delegate = self;
    self.collectionV.dataSource = self;
    //    //设置header和footer的大小
    UIFont *fnt = [UIFont systemFontOfSize:15];
    // iOS7中用以下方法替代过时的iOS6中的sizeWithFont:constrainedToSize:lineBreakMode:方法
    _tmpRect = [self.picZhaiYao boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt,NSFontAttributeName, nil] context:nil];
    //    header的高度
    layout.headerReferenceSize = CGSizeMake(0, _tmpRect.size.height+[UIScreen mainScreen].bounds.size.width/800*533+20);
    //    layout.footerReferenceSize = CGSizeMake(0, 30);
    //注册cell
    [self.collectionV registerClass:[VideoCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    //    //注册header
    [self.collectionV registerClass:[ADvertiseCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headered"];
    //    //注册footer
    //    [collectionV registerClass:[FooterCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VideoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    ZhengWenModel * model = _dataSource[indexPath.row];
    cell.model = model;
    cell.backgroundColor = [UIColor colorWithHexString:@"#2b2b2b"];
    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        
        
        ADvertiseCollectionReusableView *headerView  = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headered" forIndexPath:indexPath];
        NSString * imageStr = [NSString stringWithFormat:@"%@",self.picture];
        headerView.headImage.frame =CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width / 800*533);
        [headerView.headImage setImageWithURL:[NSURL URLWithString:imageStr] placeholder:[UIImage imageNamed:@"placeholder.jpg"]];
        headerView.titles.frame = CGRectMake(10, CGRectGetMaxY(headerView.headImage.frame) + 10, [UIScreen mainScreen].bounds.size.width - 20, _tmpRect.size.height);
        headerView.titles.textAlignment = NSTextAlignmentCenter;
        headerView.titles.text = self.picZhaiYao;
        headerView.titles.numberOfLines =0;
        headerView.titles.font = [UIFont systemFontOfSize:12.0];
        headerView.titles.textColor = [UIColor colorWithHexString:@"#808080"];
        reusableview = headerView;
    }
    return reusableview;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    ZhengWenModel * model = _dataSource [indexPath.row];
    DetailViewController * detail = [[DetailViewController alloc]init];
    
    detail.formulaId = model.FormulaID;
    detail.name = model.FormulaName;
    detail.mainimageView = model.ImgUrl;
    detail.detailStr = model.Introduction;
    detail.videoUrl = model.VideoUrl;
    detail.caiLiaoStr = model.Ingredients;
    detail.steps = model.Steps;
    if (![model.share_url isEqualToString:@""]) {
        detail.shareUrl = model.share_url;
    } else {
        model.share_url = @"http://greenishome.com/";
        detail.shareUrl = model.share_url;
    }
    //下标
    detail.index = indexPath.row;
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detail animated:YES];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(5,7, 5, 7);
}

@end
