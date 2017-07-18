//
//  FeedbackDetailViewController.m
//  SmartKitchen
//
//  Created by LICAN LONG on 16/1/30.
//  Copyright © 2016年 LICAN LONG. All rights reserved.
//

#import "FeedbackDetailViewController.h"
#import "Masonry.h"
#import "AppConstants.h"

@interface FeedbackDetailViewController ()

@property (strong, nonatomic) FeedbackDataModel *data;

@property (strong, nonatomic) UIScrollView                      *verticalScrollView;
@property (strong, nonatomic) UIView                            *verticalScrollViewContainer;

@end

@implementation FeedbackDetailViewController

- (instancetype)initWithData:(FeedbackDataModel*)data {
    self = [super init];
    if (self) {
        _data = data;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initVerticalScrollView];
    [self initViews];
}

- (void)initVerticalScrollView {
    _verticalScrollView = [UIScrollView new];
    _verticalScrollView.backgroundColor = [UIColor whiteColor];
    _verticalScrollView.scrollsToTop = YES;
    [self.view addSubview:_verticalScrollView];
    [_verticalScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _verticalScrollViewContainer = [UIView new];
    _verticalScrollViewContainer.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:234.0/255.0 blue:232.0/255.0 alpha:1.0];
    [_verticalScrollView addSubview:_verticalScrollViewContainer];
    [_verticalScrollViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_verticalScrollView);
        make.width.equalTo(_verticalScrollView);
    }];
}

- (void)initViews {
    UILabel *feedbackTime = [[UILabel alloc] init];
    feedbackTime.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedStringCN(@"feedbacktime", @""), _data.addtime];
    feedbackTime.font = [UIFont fontWithName:@"Arial" size:15.0];
    
    UILabel *feedbackContent = [[UILabel alloc] init];
    feedbackContent.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedStringCN(@"feedbackcontent", @""), _data.content];
    feedbackContent.numberOfLines = 0;
    feedbackContent.font = [UIFont fontWithName:@"Arial" size:15.0];
    
    UILabel *feedbackIsReply = [[UILabel alloc] init];
    feedbackIsReply.text = [NSString stringWithFormat:@"%@：", NSLocalizedStringCN(@"isreply", @"")];
    feedbackIsReply.font = [UIFont fontWithName:@"Arial" size:15.0];
    
    UILabel *feedbackResult = [[UILabel alloc] init];
    feedbackResult.font = [UIFont fontWithName:@"Arial" size:15.0];
    if ([_data.isReply isEqualToString:@"0"]) {
        feedbackResult.text = NSLocalizedStringCN(@"no", @"");
        feedbackResult.textColor = [UIColor redColor];
    }
    else {
        feedbackResult.text = NSLocalizedStringCN(@"yes", @"");
        feedbackResult.textColor = [AppConstants initUIColorWithInt:0x5E8A41];
    }
    
    UILabel *replyTime = [[UILabel alloc] init];
    replyTime.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedStringCN(@"replytime", @""), _data.replyTime];
//    replyTime.textColor = [AppConstants initUIColorWithInt:0x5E8A41];
    replyTime.font = [UIFont fontWithName:@"Arial" size:15.0];
    
    UILabel *replyContent = [[UILabel alloc] init];
    replyContent.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedStringCN(@"replycontent", @""), _data.replyContent];
//    replyContent.textColor = [AppConstants initUIColorWithInt:0x5E8A41];
    replyContent.numberOfLines = 0;
    replyContent.font = [UIFont fontWithName:@"Arial" size:15.0];
    
    [_verticalScrollViewContainer addSubview:feedbackTime];
    [_verticalScrollViewContainer addSubview:feedbackContent];
    [_verticalScrollViewContainer addSubview:feedbackIsReply];
    [_verticalScrollViewContainer addSubview:feedbackResult];
    [_verticalScrollViewContainer addSubview:replyTime];
    [_verticalScrollViewContainer addSubview:replyContent];
    
    [feedbackTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_verticalScrollViewContainer).with.offset(10);
        make.left.equalTo(_verticalScrollViewContainer).with.offset(20);
    }];
    
    [feedbackContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(feedbackTime.mas_bottom).with.offset(10);
        make.left.equalTo(feedbackTime);
        make.right.equalTo(_verticalScrollViewContainer).with.offset(-20);
    }];
    
    [feedbackIsReply mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(feedbackContent.mas_bottom).with.offset(10);
        make.left.equalTo(feedbackTime);
    }];
    
    [feedbackResult mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(feedbackIsReply);
        make.left.equalTo(feedbackIsReply.mas_right).with.offset(5);
    }];
    
    [replyTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(feedbackIsReply.mas_bottom).with.offset(10);
        make.left.equalTo(feedbackIsReply);
    }];
    
    [replyContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(replyTime.mas_bottom).with.offset(10);
        make.left.equalTo(feedbackTime);
        make.right.equalTo(_verticalScrollViewContainer).with.offset(-20);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
