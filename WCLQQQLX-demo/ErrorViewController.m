//
//  ErrorViewController.m
//  Greenis
//
//  Created by greenis on 16/10/26.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "ErrorViewController.h"

@interface ErrorViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)SSVideoPlayController *playController;
@property(nonatomic,strong)SSVideoPlayContainer *playContainer;
@end

@implementation ErrorViewController
{
    UITableView * _tableView;
    NSArray * _dataArray;
    NSArray * _dataArray2;
    NSArray * _dataArray3;
    CGSize titleSize ;
    NSArray *paths;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"BenDi"];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"BenDi"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _dataArray = @[@"格丽思破壁机安装指导视频"];
    paths = @[ [[NSBundle mainBundle]pathForResource:@"anzhuang.mp4" ofType:nil]];
    [self createTV];
    
}
-(void)createTV
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, UIScreenWidth , UIScreenHeight-80) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource =self;
    [self.view addSubview:_tableView];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section],(long)[indexPath row]];//以indexPath来唯一确定cell
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = _dataArray[0];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.selectionStyle =  UITableViewCellSelectionStyleNone;
    cell.textLabel.numberOfLines = 0;
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return _dataArray[0];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *videoList = [NSMutableArray array];
     [MobClick event:@"bendiVideo" label:[AppConstants userInfo].nickname];
    SSVideoModel *model = [[SSVideoModel alloc]initWithName:_dataArray[0] path:paths[0]];
    [videoList addObject:model];
    _playController = [[SSVideoPlayController alloc]initWithVideoList:videoList];
    _playContainer = [[SSVideoPlayContainer alloc]initWithRootViewController:_playController];
    [self presentViewController:_playContainer animated:NO completion:nil];
    
}
@end
