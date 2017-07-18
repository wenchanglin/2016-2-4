//
//  IMViewController.m
//  Greenis
//
//  Created by greenis on 16/10/8.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "IMViewController.h"
#import "QunViewController.h"
#import "WCLNavigationController.h"
@interface IMViewController ()

@end
@implementation IMViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title=@"单聊";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"#CCCCCC"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"<<" style:UIBarButtonItemStylePlain target:self action:@selector(dimiSelf)];
//    UIImageView * imaview = [[UIImageView alloc]initWithFrame:self.view.bounds];
//    [self.view addSubview:imaview];
//    UITapGestureRecognizer * dianji = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(push:)];
//    [imaview addGestureRecognizer:dianji];
//    imaview.image  = [UIImage imageNamed:@"huanyingye.jpg"];

    UIButton * byt = [[UIButton alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:byt];
    [byt setTitle:@"点我" forState:UIControlStateNormal];
    [byt addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside];
}
-(void)push
{
    QunViewController * qun = [[QunViewController alloc]init];
    [self.navigationController pushViewController:qun animated:YES];
}
-(void)dimiSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
