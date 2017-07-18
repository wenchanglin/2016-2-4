//
//  LiaoLiaoTouXiangViewController.m
//  歌力思
//
//  Created by likaifeng on 16/8/19.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "LiaoLiaoTouXiangViewController.h"
#import "LiaoLiaoTableViewCell.h"
#import "LiaoLiaoTouXiangTableViewCell.h"
#import "LiaoLiaoTouXiangTableViewCell.h"
#import "LiaoLiaoTX2TableViewCell.h"
#import "ChatErJiViewController.h"
@interface LiaoLiaoTouXiangViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation LiaoLiaoTouXiangViewController
{
    UITableView *_tableView;
    NSMutableArray *_dataSource;
    NSMutableArray *_mArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.name;
    _dataSource = [NSMutableArray array];
   
    [self requestData];
}
- (void)requestData  {
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    NSString *urlString = [NSString stringWithFormat:@"%@interaction/forum/post/list/byuserid/index.ashx/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"AccessToken":[AppConstants userInfo].accessToken,@"UserId":[NSString stringWithFormat:@"%zd",self.userId], @"page":@"1", @"pageSize":@"20"};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"success 我的头像 = %@", urlString);
              NSLog(@"Success: 我的头像1111%@", responseObject);
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                 [_dataSource removeAllObjects];
                  NSArray *posts = [responseObject objectForKey:@"posts"];
                  
                      for (NSDictionary * dic in posts)
                      {
                          LiaoLiaoGuangGaoDetailModel * model = [LiaoLiaoGuangGaoDetailModel modelWith:dic];
                          [_dataSource addObject:model];
                      }
                  
                  
                 [self createTableview];
              }
              else if ([[responseObject objectForKey:@"errno"] isEqualToString:@"4401"]) {
                  NSLog(@"myliaoliao 4401");
                  [AppConstants relogin:^(BOOL success) {
                      if (success) {
                          [self requestData];
                      }
                      else
                      {
                          [AppConstants notice2ManualRelogin];
                      }
                      
                  }];
              }
              else if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 0) {
                  NSLog(@"获取列表失败 %@", urlString);
                  
                  
              }
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"false urlString = %@", urlString);
              NSLog(@"Error: %@", error);
              
             
          }];}
- (void)createTableview {
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64) style:UITableViewStylePlain];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else{
        return _dataSource.count ;
    }
}
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
//    LiaoLiaoTouXiangTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
//    LiaoLiaoGuangGaoDetailModel *mod = _model;
//    cell.model = mod;
//    return cell;
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section],(long)[indexPath row]];//以indexPath来唯一确定cell
        LiaoLiaoTouXiangTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //出列可重用的cell
        
        if(cell ==nil){
            cell = [[LiaoLiaoTouXiangTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        LiaoLiaoGuangGaoDetailModel * model = _dataSource[indexPath.row];
        cell.model = model;
        return cell;
    } else {
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section],(long)[indexPath row]];//以indexPath来唯一确定cell
        LiaoLiaoTX2TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //出列可重用的cell
        
        if(cell ==nil){
            cell = [[LiaoLiaoTX2TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
               if([self.headPic hasPrefix:@"http"])
        {
            
            [cell.headImages sd_setImageWithURL:[NSURL URLWithString:self.headPic] placeholderImage:[UIImage imageNamed:@"headplace"]];
        }
        else
        {
            NSString * str0 = [NSString stringWithFormat:@"%@%@",[AppConstants httpChinaAndEnglishForHead],self.headPic];
            [cell.headImages sd_setImageWithURL:[NSURL URLWithString:str0] placeholderImage:[UIImage imageNamed:@"headplace"]];
        }
        cell.Btitle.text = self.name;
        cell.Btitle.textAlignment = NSTextAlignmentCenter;
        return cell;

    }
} 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
         _mArray =[NSMutableArray array];
        LiaoLiaoGuangGaoDetailModel * model = _dataSource[indexPath.row];
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
            //        +40 + 50 110+
            return contentH+(([UIScreen mainScreen].bounds.size.width-60)/3*2) +40   +110 ;
        }
        else if(_mArray.count==2)
        {
            return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/2)+40 + 20;
        }
        else if (_mArray.count==3)
        {
            return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/3)+40;
        }
        else if (_mArray.count>=4&&_mArray.count<=6)
        {
            return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/3)+(([UIScreen mainScreen].bounds.size.width-60)/3)+5+40;
        }
        else if (_mArray.count==0)
        {
//            110+contentH+
            NSLog(@"contentH %f",contentH);
            return 110+contentH+40;
        }
        else
        {
            return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/3)+(([UIScreen mainScreen].bounds.size.width-60)/3)+(([UIScreen mainScreen].bounds.size.width-60)/3)+40+40;
        }
    }
    else
    {
        return 110;
    }
   
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     ChatErJiViewController * GuangGao = [[ChatErJiViewController alloc]init];
    LiaoLiaoGuangGaoDetailModel * model = _dataSource[indexPath.row];
     GuangGao.navigationItem.title = NSLocalizedStringCN(@"liaoliao", @"");
    GuangGao.model = model; 
    [self.navigationController pushViewController:GuangGao animated:YES];
}
@end
