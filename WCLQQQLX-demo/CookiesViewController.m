//
//  CookiesViewController.m
//  歌力思
//
//  Created by wen on 16/7/26.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "CookiesViewController.h"
#import "Liulanjilu.h"
#import "ZhengWenTableViewCell.h"
#import "DetailViewController.h"
#import "LiuLanJiLuDetailViewController.h"
#import "HomeViewController.h"

@interface CookiesViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@end
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
@implementation CookiesViewController
{
    Liulanjilu *_liulanjilu;
    NSMutableArray *_datasource;
    NSManagedObjectContext *_managedContext;
    UITableView *_tableView;
    NSString *_ingredients;
    NSString *_videoUrl;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestCoredate];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([AppConstants downloadButtonPress2Pop]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}
- (void)requestCoredate {
    [_datasource removeAllObjects];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Liulanjilu"];
    NSError *error = nil;
    //执行查询请求,获取查询请求的结果
    NSArray *result = [_managedContext executeFetchRequest:request error:&error];
    
    if (!error) {
        NSLog(@"查询成功");
        [_datasource addObjectsFromArray:result];
        if (_datasource.count==0) {
            [self createView];
        }
        [_tableView reloadData];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringCN(@"liulanjilu", @"");
    _datasource = [NSMutableArray array];
   self.view.backgroundColor = [UIColor whiteColor];
    _managedContext = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //设置导航栏的返回按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = item;
    //更改导航栏的返回图标"<"的颜色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"#CCCCCC"];
//    UIBarButtonItem *barBtn1=[[UIBarButtonItem alloc]initWithTitle:@"左边" style:UIBarButtonItemStylePlain target:self action:@selector(handleDeleteButton:)];
    UIImage * image = [[UIImage imageNamed:@"delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *barbtn1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(handleDeleteButton:)];
    
    self.navigationItem.rightBarButtonItem = barbtn1;

    [self createTableView];
    
}
- (void)handleDeleteButton :(UIButton *)deleteButton {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否删除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    }else {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Liulanjilu"];
        NSError *error = nil;
        //执行查询请求,获取查询请求的结果
        NSArray *result = [_managedContext executeFetchRequest:request error:&error];
        for (NSManagedObject *str in result) {
            // 在临时数据库中删除
            [_managedContext deleteObject:str];
            //        执行保存操作
            NSError *error = nil;
            [_managedContext save:&error];
        }
        [_datasource removeAllObjects];
        [_tableView reloadData];
        [self createView];
    }
}
- (void)createView
{
    [_tableView removeFromSuperview];
    UIImageView *imagev= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kWidth)];
        imagev.image = [UIImage imageNamed:@"browse.jpg"];
        [self.view addSubview:imagev];
}
- (void)createTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 64) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = [UIColor colorWithHexString:@"#1e1e1e"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[ZhengWenTableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datasource.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UIScreen mainScreen].bounds.size.width / 800 * 533+35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZhengWenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Liulanjilu *his = _datasource[indexPath.row];
    cell.backgroundColor = [UIColor colorWithHexString:@"#1e1e1e"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",[AppConstants httpChinaAndEnglishForHead],his.imageliulan];
    [cell.titleImageView sd_setImageWithURL:[NSURL URLWithString:urlString]];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame] ;
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHexString:@"#1e1e1e"];
    cell.name.text = his.titleFirst;
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _liulanjilu  = _datasource[indexPath.row];
        
        // 在临时数据库中删除
        [_managedContext deleteObject:_liulanjilu];
        //        执行保存操作
        NSError *error = nil;
        [_managedContext save:&error];
        if (!error) {
            NSLog(@"删除成功");
            [_datasource removeObject:_liulanjilu];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView reloadData];
            if (_datasource.count == 0) {
                [self createView];
            }
            
        } else if (editingStyle == UITableViewCellEditingStyleInsert) {
           
        }
        
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LiuLanJiLuDetailViewController *search = [[LiuLanJiLuDetailViewController alloc] init];
    Liulanjilu *his = _datasource[indexPath.row];
   
    
    search.formulaId = his.idss;
    search.name = his.titleFirst;
    search.mainimageView = his.imageliulan;
    search.caiLiaoStr = his.titleSecond;
    search.videoUrl = his.videoURL;
    search.detailStr = his.gongxiao;
    search.step = his.step;
    if (![his.shareUrl isEqualToString:@""]) {
        search.shareUrl = his.shareUrl;
    } else {
        his.shareUrl = @"http://www.greenishome.com/";
        search.shareUrl = his.shareUrl;
    }
     search.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:search animated:YES];
}






@end
