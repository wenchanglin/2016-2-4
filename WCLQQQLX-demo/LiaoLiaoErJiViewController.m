//
//  SomePhotoViewController.m
//  歌力思
//
//  Created by greenis on 16/8/15.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "LiaoLiaoErJiViewController.h"
#import "MyLiaoLiaoTableViewCell.h"
#import "MyModel.h"
#import "MessageManagerFaceView.h"
#import "MessageInputView.h"
#import "MyTableViewCell.h"
#import "LiaoLiaoErJiFrameModel.h"
#import "Masonry.h"
@interface LiaoLiaoErJiViewController ()<UITableViewDelegate,UITableViewDataSource,MessageInputViewDelegate,MessageManagerFaceViewDelegate>
@property (strong, nonatomic) MessageInputView          *messageInputView;
@property (strong, nonatomic) MessageManagerFaceView    *faceView;
@property (nonatomic) CGRect                                    keyboardRect;
@property (nonatomic) double                                    animationDuration;
@property(nonatomic)BOOL isLikeable;
@property(nonatomic,strong) UIButton * shouChangButton;
@property(nonatomic,strong)NSString *urlString;
@property(nonatomic,strong) MyModel * Lmodel;
@end

@implementation LiaoLiaoErJiViewController
{
    UITableView * _tableView;
    NSMutableArray * _mArray;
    NSMutableArray * _commentArray;
    NSInteger _pageSize;//评论的页数
    
    
}
- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"viewWillDisappear");
    
    [super viewWillDisappear:animated];
    
    [ProgressHUD dismiss];
    _messageInputView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"commentPost" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)
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
    
    NSLog(@"show");
    _keyboardRect.size.height = 282;
    _keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _animationDuration= [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSLog(@"keyboardWillShow height = %f", _keyboardRect.size.height);
    
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [_messageInputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).with.offset(-_keyboardRect.size.height+50);
        }];
        [_messageInputView layoutIfNeeded];
    }completion:nil];
}

- (void)keyboardChange:(NSNotification *)notification{
    
    NSLog(@"keyboardChange");
    _keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSLog(@"keyboardChange");
    _keyboardRect.size.height =282;
    
    if ([[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y<CGRectGetHeight(self.view.frame)) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [_messageInputView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view).with.offset(-_keyboardRect.size.height);//-_keyboardRect.size.height-100
            }];
            _tableView.frame= CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-49 -_keyboardRect.size.height-70);
            [_messageInputView layoutIfNeeded];
            [_tableView layoutIfNeeded];
        }completion:nil];
    }
    NSLog(@"%f",_messageInputView.frame.origin.y);
    
}
-(void)faceViewChange:(NSNotification *)notification
{
    _keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSLog(@"detail页面faceViewChange");
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _pageSize  = 10;
    
    
    
    _commentArray = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendCommentPress) name:@"commentPost" object:nil];
    [self initMessageInputView];
    [self initFaceView];
    [self createTableView];
    [self requestComments];
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
    placeHolderLabel.text = NSLocalizedStringCN(@"shuojiju", "");
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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    NSString *urlString = [NSString stringWithFormat:@"%@interaction/forum/post/comment/list/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"page":@"1", @"pageSize":@"10", @"PostId":[NSString stringWithFormat:@"%zd", _model.id]};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"评论 urlString = %@", urlString);
              NSLog(@"评论Success: %@", responseObject);
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  [_commentArray removeAllObjects];
                  NSArray *comments = [responseObject objectForKey:@"comments"];
                  for (NSDictionary * dic in comments) {
                      _Lmodel = [[MyModel alloc]initWithDic:dic];
                      LiaoLiaoErJiFrameModel * erjiModel = [[LiaoLiaoErJiFrameModel alloc]init];
                      erjiModel.model = _Lmodel;
                      [_commentArray addObject:erjiModel];
                  }
                  
                  [_tableView reloadData];
              }
              else if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 0) {
                  NSLog(@"获取列表失败 %@", urlString);
                  
                  
              }
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"false urlString = %@", urlString);
              NSLog(@"Error: %@", error);
              
          }];
    
}
-(void)createTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64-49) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return 1;
    if (section==1) {
        
        return _commentArray.count;
    }
    else
    {
        return 1;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section ==1) {
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section],(long)[indexPath row]];//以indexPath来唯一确定cell
        MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //出列可重用的cell
        
        if(cell ==nil){
            
            cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        LiaoLiaoErJiFrameModel * erjimodel = _commentArray[indexPath.row];
        cell.LiaoLiaoFrameModel = erjimodel;
        
        return cell;
        
    }
    else
    {
        
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section],(long)[indexPath row]];//以indexPath来唯一确定cell
        MyLiaoLiaoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //出列可重用的cell
        
        if(cell ==nil){
            
            cell = [[MyLiaoLiaoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        LiaoLiaoGuangGaoDetailModel * model = _model;
        cell.model = model;
        cell.shouChangBtn.tag = indexPath.row+100;
        _shouChangButton = cell.shouChangBtn;
        if(_model.isThumbsup ==1){
            [_shouChangButton setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
            UIImageView * shoucImg = [[UIImageView alloc]init];
            shoucImg.image = [UIImage imageNamed:@"yizan"];
            [_shouChangButton setImage:[self scaleToSize:shoucImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
            [_shouChangButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
            _model.thumbsup_degree = [NSString stringWithFormat:@"%d",[_model.thumbsup_degree intValue]];
            [_shouChangButton setTitle:_model.thumbsup_degree forState:UIControlStateNormal];
            
        }
        else
        {
            if(_model.isThumbsup ==1){
                [_shouChangButton setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
                UIImageView * shoucImg = [[UIImageView alloc]init];
                shoucImg.image = [UIImage imageNamed:@"zan"];
                [_shouChangButton setImage:[self scaleToSize:shoucImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
                [_shouChangButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
                _model.thumbsup_degree = [NSString stringWithFormat:@"%d",[_model.thumbsup_degree intValue]-1 ];
                [_shouChangButton setTitle:_model.thumbsup_degree forState:UIControlStateNormal];
                
            }
        }
        [_shouChangButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}
-(void)btnClick:(UIButton *)button
{
    
    if (_model.isThumbsup ==1) {
        NSLog(@"你点击了取消收藏❤️ Thumbsup= %zd",_model.isThumbsup );
        _urlString = [NSString stringWithFormat:@"%@interaction/forum/post/unthumbsup/index.ashx", [AppConstants httpHeader]];
        [self like];
        
        
    }
    else
    {
        NSLog(@"你点击了收藏❤️Thumbsup=%zd",_model.isThumbsup);
        _urlString = [NSString stringWithFormat:@"%@interaction/forum/post/thumbsup/index.ashx", [AppConstants httpHeader]];//喜欢
        
        [self like];
        
    }
}


- (void)like {
    if ([[AppConstants userInfo].accessToken isEqualToString:@""]) {
        
        [ProgressHUD showError:NSLocalizedStringCN(@"dengluzaidianzan", @"")];
        
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    //    NSString *urlString = [NSString stringWithFormat:@"%@interaction/forum/post/thumbsup/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"AccessToken":[AppConstants userInfo].accessToken, @"PostId":[NSString stringWithFormat:@"%zd",_model.id]};
    
    [manager POST:_urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"点赞的urlString = %@", _urlString);
              NSLog(@"点赞的数据Success: %@", responseObject);
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  if(_model.isThumbsup ==1){
                      _model.isThumbsup = 0;
                      [_shouChangButton setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
                      UIImageView * shoucImg = [[UIImageView alloc]init];
                      shoucImg.image = [UIImage imageNamed:@"zan"];
                      [_shouChangButton setImage:[self scaleToSize:shoucImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
                      [_shouChangButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
                      _model.thumbsup_degree = [NSString stringWithFormat:@"%d",[_model.thumbsup_degree intValue]-1 ];
                      [_shouChangButton setTitle:_model.thumbsup_degree forState:UIControlStateNormal];
                      
                  }
                  else
                  {
                      _model.isThumbsup = 1;
                      [_shouChangButton setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
                      
                      UIImageView * shoucImg = [[UIImageView alloc]init];
                      shoucImg.image = [UIImage imageNamed:@"yizan"];
                      [_shouChangButton setImage:[self scaleToSize:shoucImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
                      [_shouChangButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
                      _model.thumbsup_degree = [NSString stringWithFormat:@"%d",[_model.thumbsup_degree intValue] +1];
                      [_shouChangButton setTitle:_model.thumbsup_degree forState:UIControlStateNormal];
                      
                  }
              }
              else if ([[responseObject objectForKey:@"errno"] isEqualToString:@"4401"]) {
                  [AppConstants relogin:^(BOOL success){
                      if (success) {
                          [self like];
                      }
                      else {
                          [AppConstants notice2ManualRelogin];
                      }
                  }];
              }
              else if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 0) {
                  if(_model.isThumbsup ==1){
                      _model.isThumbsup = 0;
                      [_shouChangButton setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
                      UIImageView * shoucImg = [[UIImageView alloc]init];
                      shoucImg.image = [UIImage imageNamed:@"zan"];
                      [_shouChangButton setImage:[self scaleToSize:shoucImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
                      [_shouChangButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
                      _model.thumbsup_degree = [NSString stringWithFormat:@"%d",[_model.thumbsup_degree intValue]-1];
                      [_shouChangButton setTitle:_model.thumbsup_degree forState:UIControlStateNormal];
                      
                  }
                  else
                  {
                      _model.isThumbsup =1;
                      [_shouChangButton setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
                      
                      UIImageView * shoucImg = [[UIImageView alloc]init];
                      shoucImg.image = [UIImage imageNamed:@"yizan"];
                      [_shouChangButton setImage:[self scaleToSize:shoucImg.image size:CGSizeMake(25, 25)] forState:UIControlStateNormal];
                      [_shouChangButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
                      _model.thumbsup_degree = [NSString stringWithFormat:@"%d",[_model.thumbsup_degree intValue]+1];
                      [_shouChangButton setTitle:_model.thumbsup_degree forState:UIControlStateNormal];
                      
                  }
                  
                  //                  [ProgressHUD showError:NSLocalizedStringCN(@"dianzanshibai", @"")];
                  //                  [_delegate postDetailCellChangeWithData:_data andIndex:_index];
              }
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"false urlString = %@", _urlString);
              NSLog(@"Error: %@", error);
              
              [ProgressHUD showError:NSLocalizedStringCN(@"badNetwork", @"")];
          }];
}
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        LiaoLiaoErJiFrameModel * erjimodel = _commentArray[indexPath.row];
        return erjimodel.cellHeight;
    }
    else{
        
        LiaoLiaoGuangGaoDetailModel * model = _model;
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
            
            return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/3*2)+40;
        }
        else if(_mArray.count==2)
        {
            return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/2)+40;
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
            return 110+contentH+40;
        }
        else
        {
            return 110+contentH+(([UIScreen mainScreen].bounds.size.width-60)/3)+(([UIScreen mainScreen].bounds.size.width-60)/3)+(([UIScreen mainScreen].bounds.size.width-60)/3)+5+40;
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
            
            //[_verticalScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            //    make.top.equalTo(self.view);
            //}];
            
            [_faceView layoutIfNeeded];
            [_messageInputView layoutIfNeeded];
            //[_verticalScrollView layoutIfNeeded];
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
                //                [_verticalScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
                //                    make.top.equalTo(self.view).with.offset(-196);
                //                }];
                [_faceView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.view.mas_bottom).with.offset(-196);
                }];
                
                [_messageInputView layoutIfNeeded];
                //[_verticalScrollView layoutIfNeeded];
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
                //                [_verticalScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
                //                    make.top.equalTo(self.view).with.offset(-_keyboardRect.size.height);
                //                }];
                [_faceView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.view.mas_bottom);
                }];
                
                [_messageInputView layoutIfNeeded];
                //[_verticalScrollView layoutIfNeeded];
                [_faceView layoutIfNeeded];
            }completion:nil];
        });
        
    }
}


- (void)sendComment:(NSString*)comment {
    
    
    if ([[AppConstants userInfo].accessToken isEqualToString:@""]) {
        
        [ProgressHUD showError:NSLocalizedStringCN(@"dengluzaipinglun", @"")];
        _tableView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-49-64);
        
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@interaction/forum/comment/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"AccessToken":[AppConstants userInfo].accessToken, @"PostId":[NSString stringWithFormat:@"%zd",_model.id], @"Content":comment};
    
    [manager POST:urlString parameters:parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"%@ Success: %@", urlString, responseObject);
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  [ProgressHUD showSuccess:NSLocalizedStringCN(@"pinglunchenggong", @"")];
                  
                  _tableView.frame= CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-49 -64);
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



#pragma mark - UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"dragging");
    
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


@end
