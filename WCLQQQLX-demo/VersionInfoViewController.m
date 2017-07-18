//
//  VersionInfoViewController.m
//  歌力思
//
//  Created by wen on 16/7/26.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "VersionInfoViewController.h"

@interface VersionInfoViewController ()

@end

@implementation VersionInfoViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 80) / 2, 80, 80, 80)];
    imageView.image = [UIImage imageNamed:@"versonss.png"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UILabel *appNameLabel = [[UILabel alloc] init];
    appNameLabel.text = NSLocalizedStringCN(@"appname", @"");
    
    UILabel *versionLabel = [[UILabel alloc] init];
    versionLabel.text = @"V 4.1.9";
    versionLabel.textColor = [UIColor lightGrayColor];
    
    [self.view addSubview:imageView];
    [self.view addSubview:appNameLabel];
    [self.view addSubview:versionLabel];
    

    appNameLabel.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 80) / 2, CGRectGetMaxY(imageView.frame) + 15, 80, 30);
    appNameLabel.textAlignment = NSTextAlignmentCenter;

    versionLabel.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 80) / 2, CGRectGetMaxY(appNameLabel.frame) + 15, 80, 30);
    versionLabel.textAlignment = NSTextAlignmentCenter;
}


@end
