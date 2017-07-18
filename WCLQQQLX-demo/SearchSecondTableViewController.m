//
//  SearchSecondTableViewController.m
//  歌力思
//
//  Created by likaifeng on 16/9/2.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "SearchSecondTableViewController.h"
#import "SearchViewController.h"
#import "LiuLanJiLuDetailViewController.h"
#import "ZhengWenModel.h"
#import "ZhengWenTableViewCell.h"
#import "DetailTableViewCell.h"
#import "SearchTableViewCell.h"
#import "SearchSecondTableViewController.h"
#import "DetailViewController.h"
#import "VideoCollectionViewCell.h"


@interface SearchSecondTableViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UISearchBarDelegate>

#define Start_X 0          // 第一个按钮的X坐标
#define Start_Y 5         // 第一个按钮的Y坐标
#define Width_Space 0        // 2个按钮之间的横间距
#define Height_Space 0      // 竖间距
#define Button_Height 30.0f    // 高
#define Button_Width [UIScreen mainScreen].bounds.size.width / 3     // 宽 110
@property (nonatomic) BOOL     isSearching;
@property(nonatomic,strong)UISearchBar * searchBar;
@property(nonatomic,strong)NSArray * historyArray;//搜索历史
@property (nonatomic,strong) UICollectionView *collectionV;
@property (nonatomic) int total;

@end

@implementation SearchSecondTableViewController

{
    UITableView * _tableView;
    NSMutableArray * _searchArray;
    NSMutableArray * _dataSource;
    NSString * _titleImgStr;
    NSString * _nameStr;
    NSArray * history;
    NSString * _searchStr;
    NSMutableArray * _picSource;
    NSMutableArray * _picArray;
    NSInteger _index;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [ProgressHUD dismiss];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([AppConstants downloadButtonPress2Pop]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor  =[UIColor whiteColor];
    _isSearching = NO;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _picArray = [NSMutableArray array];
    _searchArray = [NSMutableArray array];
    _dataSource =[NSMutableArray array];
    _picSource = [NSMutableArray array];
    [self initSearchBar];
    _index = 20;
    [self createCollectionView];
    UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
    searchField.textColor = [UIColor whiteColor];
    
    if (![self.searchBar.text isEqualToString:@""]) {
        [self requestData:self.searchBar.text];
        [self updown];
    } else {
        [self requestData:_str];
        self.searchBar.text = _str;
        
        //    //上拉加载
        [self updown];
    }
    
}



//上拉加载
- (void)updown {
    __weak SearchSecondTableViewController *weakSelf = self;
    self.collectionV.mj_footer = [MJRefreshBackNormalFooter  footerWithRefreshingBlock:^{
        _index += 10;
        NSLog(@"_index%ld",(long)_index);
        if ([self.searchBar.text isEqualToString:@""]) {
            [ProgressHUD showError:NSLocalizedStringCN(@"nomorepost", @"")];
            
            return ;
        }
        else
        {
            if (_index >= self.total) {
                [self.collectionV.mj_footer endRefreshing];
                [ProgressHUD showError:NSLocalizedStringCN(@"nomorepost", @"")];
                
            }else {
                [weakSelf requestData:self.searchBar.text];
            }
        }
    }];
}


#pragma mark - 获取数据
-(void)requestData:(NSString *)keyword
{
    if (_isSearching) {
        
        return;
    }
    _isSearching = YES;
    [ProgressHUD show:NSLocalizedStringCN(@"searching", @"")];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@resource/formula/keyword/list/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"page":@"1", @"pageSize":[NSString stringWithFormat:@"%ld",(long)_index], @"Keyword":keyword};
    
    [manager POST:urlString parameters:parameters  success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"搜索urlString = %@", urlString);
              NSLog(@"搜索数据: %@", responseObject);
              [self.collectionV.mj_header endRefreshing];
              [self.collectionV.mj_footer endRefreshing];
              //清空数组
              [_dataSource removeAllObjects];
              [_picSource removeAllObjects];
              [_picArray removeAllObjects];
              _isSearching = NO;
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  NSLog(@"搜索成功 %@", responseObject);
                  
                  if ([[responseObject valueForKey:@"total"] intValue] != 0) {
                      self.total = [responseObject[@"total"]intValue];
                      NSArray *formulas = [responseObject objectForKey:@"formulas"];
                      for (NSDictionary * dic in formulas) {
                          ZhengWenModel * model = [ZhengWenModel modelWith:dic];
                          [_picSource addObject:model];
                          [_dataSource addObject:dic[@"FormulaName"]];
                          [_picArray addObject:dic[@"ImgUrl"]];
                      }
                      [self.collectionV reloadData];
                      [ProgressHUD dismiss];
                  }
                  else {
                      [ProgressHUD showError:NSLocalizedStringCN(@"searchNothing", @"")];
                      [self performSelector:@selector(pushSecondController) withObject:nil afterDelay:2.0f];
                  }
                  
              }
              else if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 0) {
                  NSLog(@"搜索失败 %@", urlString);
                  
                  [ProgressHUD showError:NSLocalizedStringCN(@"searchFail", @"")];
                  [self performSelector:@selector(pushSecondController) withObject:nil afterDelay:2.0f];
              }
              
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"false urlString = %@", urlString);
              NSLog(@"Error: %@", error);
              
              _isSearching = NO;
              
              [ProgressHUD showError:NSLocalizedStringCN(@"badNetwork", @"")];
              [self performSelector:@selector(pushSecondController) withObject:nil afterDelay:2.0f];
              
          }];
    
}

-(void)pushSecondController
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
#pragma mark - 初始化搜索框
- (void)initSearchBar {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width-20, 50)];
    self.searchBar.delegate = self;
    self.navigationItem.titleView = _searchBar;
    self.searchBar.placeholder = NSLocalizedStringCN(@"searchPlaceholder", @"");
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:TRUE animated:YES];
    
    UIButton *btn=[searchBar valueForKey:@"_cancelButton"];
    [btn setTitle:NSLocalizedStringCN(@"quxiao", @"") forState:UIControlStateNormal];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    
    return TRUE;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self hideSearchBarKeyboard];
}
- (void)hideSearchBarKeyboard {
    [_searchBar setShowsCancelButton:FALSE animated:YES];
    [_searchBar resignFirstResponder];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    
    [self hideSearchBarKeyboard];
    [self requestData:searchBar.text];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS %@",self.searchBar.text];
    [_searchArray addObjectsFromArray:[_dataSource filteredArrayUsingPredicate:predicate]];
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    self.historyArray = [userDefaultes arrayForKey:@"searchHistory"];
    [_tableView reloadData];
    
    if (![_searchStr isEqualToString:@""]) {
        
        [self SearchText:self.searchBar.text];
        
        
    }
    NSUserDefaults *userDefaultes1 = [NSUserDefaults standardUserDefaults];
    self.historyArray = [userDefaultes1 arrayForKey:@"searchHistory"];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self hideSearchBarKeyboard];
}

#pragma mark - 创建tabbleview
-(void)createCollectionView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //更改item的大小
    layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / 2 - 10, ([UIScreen mainScreen].bounds.size.width / 2 ) / 800 * 533 + 35);
    
    layout.minimumInteritemSpacing = 5;
    
    //设置layout的代理
    //    layout.
    self.collectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64) collectionViewLayout:layout];
    self.collectionV.backgroundColor = [UIColor colorWithHexString:@"#1e1e1e"];
    //将其添加到根视图上
    [self.view addSubview:self.collectionV];
    //设置UICollectionView的代理
    self.collectionV.delegate = self;
    self.collectionV.dataSource = self;
    //    //设置header和footer的大小
    layout.headerReferenceSize = CGSizeMake(0, 10);
    //    layout.footerReferenceSize = CGSizeMake(0, 30);
    //注册cell
    [self.collectionV registerClass:[VideoCollectionViewCell class] forCellWithReuseIdentifier:@"collectioncell"];
    //    //注册header
    //    [collectionV registerClass:[HeaderCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    //    //注册footer
    //    [collectionV registerClass:[FooterCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _picSource.count;//搜索结果
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    //第二个cell数据
    VideoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectioncell" forIndexPath:indexPath];
    ZhengWenModel * model = _picSource[indexPath.row];
    cell.model= model;
    cell.backgroundColor = [UIColor colorWithHexString:@"#2b2b2b"];
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    ZhengWenModel * model = _picSource[indexPath.row];
    NSLog(@"点击的是第二行%ld",(long)indexPath.row);
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
    
    [self.navigationController pushViewController:detail animated:YES];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(5,7, 5,7);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    self.historyArray = [userDefaultes arrayForKey:@"searchHistory"];
    [_tableView reloadData];
}

-(void)SearchText:(NSString *)seaTxt
{
    NSMutableArray *searTXT = [[NSMutableArray alloc] init];
    if (self.historyArray) {
        searTXT = [self.historyArray mutableCopy];
    }
    
    for (NSString * str in searTXT) {
        if ([seaTxt isEqualToString:str]) {
            [searTXT removeObject:seaTxt];
            break;
        }
    }
    [searTXT addObject:seaTxt];
    
    //将上述数据全部存储到NSUserDefaults中
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:searTXT forKey:@"searchHistory"];
    
}
@end
