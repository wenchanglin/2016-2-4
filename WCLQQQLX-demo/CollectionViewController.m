//
//  CollectionViewController.m
//  歌力思
//
//  Created by likaifeng on 16/7/19.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "CollectionViewController.h"
#import "History.h"
#import "ZhengWenTableViewCell.h"
#import "DetailViewController.h"
@interface CollectionViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSManagedObjectContext *managedContext;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong) History *history ;

@end

@implementation CollectionViewController
{
    UITableView *_tableView;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([AppConstants downloadButtonPress2Pop]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        self.dataArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _dataArray;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self requestCoredate];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.managedContext = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    self.title = NSLocalizedStringCN(@"wodeshoucang", @"");
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self creatTableView];
  
}
- (void)creatTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 49 - 64) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = [UIColor colorWithHexString:@"#1e1e1e"];
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    [_tableView registerClass:[ZhengWenTableViewCell class] forCellReuseIdentifier:@"cell"];
}
- (void)requestCoredate {
    [self.dataArray removeAllObjects];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"History"];
    NSError *error = nil;
    //执行查询请求,获取查询请求的结果
    NSArray *result = [self.managedContext executeFetchRequest:request error:&error];
   
    if (!error) {
        NSLog(@"查询成功");
        [self.dataArray addObjectsFromArray:result];
        [_tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UIScreen mainScreen].bounds.size.width / 800  * 533+35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZhengWenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    History *his = self.dataArray[indexPath.row];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",[AppConstants httpChinaAndEnglishForHead],his.imgUrl];
    [cell.titleImageView setImageWithURL:[NSURL URLWithString:urlString]];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame] ;
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHexString:@"#1e1e1e"];
    cell.backgroundColor = [UIColor colorWithHexString:@"#1e1e1e"];
    cell.name.text = his.formulaName;
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self deleteData];
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
      _history  = self.dataArray[indexPath.row];
        
       // 在临时数据库中删除
        [self.managedContext deleteObject:_history];
        //        执行保存操作
        NSError *error = nil;
        [self.managedContext save:&error];
        if (!error) {
            NSLog(@"删除成功");
            [self.dataArray removeObject:_history];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView reloadData];
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }

    }


}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController *detail = [[DetailViewController alloc] init];
    History *his = self.dataArray[indexPath.row];
    detail.formulaId = his.formulaID;
    detail.name = his.formulaName;
    detail.mainimageView = his.imgUrl;
    detail.detailStr = his.gongxiao;
    detail.videoUrl = his.videoUrl;
    detail.caiLiaoStr = his.cailiao;
    detail.steps = his.steps;
    if (![his.shareurl isEqualToString:@""]) {
        detail.shareUrl = his.shareurl;
    } else {
        his.shareurl = @"http://greenishome.com/";
        detail.shareUrl = his.shareurl;
    }
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detail animated:YES];
}


@end
