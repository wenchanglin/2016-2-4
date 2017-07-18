//
//  ClassViewController.m
//  歌力思
//
//  Created by likaifeng on 16/7/15.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "ClassViewController.h"
#import "ZhengWenModel.h"
#import "ZhengWenTableViewCell.h"
#import "DetailViewController.h"
@interface ClassViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) NSInteger page;
@property (nonatomic,strong) NSMutableArray *datasource;
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation ClassViewController
- (NSMutableArray *)datasource {
    if (!_datasource) {
        self.datasource = [NSMutableArray arrayWithCapacity:1];
    }
    return _datasource;
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
   self.page = 1;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.naTitle;
     self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"#CCCCCC"],NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    //设置导航栏的返回按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = item;
    //更改导航栏的返回图标"<"的颜色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"#CCCCCC"];
    
    [self requestData];
    [self createTableView];

}

- (void)requestData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@resource/article/detail/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"ArticleId":_articleid, @"page":[NSString stringWithFormat:@"%zd", self.page], @"pageSize":@"20"};
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"6个分类%@",responseObject);
        if ([((NSNumber *)[responseObject objectForKey:@"ok"]) intValue] == 1)
        {
            NSArray *formulas = [responseObject objectForKey:@"formulas"];
            for (NSDictionary *dic in formulas)
            {
                ZhengWenModel *model = [ZhengWenModel modelWith:dic];
                [self.datasource addObject:model];
            }
            
        }
        [_tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)createTableView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height -64 - 49) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView registerClass:[ZhengWenTableViewCell class] forCellReuseIdentifier:@"cell"];
}
#pragma mark - UITableViewDataSource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30+[UIScreen mainScreen].bounds.size.width/800*600)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.width/800*600)];
    [headerView addSubview:imageView];
    NSString *imageString = [NSString stringWithFormat:@"%@%@",[AppConstants httpChinaAndEnglishForHead],self.ImgUrl];
    [imageView setImageWithURL:[NSURL URLWithString:imageString] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(imageView.frame) + 1, self.view.frame.size.width, 30)];
    [headerView addSubview:titleLable];
    titleLable.text = self.zhaiyao;
    titleLable.font = [UIFont systemFontOfSize:13.0f];
    titleLable.numberOfLines = 0;
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30+[UIScreen mainScreen].bounds.size.width/800*600;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return self.datasource.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZhengWenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    ZhengWenModel *model = self.datasource[indexPath.row];
    cell.model = model;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIScreen mainScreen].bounds.size.width / 800 * 533+20;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZhengWenModel * model = self.datasource[indexPath.row];
    DetailViewController * detail = [[DetailViewController alloc]init];
    NSLog(@"%@",model.FormulaID);
    NSLog(@"%@",model.FormulaName);
    detail.shareUrl = model.share_url;
    detail.formulaId = model.FormulaID;
    detail.name = model.FormulaName;
    detail.mainimageView = model.ImgUrl;
    detail.detailStr = model.Introduction;
    detail.videoUrl = model.VideoUrl;
    detail.caiLiaoStr = model.Ingredients;
    detail.steps = model.Steps;
    
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detail animated:YES];
}



//隐藏导航栏navigationbar和底部tabbar
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
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
        _tableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 49 );
    }
}



@end
