//
//  SubViewController.m
//  WCLQQQLX-demo
//
//  Created by wen on 16/5/24.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "SubViewController.h"

#define imageNum 4
#define WIDTH self.view.bounds.size.width
#define HEIGHT self.view.bounds.size.height
@interface SubViewController ()<UIScrollViewDelegate>

@property(nonatomic,strong)UIPageControl * pageControl;

@end

@implementation SubViewController

-(void)loadView
{
    [super loadView];
    //图层一
    [self createAnimalView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //图层二
    [self createScrollView];
    [self createPageContorl];
}

#pragma make 创建app初始动画
-(void)createAnimalView
{
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageView setImage:[UIImage imageNamed:@"new_feature_background"]];
    [self.view addSubview:imageView];
    
    [self.view setUserInteractionEnabled:YES];
}

-(void)createScrollView
{
    UIScrollView *scrollView=[[UIScrollView alloc]initWithFrame:self.view.bounds];
    //设置imageView的范围
    [scrollView setContentSize:CGSizeMake(self.view.bounds.size.width*imageNum, 0)];
    
    //在滚动视图中添加image
    for (NSInteger i=0; i<imageNum; i++) {
        UIImageView *pageImageView=[[UIImageView alloc] initWithFrame:CGRectMake(i*WIDTH, 0, WIDTH, HEIGHT)];
        [pageImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"intro%zd.png",i]]];
        if (i==imageNum - 1) {
            //添加跳转的页面
            [self createSkipButton:pageImageView];
        }
        [scrollView addSubview:pageImageView];
    }
    [scrollView setPagingEnabled:YES];
    //弹性效果实效
    [scrollView setBounces:NO];
    //移除水平指示滚动
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    
    //设置代理,以便于滑动时改变pageControl
    [scrollView setDelegate:self];
    [self.view addSubview:scrollView];
}

#pragma make 创建pageContorl翻页指示器
-(void)createPageContorl
{
    _pageControl=[[UIPageControl alloc] init];
    //位置
    [_pageControl setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height * 0.9)];
    [_pageControl setNumberOfPages:imageNum];
    //设置指示器默认颜色
    [_pageControl setPageIndicatorTintColor:[UIColor grayColor]];
    //设置当前页指示器的颜色
    [_pageControl setCurrentPageIndicatorTintColor:[UIColor orangeColor]];
    [self.view addSubview:_pageControl];
}

#pragma mark 实现scrollView的代理方法
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x/scrollView.bounds.size.width;
    [_pageControl setCurrentPage:index];
}

#pragma mark 创建最后一页的“立即体验”按钮
-(void)createSkipButton:(UIImageView*)pageImageView{
    //父子视图交互开关，开启
    [pageImageView setUserInteractionEnabled:YES];
    UIButton * skipButton=[[UIButton alloc] init];
    //设置背景图片
//    UIImage *backImage=[UIImage imageNamed:@"new_feature_finish_button"];
//    [skipButton setBackgroundImage:backImage forState:UIControlStateNormal];
    
    [skipButton setTitle:NSLocalizedStringCN(@"mashangtiyan", @"") forState:UIControlStateNormal];
    [skipButton setTitleColor:[UIColor colorWithHexString:@"#FFD700"] forState:UIControlStateNormal];
    [skipButton setBackgroundColor:[UIColor blackColor]];
    //设置button位置，坐标
    [skipButton setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-100)/2, [UIScreen mainScreen].bounds.size.height-50, 100,40)];
    //[skipButton setCenter:CGPointMake(WIDTH/2, HEIGHT*0.95)];
    
    //消息响应
    [skipButton addTarget:self action:@selector(btClick) forControlEvents:UIControlEventTouchUpInside];
    //添加到pageImageView
    [pageImageView addSubview:skipButton];
    
}

-(void)btClick
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"tabbar" object:nil];
    //改变单例的值
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    [user setInteger:1 forKey:@"isLogin"];
    [user synchronize];//同步磁盘
}@end
