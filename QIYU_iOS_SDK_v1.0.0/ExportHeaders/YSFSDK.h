//
//  YSFSDK.h
//  YSFSDK
//
//  Created by amao on 8/25/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSFHeaders.h"

/**
 *  云商服完成回调
 */
typedef void(^YSFCompletionBlock)();


/**
 *  云商服SDK
 */
@interface YSFSDK : NSObject
/**
 *  返回 SDK 单例
 *
 *  @return SDK 单例
 */
+ (instancetype)sharedSDK;

/**
 *  注册SDK
 *
 *  @param appKey  appKey
 *  @param cerName 推送证书名
 */
- (void)registerAppId:(NSString *)appKey
              cerName:(NSString *)cerName;

/**
 *  追踪用户浏览信息
 *
 *  @param urlString  浏览url
 *  @param attributes 附加信息
 */
- (void)trackHistory:(NSString *)urlString
      withAttributes:(NSDictionary *)attributes;

/**
 *  添加个人信息
 *
 *  @param infos 个人信息
 */
- (void)addUserInfo:(NSDictionary *)infos;

/**
 *  更新推送token
 *
 *  @param token 推送token
 */
- (void)updateApnsToken:(NSData *)token;

/**
 *  注销当前账号
 *
 *  @param completion 完成回调
 */
- (void)logout:(YSFCompletionBlock)completion;

/**
 *  返回AppKey
 *
 *  @return appKey
 */
- (NSString *)appKey;

/**
 *  返回客服聊天ViewController
 *
 *  @return 会话ViewController
 */
- (YSFSessionViewController *)sessionViewController;

/**
 *  返回会话管理类
 *
 *  @return 会话管理类
 */
- (id<YSFConversationManager>)conversationManager;

@end
