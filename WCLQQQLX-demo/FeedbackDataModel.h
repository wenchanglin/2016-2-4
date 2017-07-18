//
//  FeedbackDataModel.h
//  SmartKitchen
//
//  Created by LICAN LONG on 16/1/30.
//  Copyright © 2016年 LICAN LONG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedbackDataModel : NSObject

@property (strong,nonatomic) NSString  *addtime;
@property (strong,nonatomic) NSString  *content;
@property (strong,nonatomic) NSString  *Id;
@property (strong,nonatomic) NSString  *isReply;
@property (strong,nonatomic) NSString  *replyContent;
@property (strong,nonatomic) NSString  *replyTime;

@end
