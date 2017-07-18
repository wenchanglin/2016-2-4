//
//  ReMenTieZiViewController.m
//  Greenis
//
//  Created by greenis on 2017/1/5.
//  Copyright © 2017年 wen. All rights reserved.
//

#import "ReMenTieZiViewController.h"
#import "LiaoLiaoGuangGaoDetailModel.h"
#import "Masonry.h"
#import "LiaoLiaoTableViewCell.h"
#import "LiaoLiaoTouXiangViewController.h"
#import "ChatErJiViewController.h"
@interface ReMenTieZiViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) BOOL   isDataShow;
@property (strong, nonatomic) UIButton *getDataFailButton;

@end

@implementation ReMenTieZiViewController
{
    NSMutableArray * _dataSource;
    UITableView * _tableView;
    NSMutableArray * _mArray;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [ProgressHUD dismiss];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringCN(@"rementiezi", @"");
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _isDataShow = NO;
    _dataSource = [NSMutableArray array];
     [self initStatus];
     [self getDataFromServer];
    [self createTableView];
}
-(void)createTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 29, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
}
-(void)getDataFromServer
{
     [ProgressHUD show:NSLocalizedString(@"loading", @"")];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    NSString *urlString = [NSString stringWithFormat:@"%@interaction/forum/post/list/hot/top10/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"AccessToken":[AppConstants userInfo].accessToken};
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject)
    {
//        NSLog(@"热门帖子 urlString = %@", urlString);
//        NSLog(@"热门帖子Success: %@", responseObject);
        if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
            NSArray *posts = [responseObject objectForKey:@"posts"];
            for (NSDictionary * dict  in posts) {
                LiaoLiaoGuangGaoDetailModel * model = [LiaoLiaoGuangGaoDetailModel modelWith:dict];
                [_dataSource addObject:model];
            }
             [_tableView reloadData];
             [ProgressHUD dismiss];
        }
        else if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 0) {
            NSLog(@"获取列表失败 %@", urlString);
            
            [self getDataFail];
        }

        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
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
        
        [self.view addSubview:_getDataFailButton];
        
        [_getDataFailButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.centerY.equalTo(self.view);
            make.width.and.height.equalTo(@160);
        }];
    }
}
-(void)reloadAllData
{
    [_getDataFailButton removeFromSuperview];
    [_tableView removeFromSuperview];
    [_tableView.mj_header removeFromSuperview];
    [_tableView.mj_footer removeFromSuperview];
    [self createTableView];
  //  _tableView.frame = CGRectMake(0, 29, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self getDataFromServer];
  
}
-(void)initStatus
{
    _isDataShow = NO;
}
#pragma mark - tableview 代理
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
    LiaoLiaoGuangGaoDetailModel * model = _dataSource[indexPath.row];
    cell.model = model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.headImageView.tag = 600+indexPath.row;
    [cell.headImageView addTarget:self action:@selector(touxiangClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    
}
-(void)touxiangClick:(UIButton *)button
{
    LiaoLiaoTouXiangViewController *touXiang = [[LiaoLiaoTouXiangViewController alloc] init];
    LiaoLiaoGuangGaoDetailModel * model = _dataSource[ button.tag - 600];
    touXiang.userId = model.userId;
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
        return 110+contentH+40;
    }
    else
    {
        return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/3)+(([UIScreen mainScreen].bounds.size.width-60)/3)+(([UIScreen mainScreen].bounds.size.width-60)/3)+5+60;
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatErJiViewController * chaterji = [[ChatErJiViewController alloc]init];
    LiaoLiaoGuangGaoDetailModel * model = _dataSource[indexPath.row];
    chaterji.model =model;
    chaterji.navigationItem.title = NSLocalizedStringCN(@"liaoliao", @"");
    chaterji.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chaterji animated:YES];
}

@end
