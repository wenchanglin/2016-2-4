//
//  SearchResultsViewController.m
//  歌力思
//
//  Created by wen on 16/7/19.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "LiuLanJiLuDetailViewController.h"
#import "ZhengWenModel.h"
#import "DetailModel.h"
#import "ShareSheet.h"
#import "MessageInputView.h"
#import "WeiboSDK.h"
#import "WXApiRequestHandler.h"
#import "WXApiManager.h"
#import "ProgressHUD.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import "TencentOpenAPI/QQApiInterface.h"
#import "MessageManagerFaceView.h"
#import "BTConstants.h"
#import "DetailTableViewCell.h"
#import "History.h"
#import "AppDelegate.h"
#import "ZhengWenModel.h"
#import "DetailFrameModel.h"
#import "KitchenViewController.h"
#import "CommentsPersonModel.h"
#import "CommentsPersonTableViewCell.h"
#import "BLESerialComManager.h"
#import "Masonry.h"
#define Start_X 20           // 第一个按钮的X坐标
#define Start_Y caiLiaoImageview.frame.size.height+5           // 第一个按钮的Y坐标
#define Width_Space 0        // 2个按钮之间的横间距
#define Height_Space 0      // 竖间距
#define Button_Height 30.0f    // 高
#define Button_Width [UIScreen mainScreen].bounds.size.width/2-10     // 宽 110

@interface LiuLanJiLuDetailViewController ()<ShareSheetDelegate,MessageInputViewDelegate,MessageManagerFaceViewDelegate,WXApiManagerDelegate, TencentSessionDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,BLESerialComManagerDelegate>
@property(strong,nonatomic) CommentsPersonModel * commentModel ;

@property (nonatomic) BOOL        isFav;
@property(nonatomic)BOOL isZan;
@property(nonatomic)BOOL * isPlay;
@property (nonatomic) CGRect                            keyboardRect;
@property (nonatomic,strong) UIBarButtonItem * staButton;//收藏按钮
@property (strong, nonatomic) MessageInputView          *messageInputView;
@property (strong, nonatomic) MessageManagerFaceView    *faceView;
@property(nonatomic,strong)DetailModel * model;
@property (strong, nonatomic) IntroduceDataModel        *data;
@property (nonatomic,strong) ZhengWenModel *zhenwenmodle;
@property(strong,nonatomic) UIButton * zanButton;
@property(strong,nonatomic)UIButton * videoButton;
@property(nonatomic,strong)NSMutableArray * caiLiaoArray;//装材料
@property (nonatomic) double                            animationDuration;
///收藏
@property(nonatomic, strong) History * history;
///linshi收藏
@property(nonatomic, strong) History * tempHistory;
///管理器
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property(nonatomic,assign)int currentStepIndex;

@property (nonatomic, strong) UIImage *starButtonImage;

@property (nonatomic, assign) BOOL result;
@property (strong, nonatomic) TencentOAuth              *oAuth;

@end

@implementation LiuLanJiLuDetailViewController

{
    NSMutableArray * _paths;//装video的URL
    NSMutableArray * _videoName;//装video的名字
    NSMutableArray * _dataSource;//数据源
    UITableView * _tableView;//表
    NSArray  * aArray;//装材料个数
    NSDictionary *dongTaiDict;//动态字典
    CGRect dongTaiRect;//动态高度
    NSInteger _pageSize;//评论的页数
    NSMutableArray * _comentsSource;//评论数组
    NSMutableArray * _stepArray;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"liulanDetailVC"];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"liulanDetailVC"];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)//keyboardWillShow
                                                name:UIKeyboardWillShowNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardChange:)
                                                name:UIKeyboardDidChangeFrameNotification
                                              object:nil];
    //获取通知中心单例对象
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    //添加当前类对象为一个观察者，name和object设置为nil，表示接收一切通知
    [center addObserver:self selector:@selector(faceViewChange:) name:@"Keychange" object:nil];
    
    NSFetchRequest *resuest = [NSFetchRequest fetchRequestWithEntityName:@"History"];
    NSArray *array =  [self.managedObjectContext executeFetchRequest:resuest error:nil];
    for (History *his in array) {
        if ([his.formulaName isEqualToString:self.name]) {
            
            self.starButtonImage = [UIImage imageNamed:@"starFull"];
            _staButton.image = self.starButtonImage;
            self.result = YES;
            self.tempHistory = his;
            
            return;
        }else {
            self.starButtonImage = [UIImage imageNamed:@"star"];
            _staButton.image = self.starButtonImage;
            self.result = NO;
            
        }
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_messageInputView removeFromSuperview];
    [_faceView removeFromSuperview];
    [self initMessageInputView];
    [self initFaceView];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    
    NSLog(@"hide");
    
    _keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSLog(@"keyboardWillHide height = %f", _keyboardRect.size.height);
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [_messageInputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view);
        }];
       
        
        [_messageInputView layoutIfNeeded];
        
    }completion:nil];
}


- (void)keyboardWillShow:(NSNotification *)notification{
    
    CGFloat curkeyBoardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    CGRect begin = [[[notification userInfo] objectForKey:@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue];
    CGRect end = [[[notification userInfo] objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    // 第三方键盘回调三次问题，监听仅执行最后一次
    if(begin.size.height>0 && (begin.origin.y-end.origin.y>0)){
        _keyboardRect.size.height = curkeyBoardHeight+20;
        [self keyboardChange:notification];
    }    NSLog(@"keyboardWillShow height = %f", _keyboardRect.size.height);
    
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [_messageInputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).with.offset(-_keyboardRect.size.height+50);
        }];
        
        [_messageInputView layoutIfNeeded];
       
    }completion:nil];
}


-(void)faceViewChange:(NSNotification *)notification
{
    _keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSLog(@"浏览记录详情页面faceViewChange");
    _keyboardRect.size.height = 271;
    if ([[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y<CGRectGetHeight(self.view.frame)) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [_messageInputView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view).with.offset(-_keyboardRect.size.height);//-_keyboardRect.size.height-100
            }];
            
            
            _tableView.frame= CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-49-_keyboardRect.size.height);
            
            
            [_messageInputView layoutIfNeeded];
            [_tableView layoutIfNeeded];
        }completion:nil];
    }
    //    NSLog(@"%f",_messageInputView.frame.origin.y);
}

- (void)keyboardChange:(NSNotification *)notification{
    
    _keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSLog(@"keyboardChange");
  //  _keyboardRect.size.height =282;
    
    if ([[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y<CGRectGetHeight(self.view.frame)) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [_messageInputView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view).with.offset(-_keyboardRect.size.height-10);//-_keyboardRect.size.height-100
            }];
            _tableView.frame= CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-49 -_keyboardRect.size.height-70);
            [_messageInputView layoutIfNeeded];
            [_tableView layoutIfNeeded];
        }completion:nil];
    }
    NSLog(@"%f",_messageInputView.frame.origin.y);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.managedObjectContext = ((AppDelegate *)([UIApplication sharedApplication].delegate)).managedObjectContext;
    [BLESerialComManager sharedInstance].delegate = self;
    [WXApiManager sharedManager].delegate = self;
    //设置导航栏的返回按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = item;
    //更改导航栏的返回图标"<"的颜色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"#CCCCCC"];
    NSString *appid = [AppConstants QQAppID];
    
    // 只是为了消除warning
    _oAuth = [[TencentOAuth alloc] initWithAppId:appid andDelegate:self];
    dongTaiDict = [[NSDictionary alloc]initWithObjectsAndKeys:[UIFont systemFontOfSize:10.0f], NSFontAttributeName, nil];
    dongTaiRect =  [self.detailStr boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:dongTaiDict context:nil];
    
    
    if([self.caiLiaoStr rangeOfString:@"\n"].location !=NSNotFound)//_roaldSearchText
    {
        NSLog(@"yes");
        aArray = [self.caiLiaoStr componentsSeparatedByString:@"\n"];
    }
    else
    {
        NSLog(@"no");
        aArray  = [NSArray arrayWithObject:self.caiLiaoStr];
    }
    _stepArray = [NSMutableArray array];
    _comentsSource = [NSMutableArray array];
    _dataSource = [NSMutableArray array];
    _paths  = [NSMutableArray array];
    _videoName = [NSMutableArray array];
    _caiLiaoArray = [NSMutableArray array];
    self.view.backgroundColor =[UIColor whiteColor];
    NSArray * arrays = [self.step componentsSeparatedByString:@"%"];
    for (int i=0; i<arrays.count; i++) {
        if (![[arrays objectAtIndex:i] isEqualToString:@""]) {
            [_stepArray addObject:[arrays objectAtIndex:i]];
        }
    }
    self.title = self.name;
    _data.effect = self.mainimageView;
    _data.formulaID = self.formulaId;
    _pageSize  = 10;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendCommentPress) name:@"commentPost" object:nil];
//    [self initMessageInputView];
//    [self initFaceView];
    
    [self requestData];
    
    [self requestComments];
    [self rightButtonTools];
    
    
    
}



- (void)sendCommentPress {
    NSLog(@"sendCommentPress");
    NSLog(@"messageInputTextView = %@", _messageInputView.messageInputTextView);
    
    [self didSendTextAction:_messageInputView.messageInputTextView];
}

#pragma mark - 初始化输入框
-(void)initMessageInputView
{
    _messageInputView = [[MessageInputView alloc] init];
    _messageInputView.delegate = self;
    [self.view addSubview:_messageInputView];
    UILabel *placeHolderLabel = [[UILabel alloc] init];
    placeHolderLabel.text = NSLocalizedStringCN(@"pingluncaipu", "");
    placeHolderLabel.numberOfLines = 0;
    placeHolderLabel.textColor = [UIColor lightGrayColor];
    [placeHolderLabel sizeToFit];
    [_messageInputView.messageInputTextView addSubview:placeHolderLabel];
    [_messageInputView.messageInputTextView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
    [_messageInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.height.equalTo(_messageInputView.messageInputTextView.mas_height).with.offset(10);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(-2);
    }];
    
    
}
#pragma mark - 初始化表情
-(void)initFaceView
{
    self.faceView = [[MessageManagerFaceView alloc] init];
    self.faceView.delegate = self;
    self.faceView.userInteractionEnabled = YES;
    [self.view addSubview:self.faceView];
    
    [self.faceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom);
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(196);
    }];
    
}


#pragma mark - 获取评论
-(void)requestComments
{
    // 获取最新数据
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@interaction/formula/comment/list/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"formulaId":self.formulaId, @"page":@"1", @"pageSize":[NSString stringWithFormat:@"%ld", (long)_pageSize]};
    
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"评论数据:%@",responseObject);
        if ([[responseObject objectForKey:@"ok"] intValue]==1) {
            [_comentsSource removeAllObjects];
            NSArray * comments =[responseObject objectForKey:@"comments"];
            for (NSDictionary * dict in comments) {
                _commentModel = [[CommentsPersonModel alloc]initWithDic:dict];
                PingLunFrameModel * pinglunModel = [[PingLunFrameModel alloc]init];
                pinglunModel.model = _commentModel;
                [_comentsSource addObject:pinglunModel];
                
                
            }
        }
        [_tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
     }];
}
#pragma mark - 获取正文数据
-(void)requestData
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@resource/formula/steps/list/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"FormulaID":self.formulaId, @"page":@"1", @"pageSize":@"10"};
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:@"ok"]intValue]==1) {
            [_dataSource removeAllObjects];
            NSLog(@"responseObject   %@",responseObject);
            NSArray * steps = [responseObject objectForKey:@"steps"];
            for (NSDictionary * dic in steps) {
                _model = [[DetailModel alloc] initWithDic:dic];
                DetailFrameModel *frameModle = [[DetailFrameModel alloc] init];
                frameModle.model = _model;
                [_dataSource addObject:frameModle];
            }
            
            [self createTableView];
        }
        else if ([[responseObject objectForKey:@"ok"] intValue]==0)
        {
            NSLog(@"获取列表失败 %@", urlString);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"false urlString = %@", urlString);
        NSLog(@"Error: %@", error);
    }];
}

-(void)rightButtonTools
{
    
    
    
    self.starButtonImage = [UIImage imageNamed:@"star"];
    self.starButtonImage = [self.starButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    _staButton = [[UIBarButtonItem alloc]initWithImage:self.starButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(starButtonPress)];
    
    UIToolbar * toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 90, 45)];
    toolBar.backgroundColor =[UIColor clearColor];
    //分享按钮
    //    UIImage * shareImage =[[UIImage imageNamed:@"share"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //    UIBarButtonItem * shareButton = [[UIBarButtonItem alloc]initWithImage:shareImage style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonPress)];
    //下载按钮
    UIImage * downLoadImage = [[UIImage imageNamed:@"downLoad"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem * downLoadButton = [[UIBarButtonItem alloc]initWithImage:downLoadImage style:UIBarButtonItemStylePlain target:self action:@selector(downloadButtonPress)];
    [toolBar setItems:@[downLoadButton,_staButton]];
    [toolBar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [toolBar setShadowImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny];
    toolBar.clipsToBounds =YES;
    UIBarButtonItem *customButton = [[UIBarButtonItem alloc] initWithCustomView:toolBar];
    customButton.tintColor = [UIColor clearColor];
    self.navigationItem.rightBarButtonItem = customButton;
}

#pragma mark - 创建表
-(void)createTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-49 - 64) style:UITableViewStyleGrouped];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate =self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    // [_tableView registerClass:[DetailTableViewCell class] forCellReuseIdentifier:@"cell"];
    // [_tableView registerClass:[CommentsPersonTableViewCell class] forCellReuseIdentifier:@"commentsCell"];
    
}





//下载菜谱的事件
- (void)downloadButtonPress
{
    NSLog(@"downloadButtonPress");
    
    [_messageInputView.messageInputTextView resignFirstResponder];
    
    if ([BTConstants BTDownloadingSteps]) {
        return;
    }
    
    if (![BTConstants BTConnected]) {
        [ProgressHUD showError:NSLocalizedStringCN(@"weilianjielanya", @"")];
        
        [BTConstants BTSetDownloadingSteps:NO];
        
        [AppConstants setDownloadButtonPress2Pop:YES];
        
        [NSThread detachNewThreadSelector:@selector(timedPop) toTarget:self withObject:nil];
        
        return;
    }
    
    if ([BTConstants BTStatus] == BTStatusRunning) {
        [ProgressHUD showError:NSLocalizedStringCN(@"jiqiyunxingzhong", @"")];
        
        return;
    }
    else {
        [BTConstants BTSetRequestType:@"download"];
        [BTConstants sendCommand:[BTConstants A9]];
    }
}

- (void)timedPop
{
    @autoreleasepool
    {
        NSTimeInterval sleep = 2.0;
        [NSThread sleepForTimeInterval:sleep];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}


//分享的点击事件
- (void)shareButtonPress
{
    NSLog(@"shareButtonPress");
    
    [_messageInputView.messageInputTextView resignFirstResponder];
    ShareSheet *sheet = [[ShareSheet alloc]initWithlist:[AppConstants shareSheetMenu] height:0];
    sheet.delegate = self;
    [sheet showInView:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==1) {
        
        return _comentsSource.count;
    }
    else
    {
        return _dataSource.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (indexPath.section ==1) {
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section],(long)[indexPath row]];//以indexPath来唯一确定cell
        CommentsPersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //出列可重用的cell
        if(cell ==nil){
            cell = [[CommentsPersonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        PingLunFrameModel * pinglunModel = _comentsSource[indexPath.row];
        cell.model = pinglunModel;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame] ;
        cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
        return cell;
        
    }
    else
    {
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section],(long)[indexPath row]];//以indexPath来唯一确定cell
        DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //出列可重用的cell
        if(cell ==nil){
            cell = [[DetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        DetailFrameModel *frameModel = _dataSource[indexPath.row];
        cell.frameModel = frameModel;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame] ;
        cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];

        return cell;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        
        PingLunFrameModel * pinglunModel = _comentsSource[indexPath.row];
        return pinglunModel.cellHeight;
    }
    else
    {
        DetailFrameModel *frameModel = _dataSource[indexPath.row];
        return frameModel.cellHeight+5;
    }
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 160)];
        view.backgroundColor = [UIColor whiteColor];
        UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 60) / 2, 50, 60, 60)];
        share.backgroundColor = [UIColor colorWithHexString:@"#FFCC33"];
        share.layer.cornerRadius = 30;
        share.layer.masksToBounds = YES;
        [view addSubview:share];
        [share setTitle:@"分享" forState:UIControlStateNormal];
        [share addTarget:self action:@selector(shareButtonPress) forControlEvents:UIControlEventTouchUpInside];
        return view;
    } else {
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 160;
    }else {
        return 0;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==1) {
        return 0;
    }
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 670 - 210)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor whiteColor];
    //主图
    NSString * string = [NSString stringWithFormat:@"%@%@",[AppConstants httpChinaAndEnglishForHead],self.mainimageView];
    //视频图
    UIImageView * videoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 246)];
    [videoImageView setImageWithURL:[NSURL URLWithString:string] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    videoImageView.userInteractionEnabled = YES;
    [view addSubview:videoImageView];
    _videoButton = [[UIButton alloc]initWithFrame:CGRectMake((videoImageView.frame.size.width-40)/2, (videoImageView.frame.size.height-40)/2, 40, 40)];
    [_videoButton setImage:[UIImage imageNamed:@"playBtn"] forState:UIControlStateNormal];
    [videoImageView addSubview:_videoButton];
    _videoButton.tag =1;
    [_videoButton addTarget:self action:@selector(huanPic:) forControlEvents:UIControlEventTouchUpInside];
    UILabel * gongxiaoDetail = [[UILabel alloc]init];
    //功效详情
    gongxiaoDetail.font = [UIFont systemFontOfSize:13.0f];
    gongxiaoDetail.textColor = [UIColor grayColor];
    [view addSubview:gongxiaoDetail];
    gongxiaoDetail.text = self.detailStr;
    
    [gongxiaoDetail setFrame:CGRectMake(30, CGRectGetMaxY(videoImageView.frame) + 5, [UIScreen mainScreen].bounds.size.width-50, dongTaiRect.size.height+60)];
    gongxiaoDetail.numberOfLines = 0;
    
    //材料文字
    UILabel *caiLiaoLabel = [[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 120) / 2, CGRectGetMaxY(gongxiaoDetail.frame) + 40, 120, 30)];
    caiLiaoLabel.text = NSLocalizedStringCN(@"cailiao", @"");
    caiLiaoLabel.font = [UIFont systemFontOfSize:18.0f];
    [view addSubview:caiLiaoLabel];
    caiLiaoLabel.textAlignment = NSTextAlignmentCenter;
    NSLog(@"1. %@",aArray);
    UILabel * aLabel;
    if (aArray.count==1) {
        aLabel = [[UILabel alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-140)/2, CGRectGetMaxY(caiLiaoLabel.frame) + 25, 140, 30)];
        [view addSubview:aLabel];
        aLabel.text = aArray[0];
        aLabel.font = [UIFont systemFontOfSize:12.0f];
        aLabel.textColor = [UIColor grayColor];
        aLabel.textAlignment = NSTextAlignmentCenter;
    }
    else
    {
        
        for (int i=0; i<aArray.count - 1; i++) {
            //计算行数和列数
            NSInteger index = i % 2;
            NSInteger page = i / 2;
            
            aLabel = [[UILabel alloc]initWithFrame:CGRectMake(index *(Button_Width + Width_Space)+30, page*40+CGRectGetMaxY(caiLiaoLabel.frame)+ 25, [UIScreen mainScreen].bounds.size.width / 2 - 10, 30)];
            [view addSubview:aLabel];
            aLabel.text = aArray[i];
            aLabel.font = [UIFont systemFontOfSize:12.0f];
            aLabel.textColor = [UIColor grayColor];
        }
    }
    
    //    做法
    UILabel *practice = [[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 120) / 2, CGRectGetMaxY(aLabel.frame) + 50, 120, 40)];
    [view addSubview:practice];
    practice.font = [UIFont systemFontOfSize:18.0f];
    practice.text = NSLocalizedStringCN(@"zuofa", @"");
    practice.textAlignment = NSTextAlignmentCenter;
    return view;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (section==1) {
        return 3;
    }
    else
    {
        if (aArray.count==1||aArray.count==2) {
            return dongTaiRect.size.height+50+65+30+410 + 11 + 20 ;
        }
        else if (aArray.count==3||aArray.count==4) {
            return dongTaiRect.size.height+50+65+60+410 ;
        }
        else if (aArray.count==5||aArray.count==6) {
            return dongTaiRect.size.height+50+65+90+410  ;
        }
        else if (aArray.count==7||aArray.count==8) {
            
            return dongTaiRect.size.height+50+65+120+410 + 11 + 20 ;
        }
        else if (aArray.count==9||aArray.count==10) {
            return dongTaiRect.size.height+50+65+150+410 + 11 + 20 ;
        }
        else if(aArray.count==11||aArray.count ==12)
        {
            return dongTaiRect.size.height+50+65+180+440+ 11 + 20 ;
        }
        else if (aArray.count==13||aArray.count==14)
        {
            return dongTaiRect.size.height+50+65+180+470+ 31 ;
        }
        else
        {
            return dongTaiRect.size.height+50+65+180+500+ 11 ;
        }
    }
}

#pragma mark - MessageInputViewDelegate
/*
 * 点击输入框代理方法
 */
- (void)inputTextViewWillBeginEditing:(MessageTextView *)messageInputTextView{
    
}

- (void)inputTextViewDidBeginEditing:(MessageTextView *)messageInputTextView
{
    /*
     [self messageViewAnimationWithMessageRect:keyboardRect
     withMessageInputViewRect:self.messageToolView.frame
     andDuration:animationDuration
     andState:ZBMessageViewStateShowNone];
     */
}

- (void)inputTextViewDidChange:(MessageTextView *)messageInputTextView
{
    NSLog(@"messageInputTextView.text = %@", messageInputTextView.text);
    
}

-(void)SendTheFaceStr:(NSString *)faceStr isDelete:(BOOL)dele
{
    if (dele) {
        int location = [self searchFaceStr];
        if(location != -1)
        {
            [self deleteFaceStr:location];
        }
        else
        {
            [_messageInputView.messageInputTextView deleteBackward];
        }
        return;
    }
    _messageInputView.messageInputTextView.text = [_messageInputView.messageInputTextView.text stringByAppendingString:faceStr];
    [self inputTextViewDidChange:_messageInputView.messageInputTextView];
    [_messageInputView.messageInputTextView scrollRangeToVisible:NSMakeRange(_messageInputView.messageInputTextView.text.length, 1)];
}
- (int)searchFaceStr {
    
    int location = -1;
    
    NSString *str = _messageInputView.messageInputTextView.text;
    NSUInteger strLength = [str length];
    NSString *lastChar = [str substringWithRange:NSMakeRange(strLength - 1,1)];
    if ([lastChar isEqualToString:@"]"]) {
        NSRange range = [str rangeOfString:@"["options:NSBackwardsSearch];
        //判别查找到的字符串是否正确
        if (range.length> 0) {
            location = (int)range.location;
        }
    }
    
    return location;
}
- (void)deleteFaceStr:(int)location {
    NSString *str = _messageInputView.messageInputTextView.text;
    
    _messageInputView.messageInputTextView.text = [str substringWithRange:NSMakeRange(0, location)];
}

#pragma mark - MessageInputViewDelegate
-(void)didSendTextAction:(MessageTextView *)messageInputTextView
{
    NSLog(@"text = %@",messageInputTextView.text);
    _messageInputView.faceButtonSelected = NO;
    [_messageInputView.faceSendButton setImage:[UIImage imageNamed:@"ToolViewEmotion_ios7"] forState:UIControlStateNormal];
    [_messageInputView.messageInputTextView resignFirstResponder];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            [_messageInputView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view);
            }];
            
            [_faceView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_bottom);
            }];
            
           
            
            [_faceView layoutIfNeeded];
            [_messageInputView layoutIfNeeded];
            
        } completion:nil];
    });
    [self sendComment:messageInputTextView.text];
    
    messageInputTextView.text = @"";
}


- (void)didSendFaceAction:(BOOL)sendFace{
    
    if (sendFace) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [_messageInputView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(self.view).with.offset(-196);
                }];
               
                [_faceView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.view.mas_bottom).with.offset(-196);
                }];
                
                [_messageInputView layoutIfNeeded];
               
                [_faceView layoutIfNeeded];
            }completion:nil];
        });
        
    }
    else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [_messageInputView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(self.view).with.offset(-_keyboardRect.size.height);
                }];
               
                [_faceView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.view.mas_bottom);
                }];
                
                [_messageInputView layoutIfNeeded];
               
                [_faceView layoutIfNeeded];
            }completion:nil];
        });
        
    }
}


- (void)sendComment:(NSString*)comment {
    
    if ([[AppConstants userInfo].accessToken isEqualToString:@""]||[AppConstants userInfo].accessToken==nil) {
        
        [ProgressHUD showError:NSLocalizedStringCN(@"dengluzaipinglun", @"")];
        _tableView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-49-64);
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@interaction/formula/comment/post/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"AccessToken": [AppConstants userInfo].accessToken, @"formulaId":self.formulaId, @"Content":comment};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"%@ Success: %@", urlString, responseObject);
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  [ProgressHUD showSuccess:NSLocalizedStringCN(@"pinglunchenggong", @"")];
                  
                  
                  _tableView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-49-64);
                  [self requestData];
                  [self requestComments];
              }
              else if ([[responseObject objectForKey:@"errno"] isEqualToString:@"4401"]) {
                  [AppConstants relogin:^(BOOL success){
                      if (success) {
                          [self sendComment:comment];
                      }
                      else {
                          [AppConstants notice2ManualRelogin];
                      }
                  }];
              }
              else if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 0) {
                  [ProgressHUD showError:NSLocalizedStringCN(@"pinglunshibai", @"")];
                  _tableView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-49-64);
              }
              
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"Error: %@", error);
              
              [ProgressHUD showError:NSLocalizedStringCN(@"badNetwork", @"")];
              _tableView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-49-64);
          }];
}



#pragma mark - UIScrollView Delegate dragging

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
   // NSLog(@"dragging");
    
    _messageInputView.faceButtonSelected = NO;
    [_messageInputView.faceSendButton setImage:[UIImage imageNamed:@"ToolViewEmotion_ios7"] forState:UIControlStateNormal];
    [_messageInputView.messageInputTextView resignFirstResponder];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            [_messageInputView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view);
            }];
            
            [_faceView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_bottom);
            }];
            
            _tableView.frame  = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-49 - 64);
            
            [_faceView layoutIfNeeded];
            [_messageInputView layoutIfNeeded];
            [_tableView layoutIfNeeded];
        }completion:nil];
    });
}

#pragma mark 收藏功能
//收藏
- (void)starButtonPress {
    
    if (self.result) {
        [self.managedObjectContext deleteObject:self.tempHistory];
        [self.managedObjectContext save:nil];
        self.starButtonImage = [UIImage imageNamed:@"star"];
        _staButton.image = self.starButtonImage;
        self.result = NO;
        NSLog(@"取消保存成功");
        
    }else {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:self.managedObjectContext];
        self.history = [[History alloc]initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        
        //        self.history.index = @(self.index);
        self.history.imgUrl = self.mainimageView;
        self.history.formulaName = self.name;
        self.history.gongxiao = self.detailStr;
        self.history.formulaID = self.formulaId;
        self.history.shareurl = self.shareUrl;
        self.history.steps = self.step;
        self.history.videoUrl = self.videoUrl;
        self.history.cailiao = self.caiLiaoStr;
        [self.managedObjectContext save:nil];
        NSLog(@"保存成功");
        self.tempHistory = self.history;
        self.starButtonImage = [UIImage imageNamed:@"starFull"];
        _staButton.image = self.starButtonImage;
        self.result = YES;
        
    }
    
    
    
    
    
}


-(void)huanPic:(UIButton *)button
{
    switch (button.tag)
    {
        case 1:
        {
            
            if ([self.videoUrl isEqualToString:@""])
            {
                [ProgressHUD showError:NSLocalizedStringCN(@"novideo", @"")];
                return;
            }
            else
            {
            
            NSString * videoUrlStr = [NSString stringWithFormat:@"%@%@",[AppConstants httpVideoHeader],self.videoUrl];
            [_paths addObject:videoUrlStr];
            NSString * videoNameStr = [NSString stringWithFormat:@"%@",self.name];
            [_videoName addObject:videoNameStr];
            
            NSMutableArray *videoList = [NSMutableArray array];
            
            SSVideoModel *model = [[SSVideoModel alloc]initWithName:_videoName[0] path:_paths[0]];
            [videoList addObject:model];
            
            SSVideoPlayController *playController = [[SSVideoPlayController alloc]initWithVideoList:videoList];
            SSVideoPlayContainer *playContainer = [[SSVideoPlayContainer alloc]initWithRootViewController:playController];
            
            [self presentViewController:playContainer animated:NO completion:nil];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - 分享的协议
-(void)didSelectIndex:(NSInteger)index{
    // 0 新浪微博
    // 1 微信好友
    // 2 微信朋友圈
    // 3 QQ好友
    // 4 QQ空间
    // 5 取消
    
    
    switch (index) {
        case 0:
        {
            WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
            authRequest.redirectURI = @"https://api.weibo.com/oauth2/default.html";
            authRequest.scope = @"all";
            
            WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare] authInfo:authRequest access_token:[AppConstants WeiboAccessToken]];
            request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
                                 @"Other_Info_1": [NSNumber numberWithInt:123],
                                 @"Other_Info_2": @[@"obj1", @"obj2"],
                                 @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
            //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
            [WeiboSDK sendRequest:request];
        }
            break;
        case 1:
        {
            NSString * linkUrl ;
            if ([self.shareUrl hasPrefix:@"http"]) {
                linkUrl = self.shareUrl;
            }
            else
            {
                linkUrl = [NSString stringWithFormat:@"%@%@", [AppConstants shareHeader], self.shareUrl];
            }
            // ThumbImage 超过10K 会分享失败
            [WXApiRequestHandler sendLinkURL:linkUrl
                                     TagName:@"SmartKitchen"
                                       Title:self.name
                                 Description:self.detailStr
                                  ThumbImage:[UIImage imageNamed:@"icon.png"]
                                     InScene:WXSceneSession];
        }
            break;
        case 2:
        {
            NSString * linkUrl ;
            if ([self.shareUrl hasPrefix:@"http"]) {
                linkUrl = self.shareUrl;
            }
            else
            {
                linkUrl = [NSString stringWithFormat:@"%@%@", [AppConstants shareHeader], self.shareUrl];
            }
            // ThumbImage 超过10K 会分享失败
            [WXApiRequestHandler sendLinkURL:linkUrl
                                     TagName:@"SmartKitchen"
                                       Title:self.name
                                 Description:self.detailStr
                                  ThumbImage:[UIImage imageNamed:@"icon.png"]
                                     InScene:WXSceneTimeline];
        }
            break;
        case 3:
        {
            
            NSURL *previewURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [AppConstants httpChinaAndEnglishForHead], self.mainimageView]];
            NSLog(@"%@",previewURL);
            NSURL * linkUrl ;
            if ([self.shareUrl hasPrefix:@"http"]) {
                linkUrl = [NSURL URLWithString:self.shareUrl];
            }
            else
            {
                linkUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [AppConstants shareHeader], self.shareUrl]];
            }
            
            QQApiNewsObject* img = [QQApiNewsObject objectWithURL:linkUrl title:self.name description:self.detailStr previewImageURL:previewURL];
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
            
            QQApiSendResultCode sent = [QQApiInterface sendReq:req];
            [self handleSendResult:sent];
        }
            break;
        case 4:
        {
            NSURL *previewURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [AppConstants httpChinaAndEnglishForHead], self.mainimageView]];
            NSURL * linkUrl ;
            if ([self.shareUrl hasPrefix:@"http"]) {
                linkUrl = [NSURL URLWithString:self.shareUrl];
            }
            else
            {
                linkUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [AppConstants shareHeader], self.shareUrl]];
            }
            
            QQApiNewsObject* img = [QQApiNewsObject objectWithURL:linkUrl title:self.name description:self.detailStr previewImageURL:previewURL];
            
            [img setCflag:kQQAPICtrlFlagQZoneShareOnStart];
            
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
            
            QQApiSendResultCode sent = [QQApiInterface sendReq:req];
            [self handleSendResult:sent];
        }
            break;
        default:
            NSLog(@"index = %ld", (long)index);
            break;
    }
}



#pragma mark - QQ分享调用的代理
- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    NSLog(@"handleSendResult");
    
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            [ProgressHUD showError:@"App未注册 -_-"];
        }
            break;
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            [ProgressHUD showError:@"发送参数错误 -_-"];
        }
            break;
        case EQQAPIQQNOTINSTALLED:
        {
            [ProgressHUD showError:@"未安装手Q -_-"];
        }
            break;
        case EQQAPIQQNOTSUPPORTAPI:
        {
            [ProgressHUD showError:@"API接口不支持 -_-"];
        }
            break;
        case EQQAPISENDFAILD:
        {
            [ProgressHUD showError:@"发送失败-_-"];
        }
            break;
        default:
        {
            break;
        }
    }
}
#pragma mark - 微博分享代理
- (WBMessageObject *)messageToShare
{
    WBMessageObject *message = [WBMessageObject message];
    
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = self.formulaId;
    webpage.title = self.name;
    webpage.description = self.detailStr;
    webpage.thumbnailData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon" ofType:@"png"]];
    webpage.webpageUrl = [NSString stringWithFormat:@"%@%@", [AppConstants shareHeader], self.shareUrl];
    message.mediaObject = webpage;
    
    return message;
}

- (void)managerDidRecvGetMessageReq:(GetMessageFromWXReq *)req {
    // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
    NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
    NSString *strMsg = [NSString stringWithFormat:@"openID: %@", req.openID];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle
                                                    message:strMsg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    alert.tag = 1000;
    [alert show];
}

- (void)managerDidRecvShowMessageReq:(ShowMessageFromWXReq *)req {
    WXMediaMessage *msg = req.message;
    
    //显示微信传过来的内容
    WXAppExtendObject *obj = msg.mediaObject;
    
    NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
    NSString *strMsg = [NSString stringWithFormat:@"openID: %@, 标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%lu bytes\n附加消息:%@\n", req.openID, msg.title, msg.description, obj.extInfo, (unsigned long)msg.thumbData.length, msg.messageExt];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle
                                                    message:strMsg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)managerDidRecvLaunchFromWXReq:(LaunchFromWXReq *)req {
    WXMediaMessage *msg = req.message;
    
    //从微信启动App
    NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
    NSString *strMsg = [NSString stringWithFormat:@"openID: %@, messageExt:%@", req.openID, msg.messageExt];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle
                                                    message:strMsg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response {
    if (response.errCode == 0) {
        [ProgressHUD showSuccess:NSLocalizedStringCN(@"fenxiangchenggong", @"")];
    }
    else {
        [ProgressHUD showSuccess:NSLocalizedStringCN(@"fenxiangshibai", @"")];
    }
}

- (void)managerDidRecvAddCardResponse:(AddCardToWXCardPackageResp *)response {
    NSMutableString* cardStr = [[NSMutableString alloc] init];
    for (WXCardItem* cardItem in response.cardAry) {
        [cardStr appendString:[NSString stringWithFormat:@"cardid:%@ cardext:%@ cardstate:%u\n",cardItem.cardId,cardItem.extMsg,(unsigned int)cardItem.cardState]];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"add card resp"
                                                    message:cardStr
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)managerDidRecvAuthResponse:(SendAuthResp *)response {
    NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
    NSString *strMsg = [NSString stringWithFormat:@"code:%@,state:%@,errcode:%d", response.code, response.state, response.errCode];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle
                                                    message:strMsg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

#pragma BLEDelegate
// 扫描结束
-(void)bleSerilaComManagerDidEnumComplete:(BLESerialComManager *)bleSerialComManager{
    NSLog(@"scan complete");
    /*
     [_spinner stopAnimating];
     
     _tableview = [[UITableView alloc] init];
     _tableview.delegate = self;
     _tableview.dataSource = self;
     _tableview.backgroundColor = [UIColor whiteColor];
     [_tableview registerClass:[KitchenMachineTableViewCell class] forCellReuseIdentifier:@"MachineCell"];
     [_tableview reloadData];
     
     [self.view addSubview:_tableview];
     
     [_tableview mas_makeConstraints:^(MASConstraintMaker *make) {
     make.top.equalTo(_spinner.mas_bottom);
     make.left.right.and.bottom.equalTo(self.view);
     }];*/
}

// 扫描到可用设备
-(void)bleSerilaComManager:(BLESerialComManager *)bleSerialComManager didFoundPort:(BLEPort *)port{
    if (port!=nil) {
        //        NSLog(@"name = %@, PORT_STATE = %ld, connectTimer = %@, discoverTimer = %@, writeBuffer = %@, readBuffer = %@, address = %@", port.name, (long)port.state, port.connectTimer, port.discoverTimer, port.writeBuffer, port.readBuffer, port.address);
        
        //        [_machineArray addObject:port];
    }
}

//打开端口结果
-(void)bleSerilaComManager:(BLESerialComManager *)bleSerialComManager didOpenPort:(BLEPort *)port withResult:(resultCodeType)result{
    if (result == RESULT_SUCCESS) {
        
        [BTConstants BTSetConnected:YES];
        [BTConstants BTSetCurrentPort:port];
        
        /*
         NSLog(@"连接成功");
         
         [_spinner stopAnimating];
         
         _kitchenMachineViewController = [[KitchenMachineViewController alloc] initWithPort:_currentPort];
         
         _kitchenMachineViewController.view.backgroundColor = [UIColor whiteColor];
         
         _kitchenMachineViewController.hidesBottomBarWhenPushed = YES;
         
         [BLESerialComManager sharedInstance].delegate = _kitchenMachineViewController;
         
         [self.navigationController pushViewController:_kitchenMachineViewController animated:YES];
         
         _kitchenMachineViewController = nil;*/
    }
}

// 关闭端口
-(void)bleSerialComManager:(BLESerialComManager *)bleSerialComManager didClosedPort:(BLEPort *)port{
    NSLog(@"didClosedPort");
    
    [BTConstants BTSetConnectedMachineName:@""];
    [BTConstants BTSetConnected:NO];
    [BTConstants BTSetCurrentPort:nil];
    [BTConstants BTSetAvailable:NO];
    [BTConstants BTSetStatus:BTStatusNotReady];
    //    [BTConstants BTSetStepTotalTime:0];
}

// 状态改变
-(void)bleSerilaComManagerDidStateChange:(BLESerialComManager *)bleSerialComManager{
    /*
     NSString *stateStrings[6] = {@"CENTRAL_STATE_UNKNOWN",
     @"CENTRAL_STATE_RESETTING",
     @"CENTRAL_STATE_UNSUPPORTED",
     @"CENTRAL_STATE_UNAUTHORIZED",
     @"CENTRAL_STATE_POWEREDOFF",
     @"CENTRAL_STATE_POWEREDON"
     };
     
     NSString *message = [@"state change to " stringByAppendingString:stateStrings[bleSerialComManager.state]];
     
     
     UIAlertView *stateChangeAlert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:message delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:nil, nil];
     [stateChangeAlert show];*/
}

-(void)bleSerialComManager:(BLESerialComManager *)bleSerialComManager port:(BLEPort *)port didReceivedPackage:(NSData *)package{
    
    
    
}
- (void)downloadTimeUp {
    @autoreleasepool
    {
        NSTimeInterval sleep = 5.0;
        
        [NSThread sleepForTimeInterval:sleep];
        
        if ([BTConstants BTDownloadingSteps] == YES) {
            [BTConstants BTSetDownloadingSteps:NO];
            [BTConstants BTSetRequestType:@""];
            [ProgressHUD showError:NSLocalizedStringCN(@"xiafacaipuchaoshi", @"")];
        }
    }
}
-(void)bleSerialComManager:(BLESerialComManager *)bleSerialComManager didDataReceivedOnPort:(BLEPort *)port withLength:(unsigned int)length{
    
    
    NSLog(@"read data!!!!");
    
    NSData *recData = [bleSerialComManager readDataFromPort:port withLength:length];
    NSString *data = [[NSString alloc] initWithData:recData encoding:NSUTF8StringEncoding];
    NSLog(@"DetailViewController package is : %@ D7_1 = %@",data, [BTConstants D7_1]);
    
    if ([[BTConstants BTRequestType] isEqualToString:@"download"]) {
        
        [BTConstants BTSetRequestType:@""];
        
        if ([data hasPrefix:@"SBT:B9040002"] || [data hasPrefix:@"SBT:B9040010"]) {
            [ProgressHUD showError:NSLocalizedStringCN(@"tishijiesuo", @"")];
        }
        else {
            [NSThread detachNewThreadSelector:@selector(downloadTimeUp) toTarget:self withObject:nil];
            
            [ProgressHUD show:NSLocalizedStringCN(@"xiafacaipuzhong", @"")];
            
            [BTConstants BTSetDownloadingSteps:YES];
            
            _currentStepIndex = 0;
            
            NSString *countStr = [[NSString alloc] initWithFormat:@"%02x",(int)[_stepArray count]];
            
            [BTConstants BTSetRequestType:@"C5"];
            [BTConstants sendCommand:[BTConstants C5:countStr]];
        }
        
        return;
    }
    
    if ([data hasPrefix:@"SBT:D207"]) {
        if ([BTConstants BTStatus] != BTStatusRunning) {
            [BTConstants BTSetStatus:BTStatusRunning];
        }
    }
    
    if ([data hasPrefix:@"SBT:BA0205"]) {
        [ProgressHUD showError:NSLocalizedStringCN(@"shebeiyiduankai", @"")];
        
        [[BLESerialComManager sharedInstance] closePort:[BTConstants BTcurrentPort]];
        
        [BTConstants BTResetStatus];
        
        return;
    }
    
    if ([data hasPrefix:@"SBT:BA0201"]) {
        [ProgressHUD showError:NSLocalizedStringCN(@"jiqiyijiesuo", @"")];
        
        return;
    }
    
    if ([data hasPrefix:@"SBT:BA0203"]) {
        [ProgressHUD showError:NSLocalizedStringCN(@"beiziweifanghao", @"")];
        [BTConstants BTSetRequestType:@"A3"];
        [BTConstants sendCommand:[BTConstants A3]];
        return;
    }
    
    if ([data hasPrefix:@"SBT:BA0202"]) {
        [ProgressHUD showSuccess:NSLocalizedStringCN(@"beiziyifanghao", @"")];
        
        return;
    }
    if([data hasPrefix:@"SBT:B302"])
    {
        
        if ( [[BTConstants B3:data] isEqualToString:@"0"]) {
            [ProgressHUD showSuccess:NSLocalizedStringCN(@"beizibujianle", @"")];
            //NSLog(@"表示整个杯子都被拿走了");
        }
        else if([[BTConstants B3:data] isEqualToString:@"1"])
        {
            [ProgressHUD showSuccess:NSLocalizedStringCN(@"beigaibujianle", @"")];
            // NSLog(@"表示只有杯盖被拿走了,杯体还放在机身上面");
            
        }
        else if([[BTConstants B3:data] isEqualToString:@"2"])
        {
            [ProgressHUD showSuccess:NSLocalizedStringCN(@"beiziyifanghao", @"")];
            //  NSLog(@"杯子和杯盖都放好了。");
            return;
        }
        
    }
    if ([data hasPrefix:@"SBT:B9040001"]) {
        [BTConstants BTSetStatus:BTStatusReady];
        return;
    }
    
    if ([data hasPrefix:@"SBT:B90400"]) {
        if ([data hasPrefix:@"SBT:B9040010"] && [BTConstants BTConnected]) {
            
            [[BLESerialComManager sharedInstance] closePort:[BTConstants BTcurrentPort]];
            
            [BTConstants BTSetConnectedMachineName:@""];
            [BTConstants BTSetConnected:NO];
            [BTConstants BTSetCurrentPort:nil];
            [BTConstants BTSetAvailable:NO];
            [BTConstants BTSetStatus:BTStatusNotReady];
            
            [ProgressHUD showError:NSLocalizedStringCN(@"shebeiyiduankai", @"")];
            
            return;
        }
        
        if ([data hasPrefix:@"SBT:B9040002"]) {
            [BTConstants BTSetAvailable:NO];
        }
        else {
            [BTConstants BTSetAvailable:YES];
        }
    }
    
    if ([BTConstants BTStatus] == BTStatusRunning || [BTConstants BTStatus] == BTStatusReady) {
        if ([data length] >= 16 && [data hasPrefix:@"SBT:D207"]) {
            NSString *timeRemain = [data substringWithRange:NSMakeRange(11, 4)];
            
            NSLog(@"timeRemain = %@", timeRemain);
            
            if ([BTConstants BTStatus] == BTStatusRunning) {
                
                if ([BTConstants turnString2Time:timeRemain] == 0) {
                    [BTConstants BTSetStatus:BTStatusDone];
                }
            }
            else if ([BTConstants BTStatus] == BTStatusReady) {
                
                [BTConstants BTSetStatus:BTStatusRunning];
                
                /*
                 if ([BTConstants BTStepTotalTime] == 0) {
                 [BTConstants BTSetStepTotalTime:[BTConstants turnString2Time:timeRemain]];
                 [BTConstants BTSetStatus:BTStatusRunning];
                 }
                 */
            }
        }
    }
    
    if ([[BTConstants BTRequestType] isEqualToString:@"C7"]) {
        [BTConstants BTSetRequestType:@""];
        if ([data hasPrefix:@"SBT:BF02C7"] && _currentStepIndex != -1) {
            [self downloadStepToMachine];
        }
    }
    else if ([[BTConstants BTRequestType] isEqualToString:@"C2"]) {
        [BTConstants BTSetRequestType:@""];
        
        if ([data length] > 12) {
            if ([[data substringWithRange:NSMakeRange(0, 12)] isEqualToString:@"SBT:BF02C200"]) {
                [ProgressHUD showSuccess:NSLocalizedStringCN(@"xiafacaipuchenggong", @"")];
                
                if ([_stepArray count] != 0) {
                    [BTConstants BTSetStepTotalTime:[self getStepTotalTime:[_stepArray objectAtIndex:0]]];
                }
                 [MobClick event:@"liulanxiacaipu" label:self.name];
                [BTConstants BTSetStatus:BTStatusReady];
                [BTConstants BTSetCurrentRecipeName:self.name];
                [BTConstants BTSetCurrentRecipeImageName:self.mainimageView];
                
                [AppConstants setDownloadButtonPress2Pop:YES];
                
                [NSThread detachNewThreadSelector:@selector(timedPop) toTarget:self withObject:nil];
            }
            else {
                [ProgressHUD showError:NSLocalizedStringCN(@"xiafacaipushibai", @"")];
                
                [BTConstants BTSetStatus:BTStatusNotReady];
                [BTConstants BTSetCurrentRecipeName:@""];
                [BTConstants BTSetCurrentRecipeImageName:@""];
            }
        }
        [BTConstants BTSetDownloadingSteps:NO];
    }
    else if ([[BTConstants BTRequestType] isEqualToString:@"C5"]) {
        [BTConstants BTSetRequestType:@""];
        if ([data length] > 12) {
            if ([[data substringWithRange:NSMakeRange(0, 12)] isEqualToString:@"SBT:BF02C500"]) {
                [self downloadStepToMachine];
            }
            else {
                //                [ProgressHUD showError:@"申请下载菜谱失败"];
                [ProgressHUD showError:NSLocalizedStringCN(@"tishijiesuo", @"")];
                [BTConstants BTSetDownloadingSteps:NO];
                [BTConstants BTSetStatus:BTStatusNotReady];
                [BTConstants BTSetCurrentRecipeName:@""];
                [BTConstants BTSetCurrentRecipeImageName:@""];
            }
        }
    }
}

- (unsigned long)getStepTotalTime:(NSString*)stepStr {
    
    NSString *number1 = [stepStr substringWithRange:NSMakeRange(8, 1)];
    NSString *number2 = [stepStr substringWithRange:NSMakeRange(9, 1)];
    NSString *number3 = [stepStr substringWithRange:NSMakeRange(10, 1)];
    NSString *number4 = [stepStr substringWithRange:NSMakeRange(11, 1)];
    
    int totalTime = ([self turnString2Int:number1] * 16 * 16 * 16) + ([self turnString2Int:number2] * 16 * 16) + ([self turnString2Int:number3] * 16) + ([self turnString2Int:number4]);
    NSLog(@"stepStr = %@", stepStr);
    NSLog(@"totalTime = %d", totalTime);
    
    return totalTime;
}

- (int)turnString2Int:(NSString*)str {
    if ([str isEqualToString:@"A"] || [str isEqualToString:@"a"]) {
        return 10;
    }
    else if ([str isEqualToString:@"B"] || [str isEqualToString:@"b"]) {
        return 11;
    }
    else if ([str isEqualToString:@"C"] || [str isEqualToString:@"c"]) {
        return 12;
    }
    else if ([str isEqualToString:@"D"] || [str isEqualToString:@"d"]) {
        return 13;
    }
    else if ([str isEqualToString:@"E"] || [str isEqualToString:@"e"]) {
        return 14;
    }
    else if ([str isEqualToString:@"F"] || [str isEqualToString:@"f"]) {
        return 15;
    }
    else {
        return [str intValue];
    }
}
-(void)downloadStepToMachine
{
    if (_currentStepIndex == [_stepArray count]) {
        _currentStepIndex = -1;
        
        [BTConstants BTSetRequestType:@"C2"];
        [BTConstants sendCommand:[BTConstants C2_6]];
        
        return;
    }
    
    if (![[_stepArray objectAtIndex:_currentStepIndex] isEqualToString:@""]) {
        [BTConstants BTSetRequestType:@"C7"];
        [BTConstants sendCommand:[BTConstants C7:[_stepArray objectAtIndex:_currentStepIndex]]];
        
        _currentStepIndex++;
    }
}
#pragma mark QQ login message

- (void)tencentDidLogin {
    
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    
}

- (void)tencentDidNotNetWork {
    
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_messageInputView resignFirstResponder];
}

@end

