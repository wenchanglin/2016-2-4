//
//  XiGuaViewController.m
//  歌力思
//
//  Created by wen on 16/7/21.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "JiangLiaoViewController.h"
#import "ZhengWenModel.h"
#import "ZhengWenTableViewCell.h"
#import "DetailViewController.h"
#import "VideoCollectionViewCell.h"
#import "JiangLiaoCollectionReusableView.h"

@interface JiangLiaoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong) NSMutableArray *datasource;
@property (nonatomic,strong) UICollectionView *collectionV;
@property(nonatomic) CGRect tmpRect;
@end

@implementation JiangLiaoViewController
{
    NSInteger _page;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([AppConstants downloadButtonPress2Pop]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _page = 1;
    self.view.backgroundColor = [UIColor blackColor];
    self.title = self.naTitle;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"#CCCCCC"],NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    //设置导航栏的返回按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = item;
    //更改导航栏的返回图标"<"的颜色
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"#CCCCCC"];
    self.datasource = [NSMutableArray array];
    [self createCollectionView];
    [self requestData];
    
}

- (void)requestData {
   [ProgressHUD show:NSLocalizedStringCN(@"loading", @"")];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@resource/article/detail/index.ashx", [AppConstants httpHeader]];
    
    NSDictionary *parameters = @{@"ArticleId":_articleid, @"page":[NSString stringWithFormat:@"%zd", _page], @"pageSize":@"10"};
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"6个分类%@",responseObject);
        if ([((NSNumber *)[responseObject objectForKey:@"ok"]) intValue] == 1)
        {
            NSArray *formulas = [responseObject objectForKey:@"formulas"];
            for (NSDictionary *dic in formulas)
            {
                ZhengWenModel *model = [ZhengWenModel modelWith:dic];
                [self.datasource addObject:model];
               
            }
            
        }
        [self.collectionV reloadData];
        [ProgressHUD dismiss];
//        [self createCollectionView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}

-(void)createCollectionView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //更改item的大小
    layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / 2 - 10, ([UIScreen mainScreen].bounds.size.width / 2 ) / 800 * 533 + 35);
    
    layout.minimumInteritemSpacing = 5;
    
    //设置layout的代理
    //    layout.
    self.collectionV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64-29) collectionViewLayout:layout];
    self.collectionV.backgroundColor = [UIColor colorWithHexString:@"#1e1e1e"];
    //将其添加到根视图上
    [self.view addSubview:self.collectionV];
    //设置UICollectionView的代理
    self.collectionV.delegate = self;
    self.collectionV.dataSource = self;
    //    //设置header和footer的大小
    UIFont *fnt = [UIFont systemFontOfSize:15];
    // iOS7中用以下方法替代过时的iOS6中的sizeWithFont:constrainedToSize:lineBreakMode:方法
    _tmpRect = [self.zhaiyao boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt,NSFontAttributeName, nil] context:nil];
    layout.headerReferenceSize = CGSizeMake(0, _tmpRect.size.height+[UIScreen mainScreen].bounds.size.width/690*460+15);
    //    layout.footerReferenceSize = CGSizeMake(0, 30);
    //注册cell
    [self.collectionV registerClass:[VideoCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    //    //注册header
    [self.collectionV registerClass:[JiangLiaoCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
        //注册footer
    //    [collectionV registerClass:[FooterCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
}
#pragma mark - UICollectionViewDataSource
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
     UICollectionReusableView *reusableview = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        

       JiangLiaoCollectionReusableView *headerView  = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        NSString * imageStr = [NSString stringWithFormat:@"%@%@",[AppConstants httpChinaAndEnglishForHead],self.ImgUrl];
        [headerView.headImage setImageWithURL:[NSURL URLWithString:imageStr] placeholder:[UIImage imageNamed:@"placeholder.jpg"]];
        headerView.titles.frame = CGRectMake(10, CGRectGetMaxY(headerView.headImage.frame) + 5, [UIScreen mainScreen].bounds.size.width - 20, _tmpRect.size.height);
        //headerView.titles.textAlignment = NSTextAlignmentCenter;
        headerView.titles.text = self.zhaiyao;
        headerView.titles.font = [UIFont systemFontOfSize:12.0];
        headerView.titles.textColor = [UIColor colorWithHexString:@"#808080"];
        reusableview = headerView;
    }
    return reusableview;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return self.datasource.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VideoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    ZhengWenModel * model =_datasource[indexPath.row];
        cell.model= model;
        cell.backgroundColor = [UIColor colorWithHexString:@"#2b2b2b"];
        return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    ZhengWenModel * model = self.datasource[indexPath.row];
    DetailViewController * detail = [[DetailViewController alloc]init];
   
    if (![model.share_url isEqualToString:@""]) {
        detail.shareUrl = model.share_url;
    } else {
        model.share_url = @"http://greenishome.com/";
        detail.shareUrl = model.share_url;
    }
    detail.formulaId = model.FormulaID;
    detail.name = model.FormulaName;
    detail.mainimageView = model.ImgUrl;
    detail.detailStr = model.Introduction;
    detail.videoUrl = model.VideoUrl;
    detail.caiLiaoStr = model.Ingredients;
    detail.steps = model.Steps;
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detail animated:YES];
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(5,7, 5, 7);
}






@end

