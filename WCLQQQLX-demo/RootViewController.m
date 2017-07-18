//
//  RootViewController.m
//  WCLQQQLX-demo
//
//  Created by wen on 16/5/24.
//  Copyright © 2016年 wen. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()
@property (nonatomic,strong) UIImageView *secondImagev;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor= [UIColor whiteColor];
    [self creatImageV];
    [self Animation];
}

- (void)creatImageV{
    [self requestLaunchImage];
    _secondImagev= [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _secondImagev.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_secondImagev];
    
    
    
}
-(void)requestLaunchImage
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    
    NSString *urlString = [NSString stringWithFormat:@"%@resource/SplashScreen/first/index.ashx", [AppConstants httpHeader]];
    [manager POST:urlString parameters:nil
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              NSLog(@"success urlString = %@", urlString);
              NSLog(@"Success: %@", responseObject);
              
              if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 1) {
                  NSArray *pics = [responseObject objectForKey:@"pics"];
                  
                  NSString *imageUrl = [[pics objectAtIndex:0] objectForKey:@"url"];
                  
                  if (![imageUrl isEqualToString:@""]) {
                      NSString * str = [NSString stringWithFormat:@"%@%@",[AppConstants httpServerIP],imageUrl];
                      NSLog(@"第一图%@",str);
                      [_secondImagev sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
                  }
              }
              else if ([((NSNumber*)[responseObject objectForKey:@"ok"]) intValue] == 0) {
                  NSLog(@"获取列表失败 %@", urlString);
                  
              }
              
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSLog(@"false urlString = %@", urlString);
              NSLog(@"Error: %@", error);
              
          }];
    
}
- (void)Animation{
    [UIView animateWithDuration:2.5f animations:^{
        
        _secondImagev.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 animations:^{
            _secondImagev.alpha = 0.f;
        } completion:^(BOOL finished) {
            [_secondImagev removeFromSuperview];
            [self.view removeFromSuperview];
        }];
    }];
}

@end
