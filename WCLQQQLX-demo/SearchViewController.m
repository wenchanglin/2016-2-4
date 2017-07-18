#import "DetailViewController.h"

#import "SearchViewController.h"
#import "LiuLanJiLuDetailViewController.h"
#import "ZhengWenModel.h"
#import "ZhengWenTableViewCell.h"
#import "DetailTableViewCell.h"
#import "SearchTableViewCell.h"
#import "SearchSecondTableViewController.h"
#import "SearchHistoryTableViewCell.h"
#define Start_X 0          // 第一个按钮的X坐标
#define Start_Y 5         // 第一个按钮的Y坐标
#define Width_Space 0        // 2个按钮之间的横间距
#define Height_Space 0      // 竖间距
#define Button_Height 30.0f    // 高
#define Button_Width [UIScreen mainScreen].bounds.size.width / 3     // 宽 110
@interface SearchViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) BOOL     isSearching;
@property(nonatomic,strong)UISearchBar * searchBar;
@property(nonatomic,strong)NSArray * historyArray;//搜索历史
@end

@implementation SearchViewController
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
    self.view.backgroundColor  =[UIColor colorWithHexString:@"#1e1e1e"];
    _isSearching = NO;
    _picArray = [NSMutableArray array];
    _searchArray = [NSMutableArray array];
    _dataSource =[NSMutableArray array];
    _picSource = [NSMutableArray array];
    [self initSearchBar];
    _index = 20;
    [self createTableView];
    UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
    searchField.textColor = [UIColor whiteColor];
    //    if ([self.searchBar.text isEqualToString:@""]) {
    //        [_tableView.mj_footer endRefreshing];
    //
    //        return ;
    //    }else {
    //        [self requestData:self.searchBar.text];
    //    }
    //上拉加载
    [self updown];
    
}



//上拉加载
- (void)updown {
    __weak SearchViewController *weakSelf = self;
    _tableView.mj_footer = [MJRefreshBackNormalFooter  footerWithRefreshingBlock:^{
        _index += 10;
        
        if ([self.searchBar.text isEqualToString:@""]) {
            [_tableView.mj_footer endRefreshing];
            
            return ;
        }
        else
        {
            [weakSelf requestData:self.searchBar.text];
            
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
    //   [_picArray removeAllObjects];
    //    [_dataSource removeAllObjects];
    [ProgressHUD show:NSLocalizedStringCN(@"searching", @"")];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@resource/formula/keyword/list/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"page":@"1", @"pageSize":[NSString stringWithFormat:@"%ld",(long)_index], @"Keyword":keyword};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"搜索urlString = %@", urlString);
              NSLog(@"搜索数据: %@", responseObject);
              [_tableView.mj_header endRefreshing];
              [_tableView.mj_footer endRefreshing];
              //清空数组
              _isSearching = NO;
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  if ([[responseObject valueForKey:@"total"] intValue] != 0) {
                      
                      NSArray *formulas = [responseObject objectForKey:@"formulas"];
                      [_dataSource removeAllObjects];
                      [_picSource removeAllObjects];
                      [_picArray removeAllObjects];
                      for (NSDictionary * dic in formulas) {
                          ZhengWenModel * model = [ZhengWenModel modelWith:dic];
                          [_picSource addObject:model];
                          [_dataSource addObject:dic[@"FormulaName"]];
                          [_picArray addObject:dic[@"ImgUrl"]];
                          
                          
                      }
                      [_tableView reloadData];
                      [ProgressHUD dismiss];
                      
                  }
                  else {
                      [ProgressHUD showError:NSLocalizedStringCN(@"searchNothing", @"")];
                      [self performSelector:@selector(pushSecondController) withObject:nil afterDelay:2.0];
                  }
                  
              }
              else if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 0) {
                  NSLog(@"搜索失败 %@", urlString);
                  
                  [ProgressHUD showError:NSLocalizedStringCN(@"searchFail", @"")];
                  [self performSelector:@selector(pushSecondController) withObject:nil afterDelay:2.0];
              }
              
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"false urlString = %@", urlString);
              NSLog(@"Error: %@", error);
              
              _isSearching = NO;
              
              [ProgressHUD showError:NSLocalizedStringCN(@"badNetwork", @"")];
              [self performSelector:@selector(pushSecondController) withObject:nil afterDelay:2.0];
          }];
    
}
- (void)pushSecondController     {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 初始化搜索框
- (void)initSearchBar {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-20, 30)];
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
    
    SearchSecondTableViewController *searchSecond = [[SearchSecondTableViewController alloc] init];
    searchSecond.str = self.searchBar.text;
    searchSecond.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchSecond animated:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self hideSearchBarKeyboard];
}

#pragma mark - 创建tabbleview
-(void)createTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 , [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-49-64) style:UITableViewStylePlain];
    _tableView.backgroundColor= [UIColor colorWithHexString:@"#1e1e1e"];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //    [_tableView registerClass:[SearchTableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableView registerClass:[DetailTableViewCell class] forCellReuseIdentifier:@"cells"];
    [_tableView registerClass:[SearchHistoryTableViewCell class] forCellReuseIdentifier:@"celld"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
    {
        return self.historyArray.count;
    }
    else
    {
        return 1;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"indexcell"];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"indexcell"];
        //cell.backgroundColor = [UIColor grayColor];
    }
    
    if (indexPath.section==0) {
        SearchHistoryTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:@"celld" forIndexPath:indexPath];
        cell.hiss.text = _historyArray[indexPath.row];
        cell.hiss.textColor = [UIColor colorWithHexString:@"#b4b4b4"];
        cell.backgroundColor = [UIColor colorWithHexString:@"#1e1e1e"];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame] ;
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHexString:@"#1e1e1e"];
        return cell;
    }
    else     {
        DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cells" forIndexPath:indexPath];
        if (tableView == _tableView) {
            cell.historyss.text = NSLocalizedStringCN(@"clearSearchHistory", @"");
            cell.backgroundColor = [UIColor colorWithHexString:@"#1e1e1e"];
            if (_historyArray.count == 0) {
                cell.historyss.text = @"";
            }
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame] ;
            cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHexString:@"#1e1e1e"];
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (indexPath.section==0)
    {
        SearchSecondTableViewController *searchSecond = [[SearchSecondTableViewController alloc] init];
        searchSecond.str = _historyArray[indexPath.row];
        searchSecond.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:searchSecond animated:YES];
        
    }
    else
    {
        
        NSUserDefaults * user = [NSUserDefaults standardUserDefaults ];
        [user removeObjectForKey:@"searchHistory"];
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        self.historyArray = [userDefaultes arrayForKey:@"searchHistory"];
        [_tableView reloadData];
    }
    
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 45;
    
    
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
