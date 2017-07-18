//
//  UseViewController.m
//  Greenis
//
//  Created by greenis on 16/10/26.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "UseViewController.h"

@interface UseViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * _tableView;
    NSArray * _dataArray;
    CGSize titleSize ;
}
@end

@implementation UseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor grayColor];
    _dataArray  = @[@"1.打粉",@"打粉的话需要您将食材切片或者是切小处理,然后将食材烘干或者是烤熟,减少食材水分.如果不够细腻的话可以用磨粉键多打几次,或者是选择手动设置时间,将速度调高,时间增加.",@"2.冰块",@"使用空心冰块,然后加入牛奶,蜂蜜等润滑剂.",@"3.果汁",@"果汁需要您加水或者冰块,然后使用果蔬键运行至结束.如果是软性的水果,比如香蕉草莓等,可以选用冷饮键运行或者在果蔬键运行到一分钟可以按停止键.",@"4.豆浆",@"豆子需要提前煮熟,一次性可以多煮一些,然后放入冰箱中,需要用时取一点即可,最好使用热水大,水和豆子及其他食材放入料理杯中之后,容量大概在800ml到1000ml,效果比较好.",@"5.鱼汤",@"选择刺少的鱼,同时将鱼煮熟,用热水打制效果更好,如果是制作鱼丸,需要选择刺少的鱼类,保证鱼量没过刀头.",@"6.绿豆沙",@"绿豆泡好煮熟,沥干水分,倒入料理机中,绿豆的量要没过刀头到杯子的三分之一多一点,需要借助搅拌棒,一直搅拌.",@"7.酱料",@"比如制作芝麻酱,需要您将花生和芝麻烤熟,加入适量盐,糖以及适量的橄榄油,橄榄油需要分次加入,选择酱料键运行至结束,边制作边用搅拌棒快速搅拌."];
    [self createTV];
    
}
-(void)createTV
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, UIScreenWidth , UIScreenHeight-80) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource =self;
    [self.view addSubview:_tableView];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        titleSize = [_dataArray[indexPath.section * 2 + 1]  boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size ;
        
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = _dataArray[indexPath.section * 2 + 1];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.selectionStyle =  UITableViewCellSelectionStyleNone;
    cell.textLabel.numberOfLines = 0;
    
    
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _dataArray[section*2];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    if (indexPath.section==1) {
        return titleSize.height+10;
    }
    return titleSize.height + 40;
}
@end
