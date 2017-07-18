//
//  AllVideoViewController.m
//  歌力思
//
//  Created by wen on 16/7/18.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "AllVideoViewController.h"
#import "VideoCollectionViewCell.h"
#import "HeaderCollectionReusableView.h"
#import "FooterCollectionReusableView.h"

@interface AllVideoViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic)BOOL isDataShow;
@property(nonatomic,strong)UIButton * getDataFailButton;
@end

@implementation AllVideoViewController
{
    UICollectionView * _collectionView;//集合视图
    NSMutableArray * _oneDataSource;//装第1个数据
    NSInteger  _page;//
    NSMutableArray * _twoDataSource;//装第2个数据
    NSMutableArray * _paths;//装video的URL
    NSMutableArray * _videoName;//装video的名字
    NSMutableArray *_videoList;//视频列表
    NSMutableArray * _twoVideoName;//装第二个分组视频的名字
    NSMutableArray * _twoVideoList;//装第二个分组视频的列表
    NSMutableArray * _twoPaths;//装第二个分组视频的路径
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _oneDataSource = [NSMutableArray array];
    _twoDataSource = [NSMutableArray array];
    _paths = [NSMutableArray array];
    _videoName = [NSMutableArray array];
    _videoList  = [NSMutableArray array];
    _twoPaths = [NSMutableArray array];
    _twoVideoList = [NSMutableArray array];
    _twoVideoName  = [NSMutableArray array];
    _page = 1;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedStringCN(@"shipinzhuanqu", @"");
    [self createOneData];
    [self createTwoData];
    
}
//请求第一个正文视频资源
-(void)createOneData
{
    [ProgressHUD show:NSLocalizedStringCN(@"loading", @"")];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@resource/formula/frontpage/list/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"page":@"1", @"pageSize":@"100"};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"success zhengwen urlString = %@", urlString);
              NSLog(@"Success: %@", responseObject);
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  [_oneDataSource removeAllObjects];
                  [_oneDataSource removeAllObjects];
                  [_paths removeAllObjects];
                  [_videoName removeAllObjects];
                  NSArray *articles = [responseObject objectForKey:@"formulas"];
                  for (NSDictionary * dict in articles) {
                      ZhengWenModel * model = [ZhengWenModel modelWith:dict];
                      [_oneDataSource addObject:model];
                      
                      
                      NSString * videoUrlStr = [NSString stringWithFormat:@"%@%@",[AppConstants httpVideoHeader],model.VideoUrl];
                      [_paths addObject:videoUrlStr];
                      NSString * videoNameStr = [NSString stringWithFormat:@"%@",model.FormulaName];
                      [_videoName addObject:videoNameStr];
                      
                  }
                  
                  [self createCollectionView];
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
        _getDataFailButton.frame = CGRectMake((self.view.frame.size.width-60)/2, (self.view.frame.size.height-60)/2, 60, 60);
        [self.view addSubview:_getDataFailButton];
        
    }
}

-(void)reloadAllData
{
    NSLog(@"加载失败");
    [_getDataFailButton removeFromSuperview];
    [_collectionView removeFromSuperview];
    [self createCollectionView];
    [self createOneData];
    [self createTwoData];
}
//请求第二个广告栏视频资源
-(void)createTwoData
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@resource/article/detail/index.ashx", [AppConstants httpHeader]];
    
    for (NSString * picId in _pictureIdArray) {
        NSDictionary * parameters = @{@"ArticleId":picId, @"page":[NSString stringWithFormat:@"%zd", _page], @"pageSize":@"100"};
        [manager POST:urlString parameters:parameters
              success:^(AFHTTPRequestOperation *operation,id responseObject) {
                  NSLog(@"success 广告栏详情视频资源urlString = %@", urlString);
                  NSLog(@"Success:广告栏详情视频 %@", responseObject);
                  NSLog(@"当前页 %zd",_page);
                  NSLog(@"%@",_pictureIdArray);
                  if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                      
                      [_twoPaths removeAllObjects];
                      [_twoDataSource removeAllObjects];
                      [_twoVideoName removeAllObjects];
                      NSArray *articles = [responseObject objectForKey:@"formulas"];
                      for (NSDictionary * dic in articles) {
                          ZhengWenModel * model = [ZhengWenModel modelWith:dic];
                          [_twoDataSource addObject:model];
                          NSString * videoUrlStr = [NSString stringWithFormat:@"%@%@",[AppConstants httpVideoHeader],model.VideoUrl];
                          [_twoPaths addObject:videoUrlStr];
                          NSString * videoNameStr = [NSString stringWithFormat:@"%@",model.FormulaName];
                          [_twoVideoName addObject:videoNameStr];
                          
                      }
                      
                      [self createCollectionView];
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
    
    
    
}


-(void)createCollectionView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //更改item的大小
    layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / 2 - 10, ([UIScreen mainScreen].bounds.size.width / 2 ) / 800 * 533 + 35);
    
    layout.minimumInteritemSpacing = 5;
    
    //设置layout的代理
    //    layout.
    UICollectionView *collectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-49-64) collectionViewLayout:layout];
    collectionV.backgroundColor = [UIColor colorWithHexString:@"#1e1e1e"];
    //将其添加到根视图上
    [self.view addSubview:collectionV];
    //设置UICollectionView的代理
    collectionV.delegate = self;
    collectionV.dataSource = self;
//    //设置header和footer的大小
    layout.headerReferenceSize = CGSizeMake(0, 10);
//    layout.footerReferenceSize = CGSizeMake(0, 30);
    //注册cell
    [collectionV registerClass:[VideoCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
//    //注册header
//    [collectionV registerClass:[HeaderCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
//    //注册footer
//    [collectionV registerClass:[FooterCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section==1) {
        return _twoDataSource.count;
    }
    return  _oneDataSource.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==1) {
        //第二个cell数据
        VideoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        ZhengWenModel * model = _twoDataSource[indexPath.row];
        cell.model= model;
        cell.backgroundColor = [UIColor colorWithHexString:@"#2b2b2b"];
        return cell;
    }
    else
    {
        //第一个cell数据
        VideoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        ZhengWenModel * model = _oneDataSource[indexPath.row];
        cell.model = model;
        cell.backgroundColor = [UIColor colorWithHexString:@"#2b2b2b"];
        return cell;
    }
}

//-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
//        HeaderCollectionReusableView * header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
//        header.backgroundColor =[UIColor clearColor];
//        if (indexPath.section==1) {
//            header.headerLabel.text = NSLocalizedStringCN(@"", @"");
//        }
//        else
//        {
//            header.headerLabel.text = NSLocalizedStringCN(@"", @"");
//        }
//        return header;
//    }
//    else
//    {
//        FooterCollectionReusableView * footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
//        footer.backgroundColor = [UIColor clearColor];
//        return footer;
//    }
//}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        
        if (![_paths[indexPath.row] hasSuffix:@"mp4"])
        {
            [ProgressHUD showError:NSLocalizedStringCN(@"novideo", @"")];
            return;
        }
        else
        {
            SSVideoModel *SSmodel = [[SSVideoModel alloc]initWithName:_videoName[indexPath.row] path:_paths[indexPath.row]];
            [_videoList addObject:SSmodel];
            SSVideoPlayController *playController = [[SSVideoPlayController alloc]initWithVideoList:_videoList];
            SSVideoPlayContainer *playContainer = [[SSVideoPlayContainer alloc]initWithRootViewController:playController];
            [self presentViewController:playContainer animated:NO completion:nil];
            [_videoList removeAllObjects];
        }
    }
    else
    {
        
        if (![_twoPaths[indexPath.row] hasSuffix:@"mp4"]) {
            [ProgressHUD showError:NSLocalizedStringCN(@"novideo", @"")];
            return;
        }
        else
        {
            SSVideoModel *SSmodel = [[SSVideoModel alloc]initWithName:_twoVideoName[indexPath.row] path:_twoPaths[indexPath.row]];
            [_twoVideoList addObject:SSmodel];
            SSVideoPlayController *playController = [[SSVideoPlayController alloc]initWithVideoList:_twoVideoList];
            SSVideoPlayContainer *playContainer = [[SSVideoPlayContainer alloc]initWithRootViewController:playController];
            [self presentViewController:playContainer animated:NO completion:nil];
            [_twoVideoList removeAllObjects];
        }
    }
    
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(5,7, 5, 7);
}
@end
