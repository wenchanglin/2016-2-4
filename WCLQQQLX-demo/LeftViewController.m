//
//  LeftViewController.m
//  WCLMZJR-Demo
//
//  Created by wen on 16/5/17.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "LeftViewController.h"
#import "AppDelegate.h"
#import "WCLTabBarController.h"
#import "ImageTool.h"
@interface LeftViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSArray * _dataArray;
    UITableView * _tableview;
    UIButton * skipButton;
    NSMutableArray * _array;
}
@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _array = [NSMutableArray array];
    skipButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 70, 100, 100)];
    skipButton.layer.cornerRadius = 50;
    skipButton.layer.masksToBounds = YES;
    skipButton.layer.borderWidth = 0.7;
    [skipButton setImage:[UIImage imageNamed:@"headimage0.jpg"] forState:UIControlStateNormal];
    [skipButton setTitle:@"点击我设置头像" forState:UIControlStateNormal];
    [skipButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [skipButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipButton];

    _dataArray = @[@"开通会员",@"我的收藏",@"回到首页"];
    self.automaticallyAdjustsScrollViewInsets = NO;
   _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 170, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64-49) style:UITableViewStylePlain];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    //取消cell的下划线
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableview];
    [_tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
   
}
//相机实现方法
-(void)buttonClick:(UIButton *)button
{
    [self loadType:UIImagePickerControllerSourceTypePhotoLibrary];
}
-(void)loadType:(UIImagePickerControllerSourceType)type
{
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType = type;
    //允许后续对图片的编辑操作
    picker.allowsEditing = YES;
    //相册相机界面 都是模态出来的
    [self presentViewController:picker animated:YES completion:nil];
}


#pragma mark -调用相机协议
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    ImageTool * tool = [ImageTool shareTool];
    UIImage * newImage = [tool resizeImageToSize:CGSizeMake(200, 200) sizeOfImage:image];
    [skipButton setImage:newImage forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"点击相册界面取消按钮");
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
#pragma mark -表协议
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = _dataArray[indexPath.row];
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消反选
    [_tableview deselectRowAtIndexPath:indexPath animated:YES];
    NSString * title = _dataArray[indexPath.row];
//    //重新初始化主界面

    switch (indexPath.row) {
           
        case 0:
        {
//            FileViewController * file = [[FileViewController alloc]init];
//            mainNav = [[UINavigationController alloc]initWithRootViewController:file];
//            file.title = title;
        }
            break;
        case 1:
        {
//            VIPViewController * vip = [[VIPViewController alloc]init];
//            mainNav = [[UINavigationController alloc]initWithRootViewController:vip];
//            vip.title =title;
        }
            break;
     
        case 2://回到首页
        {
           // WCLTabBarController * main = [[WCLTabBarController alloc]init];
            //获取应用程序的window
           // AppDelegate * delegate = [UIApplication sharedApplication].delegate;
            //重新设置根视图
         //   delegate.ddMenuCotrol.rootViewController = main;
            
        }
            break;
        default:
            break;
    }
    
    
  
}

@end
