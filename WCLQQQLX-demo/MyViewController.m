//
//  AboutMeViewController.m
//  WCLQQQLX-demo
//
//  Created by wen on 16/5/24.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "MyViewController.h"
#import "CookiesViewController.h"
#import "MyLiaoLiaoViewController.h"
#import "FeedBackViewController.h"
#import "MyFeedBackViewController.h"
#import "VersionInfoViewController.h"
#import "LoginViewController.h"
#import "PersonMessageViewController.h"
#import "MyMessageTableViewCell.h"
#import "CollectionViewController.h"
#import "ZhengWenModel.h"
#import "Masonry.h"
@interface MyViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic) BOOL  isUserInfoShow;
@end

@implementation MyViewController
{
    
    NSArray *_secondArray;//第二分区数组
    UITableView *_tableView;//表视图
    UIButton * _secondButton;//登录按钮
    UIButton * _headButton;//头部图片
    UILabel * _firstLabel;//您还么有登录
    UIView * _view;//表头视图
    UIButton * _bigButton;//大按钮盖住
    UIButton * _sexBtn;
    UIButton * _myLiaoBtn;
    UIButton * _liuLanBtn;
    UIView * _smallView;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear");
    self.tabBarController.tabBar.hidden = NO;
    if ([AppConstants downloadButtonPress2Pop]) {
        [AppConstants setDownloadButtonPress2Pop:NO];
        NSLog(@"第4页首页");
        ((AppDelegate*)[[UIApplication sharedApplication] delegate]).mainTabBarController.selectedIndex =1;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isUserInfoShow = NO;
     [AppConstants YeMianSetStatus:FourYemian];
      self.view.backgroundColor = [UIColor grayColor];
    self.navigationItem.title = NSLocalizedStringCN(@"wode", @"");
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"#CCCCCC"],NSFontAttributeName : [UIFont boldSystemFontOfSize:16]};
    //设置导航栏的返回按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = item;
    //更改导航栏的返回图标"<"的颜色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"#CCCCCC"];

    _secondArray = @[NSLocalizedStringCN(@"wodeshoucang", @""),NSLocalizedStringCN(@"guanyuwomen", @""),NSLocalizedStringCN(@"yijianfankui", @""),NSLocalizedStringCN(@"wodefankui", @""),NSLocalizedStringCN(@"dafenguli", @""),NSLocalizedStringCN(@"banbenxinxi", @""),NSLocalizedStringCN(@"qinglihuancun", @"")];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self creatTableView];
    [self createHeaderView];
    if ([FileOperator fileExist:[AppConstants localFileUserInfo]]) {
        [self showUserInfo];
        
        _isUserInfoShow = YES;
    }
}
- (void)creatTableView  {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height -75) style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellAccessoryNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[MyMessageTableViewCell class] forCellReuseIdentifier:@"cell"];
}

-(void)createHeaderView
{
    _view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 160)];
    _view.userInteractionEnabled = YES;
    _smallView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 110)];
    _smallView.userInteractionEnabled = YES;
    [_view addSubview:_smallView];
    _tableView.tableHeaderView =_view;
    _view.backgroundColor = [UIColor whiteColor];
    _smallView.backgroundColor = [UIColor colorWithHexString:@"#FFCC33"];
    _headButton = [[UIButton alloc]initWithFrame:CGRectMake(20,15, 80, 80)];
    _headButton.layer.cornerRadius = 40;
    _headButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _headButton.layer.borderWidth = 3;
    _headButton.layer.masksToBounds = YES;
    [_smallView addSubview:_headButton];
    [_headButton setBackgroundImage:[UIImage imageNamed:@"personPic.jpg"] forState:UIControlStateNormal];
    _firstLabel  = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headButton.frame)+10, 30, 220, 16)];
    [_smallView addSubview:_firstLabel];
    _firstLabel.text = NSLocalizedStringCN(@"haimeiyoudenglu", @"");
    _firstLabel.font = [UIFont systemFontOfSize:14.0f];
   // _firstLabel.textAlignment = NSTextAlignmentCenter;
    _firstLabel.textColor = [UIColor whiteColor];
    //马上登陆
    _secondButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headButton.frame)+10, CGRectGetMaxY(_firstLabel.frame), 100, 30)];
    [_smallView addSubview:_secondButton];
    [_secondButton setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    _secondButton.titleLabel.font = [UIFont systemFontOfSize:19];
    [_secondButton setTitle:NSLocalizedStringCN(@"mashangdenglu", @"") forState:UIControlStateNormal];
    _secondButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //_secondButton.backgroundColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [_secondButton addTarget:self action:@selector(denglu:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView * imgView = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-40, _smallView.frame.size.height/2, 20, 20)];
    [_smallView addSubview:imgView];
    imgView.image= [UIImage imageNamed:@"jiantou"];
    
#pragma mark - 我的聊聊图片
    UIImageView * liaoImg = [[UIImageView alloc]init];
    liaoImg.image = [UIImage imageNamed:@"myliaoliao"];
    _myLiaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [_myLiaoBtn setTitle:NSLocalizedStringCN(@"wodeliaoliao", @"") forState:UIControlStateNormal];
    [_myLiaoBtn setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    _myLiaoBtn.titleLabel.font= [UIFont systemFontOfSize:15.0f];
   
    [_myLiaoBtn setImage:[self scaleToSize:liaoImg.image size:CGSizeMake(20, 20)] forState:UIControlStateNormal];
    
    
    [_myLiaoBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    //    UIEdgeInsetsMa
    
    [_myLiaoBtn addTarget:self action:@selector(activityPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [_view addSubview:_myLiaoBtn];
    
    [_myLiaoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(_headButton.mas_bottom).with.offset(30);
        make.height.equalTo(@30);
        make.width.mas_equalTo([AppConstants uiScreenWidth] / 2);
    }];
    //中线
    UIView * zhongxian = [[UIView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, CGRectGetMaxY(_headButton.frame)+30, 2, 25)];
    [_view addSubview:zhongxian];
    zhongxian.backgroundColor =[UIColor colorWithHexString:@"#DFDFDF"];
    
    _liuLanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [_liuLanBtn setTitle:NSLocalizedStringCN(@"liulanjilu", @"") forState:UIControlStateNormal];
    [_liuLanBtn setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    
    UIImage *postButtonImage = [UIImage imageNamed:@"newliulanjilu"];
   
    [_liuLanBtn setImage:[self scaleToSize:postButtonImage size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
    
    
    [_liuLanBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    _liuLanBtn.titleLabel.font= [UIFont systemFontOfSize:15.0f];
    [_liuLanBtn addTarget:self action:@selector(postPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [_view addSubview:_liuLanBtn];
    
    [_liuLanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([AppConstants uiScreenWidth] / 2);
        make.top.equalTo(_headButton.mas_bottom).with.offset(30);
        make.height.equalTo(@30);
        make.right.mas_equalTo(0);
    }];
    //分割线
    UIView * fengeXian = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(zhongxian.frame)+10, [UIScreen mainScreen].bounds.size.width, 1)];
    [_view addSubview:fengeXian];
    fengeXian.backgroundColor = [UIColor colorWithHexString:@"#DFDFDF"];
    
}
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
- (void)activityPressed {
    if ([[AppConstants userInfo].accessToken isEqualToString:@""]||[AppConstants userInfo].accessToken ==nil)
    {
        [ProgressHUD showError:NSLocalizedStringCN(@"dengluzailiaoliao", @"")];
        _secondButton.enabled = NO;
        [self performSelector:@selector(click) withObject:nil afterDelay:3.0f];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserInfo) name:@"LoginSuccess" object:nil];
        return;
    }
    MyLiaoLiaoViewController * myliao = [[MyLiaoLiaoViewController alloc]init];
    myliao.navigationItem.title = NSLocalizedStringCN(@"wodeliaoliao", @"");
    myliao.hidesBottomBarWhenPushed =YES;
    [self.navigationController pushViewController:myliao animated:YES];
}

-(void)click
{
    LoginViewController * login1 = [[LoginViewController alloc]init];
    [self.navigationController pushViewController:login1 animated:YES];
    _secondButton.enabled= YES;
}
- (void)postPressed {
    CookiesViewController * cookies = [[CookiesViewController alloc]init];
    cookies.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cookies animated:YES];
}

-(void)denglu:(UIButton *)button
{
    LoginViewController * login = [[LoginViewController alloc]init];
    [self.navigationController pushViewController:login animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserInfo) name:@"LoginSuccess" object:nil];
}
- (void)showUserInfo {
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginSuccess" object:nil];
    [self hideUnLoginViews];
    
    NSLog(@"我在MyView界面了");
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"我在首页了");
}

-(void)hideUnLoginViews
{
    [_firstLabel removeFromSuperview];
    [_headButton removeFromSuperview];
    [_secondButton removeFromSuperview];
    _headButton.frame = CGRectMake(20,15, 80, 80);
    _headButton.layer.cornerRadius = 40;
    _headButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _headButton.layer.borderWidth = 5;
    _headButton.layer.masksToBounds = YES;
    [_view addSubview:_headButton];
    if ([[AppConstants userInfo].avatarURL hasPrefix:@"http:"]) {
        NSString * string  = [NSString stringWithFormat:@"%@",[AppConstants userInfo].avatarURL];
        
        [_headButton setBackgroundImageWithURL:[NSURL URLWithString:string] forState:UIControlStateNormal options:1];
    }
    else {
        [_headButton setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [AppConstants httpImageHeader], [AppConstants userInfo].avatarURL]] forState:UIControlStateNormal options:1];
    }
    _firstLabel.frame = CGRectMake(CGRectGetMaxX(_headButton.frame)+10, 20, 160, 30);
    [_view addSubview:_firstLabel];
    _firstLabel.font = [UIFont systemFontOfSize:16.0f];
    //_firstLabel.textAlignment = NSTextAlignmentCenter;
    _firstLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    _firstLabel.text = [AppConstants userInfo].nickname;
   // _firstLabel.backgroundColor = [UIColor whiteColor];
    _sexBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headButton.frame)+10, CGRectGetMaxY(_firstLabel.frame)+5, 20, 20)];
    [_view addSubview:_sexBtn];
    
    if ([[AppConstants userInfo].sex isEqualToString:@"男"]) {
        UIImage * image = [[UIImage imageNamed:@"male.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_sexBtn setImage:image forState:UIControlStateNormal];
    }
    else if ([[AppConstants userInfo].sex isEqualToString:@"女"]) {
        [_sexBtn setImage:[UIImage imageNamed:@"female.png"] forState:UIControlStateNormal];
    }
    else {
        [_sexBtn setImage:[UIImage imageNamed:@"male.png"] forState:UIControlStateNormal];
    }
    
    _bigButton = [[UIButton alloc]initWithFrame:_smallView.bounds];
    [_view addSubview:_bigButton];
    [_bigButton addTarget:self action:@selector(enterBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_myLiaoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(_headButton.mas_bottom).with.offset(25);
        make.height.equalTo(@30);
        make.width.mas_equalTo([AppConstants uiScreenWidth] / 2);
    }];
    [_liuLanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([AppConstants uiScreenWidth] / 2);
        make.top.equalTo(_headButton.mas_bottom).with.offset(25);
        make.height.equalTo(@30);
        make.right.mas_equalTo(0);
    }];
}
-(void)enterBtn:(UIButton *)button
{
    PersonMessageViewController * person = [[PersonMessageViewController alloc]init];
    person.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:person animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initUnloginView) name:@"LogoutSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeImage) name:@"changeImage" object:nil];
    
}
- (void)initUnloginView {
    [self createHeaderView];
    [_tableView reloadData];
    _isUserInfoShow = NO;
}
- (void)changeImage {
    if ([[AppConstants userInfo].avatarURL hasPrefix:@"http:"]) {
        [_headButton setBackgroundImageWithURL:[NSURL URLWithString:[AppConstants userInfo].avatarURL] forState:UIControlStateNormal placeholder:[UIImage imageNamed:@"placeholder.png"]];
    }
    else {
        [_headButton setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [AppConstants httpImageHeader], [AppConstants userInfo].avatarURL]] forState:UIControlStateNormal placeholder:[UIImage imageNamed:@"placeholder.png"]];
    }
}

#pragma mark - tableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
        return _secondArray.count;
   
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MyMessageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.xname.text =_secondArray[indexPath.row];
    cell.rightImgView.image =[UIImage imageNamed:@"jiantou"];
    
        return cell;
  }

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

#pragma mark - 清理缓存的方法
-(void)clearCache
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSArray *files = [[ NSFileManager defaultManager ]  subpathsAtPath :cachPath];
        NSLog ( @"files :%lu" ,(unsigned long)[files  count ]);
        for (NSString * p in files)
        {
            NSError * error;
            NSString * path = [cachPath stringByAppendingPathComponent:p];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path])
            {
                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            }
        
        }
        
    });
    
    [ProgressHUD showSuccess:NSLocalizedStringCN(@"qingliwancheng", @"")];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 
    if (indexPath.row==0) {
        NSLog(@"我的收藏");
                    CollectionViewController *collection = [[CollectionViewController alloc] init];
        
                    [self.navigationController pushViewController:collection animated:YES];

    }
        else if (indexPath.row == 1) {
            NSLog(@"关于我们");
            
            NSString *str = @"http://www.greenishome.com/";
            //            https://itunes.apple.com/cn/app/ge-li-si/id?mt=8
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
        else if (indexPath.row == 2)//意见反馈
        {
            NSLog(@"意见反馈");
            
            if ([[AppConstants userInfo].accessToken isEqualToString:@""]) {
                
                [ProgressHUD showError:NSLocalizedStringCN(@"dengluzaifankui", @"")];
                _secondButton.enabled = NO;
                [self performSelector:@selector(click) withObject:nil afterDelay:3.0f];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserInfo) name:@"LoginSuccess" object:nil];
                return;
            }
            
            FeedBackViewController * feed = [[FeedBackViewController alloc]init];
            
            feed.navigationItem.title = NSLocalizedStringCN(@"yijianfankui", @"");
            
            [self.navigationController pushViewController:feed animated:YES];
        }
        else if (indexPath.row == 3) {
            NSLog(@"我的反馈");
            
            if ([[AppConstants userInfo].accessToken isEqualToString:@""]) {
                
                [ProgressHUD showError:NSLocalizedStringCN(@"dengluzaichakanfankui", @"")];
                _secondButton.enabled = NO;
                [self performSelector:@selector(click) withObject:nil afterDelay:3.0f];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserInfo) name:@"LoginSuccess" object:nil];
                return;
            }
            
            MyFeedBackViewController *mfvc = [[MyFeedBackViewController alloc] init];
            
            mfvc.view.backgroundColor = [AppConstants backgroundColor];
            
            mfvc.navigationItem.title = NSLocalizedStringCN(@"wodefankui", @"");
            
            [self.navigationController pushViewController:mfvc animated:YES];
        }
        else if (indexPath.row == 4) {
            NSLog(@"打分鼓励");
            
            NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", [AppConstants AppID]];
            //          https://itunes.apple.com/app/id1067728404
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
        
        else if (indexPath.row == 5) {
            NSLog(@"版本信息");
            
            VersionInfoViewController *vivc = [[VersionInfoViewController alloc] init];
            
            vivc.view.backgroundColor = [AppConstants backgroundColor];
            
            vivc.navigationItem.title = NSLocalizedStringCN(@"banbenxinxi", @"");
            
            [self.navigationController pushViewController:vivc animated:YES];
        }
        else
        {
            NSLog(@"清理缓存");
            
            [ProgressHUD show:NSLocalizedStringCN(@"qinglizhong", @"")];
            [self clearCache];
       

        }
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"wode"];
}
-(void)viewWillappear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [ProgressHUD dismiss];
    [MobClick beginLogPageView:@"wode"];
    //    self.navigationController.navigationBarHidden = NO;
    //    self.tabBarController.tabBar.hidden = NO;
}
@end
