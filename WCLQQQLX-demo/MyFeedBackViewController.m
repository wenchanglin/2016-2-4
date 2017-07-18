//
//  MyFeedBackViewController.m
//  歌力思
//
//  Created by wen on 16/7/26.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "MyFeedBackViewController.h"

#import "Masonry.h"
#import "AppConstants.h"

#import "AFNetworking.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#define AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES
#import "HomeViewController.h"
#import "FeedbackDataModel.h"
#import "ProgressHUD.h"
#import "FeedbackDetailViewController.h"

@interface MyFeedBackViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView           *tableView;
@property (nonatomic) NSInteger                     currentPage;

@property (strong, nonatomic) NSMutableArray        *feedbackDataDics;
@property (strong, nonatomic) NSMutableArray        *feedbackDatas;

@property (nonatomic) BOOL                          isDataShow;

@property (strong, nonatomic) UIButton              *getDataFailButton;

@property (strong, nonatomic) UILabel               *noFeedbackLabel;

@end

@implementation MyFeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _currentPage = 1;
    _isDataShow = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    _feedbackDatas = [[NSMutableArray alloc] init];
    
    [self getDataFromServerWithPage:_currentPage];
    
}

- (void)getDataFromServerWithPage:(NSInteger)page {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@interaction/feedback/query/bymyselft/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"AccessToken":[AppConstants userInfo].accessToken, @"page":[NSString stringWithFormat:@"%ld", (long)page], @"pageSize":@"10"};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"success urlString = %@", urlString);
              NSLog(@"Success: %@", responseObject);
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  NSArray *feedbacks = [responseObject objectForKey:@"feedbacks"];
                  
                  _feedbackDataDics = [[NSMutableArray alloc] init];
                  [_feedbackDataDics addObjectsFromArray:feedbacks];
                  
                  for (int i = 0; i < _feedbackDataDics.count; i++) {
                      FeedbackDataModel *dataModel = [[FeedbackDataModel alloc] init];
                      dataModel.addtime = [[_feedbackDataDics objectAtIndex:i] objectForKey:@"add_time"];
                      dataModel.content = [[_feedbackDataDics objectAtIndex:i] objectForKey:@"content"];
                      dataModel.Id = [[_feedbackDataDics objectAtIndex:i] objectForKey:@"id"];
                      dataModel.isReply = [[_feedbackDataDics objectAtIndex:i] objectForKey:@"is_reply"];
                      dataModel.replyContent = [[_feedbackDataDics objectAtIndex:i] objectForKey:@"reply_content"];
                      dataModel.replyTime = [[_feedbackDataDics objectAtIndex:i] objectForKey:@"reply_time"];
                      
                      [_feedbackDatas addObject:dataModel];
                  }
                  
                  if ([_feedbackDataDics count] == 0) {
                      if (!_isDataShow) {
                          [self showNoFeedback];
                      }
                      else {
                          if (page != 1) {
                              [ProgressHUD showSuccess:NSLocalizedStringCN(@"nomorefeedback", @"")];
                          }
                      }
                  }
                  else {
                      if (_isDataShow) {
                          [_tableView reloadData];
                      }
                      else {
                          [self initTableView];
                      }
                  }
                  
                  _currentPage++;
                  
              }
              else if ([[responseObject objectForKey:@"errno"] isEqualToString:@"4401"]) {
                  [AppConstants relogin:^(BOOL success){
                      if (success) {
                          [self getDataFromServerWithPage:page];
                      }
                      else {
                          [AppConstants notice2ManualRelogin];
                      }
                  }];
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
//无返回信息
- (void)showNoFeedback {
    _noFeedbackLabel = [[UILabel alloc] init];
    _noFeedbackLabel.text = NSLocalizedStringCN(@"nofeedback", @"");
    _noFeedbackLabel.font = [UIFont fontWithName:@"Arial" size:18.0];
    
    [self.view addSubview:_noFeedbackLabel];
    [_noFeedbackLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
        //        make.width.and.height.equalTo(@160);
    }];
}

- (void)getDataFail {
    [_getDataFailButton removeFromSuperview];
    
    [ProgressHUD showError:NSLocalizedStringCN(@"jiazaishibai", @"")];
    
    if (_isDataShow == NO) {
        _getDataFailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_getDataFailButton setImage:[UIImage imageNamed:@"reload.png"] forState:UIControlStateNormal];
        [_getDataFailButton addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_getDataFailButton];
        
        [_getDataFailButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.centerY.equalTo(self.view);
            make.width.and.height.equalTo(@160);
        }];
    }
}

- (void)reloadData {
    [_getDataFailButton removeFromSuperview];
    
    _currentPage = 1;
    
    [self getDataFromServerWithPage:_currentPage];
}

- (void)initTableView {
    _isDataShow = YES;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64 - 49)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    
//    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
  
//    [self setupFooter];
}

//- (void)setupFooter {
//    SDRefreshFooterView *refreshFooter = [SDRefreshFooterView refreshView];
//    refreshFooter.delegate = self;
//    
//    // 默认是在navigationController环境下，如果不是在此环境下，请设置 refreshHeader.isEffectedByNavigationController = NO;
//    [refreshFooter addToScrollView:_tableView];
//    
//    __weak SDRefreshFooterView *weakRefreshFooter = refreshFooter;
//    refreshFooter.beginRefreshingOperation = ^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            
//            NSLog(@"Refreshing");
//            
//            [NSThread detachNewThreadSelector:@selector(loadMore) toTarget:self withObject:nil];
//            
//            [weakRefreshFooter endRefreshing];
//        });
//    };
//    
//    // 进入页面自动加载一次数据
//    //    [refreshHeader beginRefreshing];
//}

- (void)loadMore {
    [self getDataFromServerWithPage:_currentPage];
}

-(NSInteger)lineInString:(NSString*)str {
    NSUInteger count = 0;
    NSString * string2 = @"\n";
    
    // i=0的时候比较123和123，i=1的时候比较23a和123，i=2的时候比较3as和123...以此类推，直到string1遍历完成
    for (int i = 0; i < str.length - string2.length + 1; i++) {
        
        if ([[str substringWithRange:NSMakeRange(i, string2.length)] isEqualToString:string2]) {
            count++;
        }
    }
    
    return count;
}

#pragma mark - UITableView delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_feedbackDatas count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
//    反馈时间
    UILabel *feedbackTime = [[UILabel alloc] init];
    feedbackTime.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedStringCN(@"feedbacktime", @""), ((FeedbackDataModel*)[_feedbackDatas objectAtIndex:indexPath.row]).addtime];
    feedbackTime.font = [UIFont fontWithName:@"Arial" size:15.0];
//    反馈内容
    UILabel *feedbackContent = [[UILabel alloc] init];
    feedbackContent.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedStringCN(@"feedbackcontent", @""), ((FeedbackDataModel*)[_feedbackDatas objectAtIndex:indexPath.row]).content];
    feedbackContent.numberOfLines = 0;
    feedbackContent.font = [UIFont fontWithName:@"Arial" size:15.0];
//    是否回复
//    UILabel *feedbackIsReply = [[UILabel alloc] init];
//    feedbackIsReply.text = [NSString stringWithFormat:@"%@：", NSLocalizedStringCN(@"isreply", @"")];
//    feedbackIsReply.font = [UIFont fontWithName:@"Arial" size:15.0];
//    回复结果
    UILabel *feedbackResult = [[UILabel alloc] init];
    feedbackResult.font = [UIFont fontWithName:@"Arial" size:15.0];
    UIImageView *isReplay = [[UIImageView alloc] init];
    UIImageView *noReplay = [[UIImageView alloc] init];
    UILabel *look = [[UILabel alloc] init];
    look.font = [UIFont fontWithName:@"Arial" size:17.0];
    if ([((FeedbackDataModel*)[_feedbackDatas objectAtIndex:indexPath.row]).isReply isEqualToString:@"0"]) {
        feedbackResult.text = NSLocalizedStringCN(@"dengdaihuifu", @"");
        noReplay.image = [UIImage imageNamed:@"waitreply"];
//        feedbackResult.textColor = [UIColor redColor];
        
    }
    else {
        feedbackResult.text = NSLocalizedStringCN(@"yihuifu", @"");
        isReplay.image = [UIImage imageNamed:@"hadreply"];
        look.text = NSLocalizedStringCN(@"chakan", @"");
//        feedbackResult.textColor = [AppConstants initUIColorWithInt:0x5E8A41];;
    }
    
    [cell addSubview:feedbackTime];
    [cell addSubview:feedbackContent];
    [cell addSubview:isReplay];
    [cell addSubview:noReplay];
    [cell addSubview:feedbackResult];
    [cell addSubview:look];
    
//    [feedbackTime mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(cell).with.offset(20);
//        make.left.equalTo(cell).with.offset(100);
////        make.right.equalTo(cell).width.offset(70);
//    }];
    feedbackTime.frame = CGRectMake(100, 20, [UIScreen mainScreen].bounds.size.width - 100,20);
    
//    [feedbackContent mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(feedbackTime.mas_bottom).with.offset(5);
//        make.left.equalTo(feedbackTime);
//        make.right.equalTo(cell).with.offset(-100);
//    }];
    feedbackContent.frame = CGRectMake(100, CGRectGetMaxY(feedbackTime.frame) + 5, [UIScreen mainScreen].bounds.size.width - 200, 40);
    look.frame = CGRectMake(CGRectGetMaxX(feedbackContent.frame) + 20, CGRectGetMaxY(feedbackTime.frame) + 5, 40, 20);
    feedbackResult.frame = CGRectMake(20, CGRectGetMaxY(feedbackTime.frame) + 8, 70, 20);
    isReplay.frame = CGRectMake(20, 22, 25, 20);
    noReplay.frame = CGRectMake(20, 22, 25, 20);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CGFloat h = [[NSString stringWithFormat:@"%@：%@", NSLocalizedStringCN(@"feedbackcontent", @""), ((FeedbackDataModel*)[_feedbackDatas objectAtIndex:indexPath.row]).content] boundingRectWithSize:CGSizeMake(([UIScreen mainScreen].bounds.size.width) - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:15.0]} context:nil].size.height;
   
//    h = 85 + h /*+ ([self lineInString:((FeedbackDataModel*)[_feedbackDatas objectAtIndex:indexPath.row]).content] )*/;
    return 85;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([((FeedbackDataModel*)[_feedbackDatas objectAtIndex:indexPath.row]).isReply isEqualToString:@"0"]) {
        [ProgressHUD showSuccess:NSLocalizedStringCN(@"feedbacknotreply", @"")];
        
        return;
    }
    
    FeedbackDetailViewController *fdvc = [[FeedbackDetailViewController alloc] initWithData:[_feedbackDatas objectAtIndex:indexPath.row]];
    
    fdvc.view.backgroundColor = [AppConstants backgroundColor];
    
    fdvc.navigationItem.title = NSLocalizedStringCN(@"feedbackdetail", @"");
    
    [self.navigationController pushViewController:fdvc animated:YES];
    
}

#pragma mark - Refresh delegate
- (void)viewWillRefresh {
    NSLog(@"viewWillRefresh");
    //    [self removeClickedObservers];
    
    _tableView.userInteractionEnabled = NO;
}

- (void)viewDidRefresh {
    NSLog(@"viewDidRefresh");
    
    _tableView.userInteractionEnabled = YES;
}



@end
