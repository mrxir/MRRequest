//
//  MRRequest.h
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MRRequestManager.h"
#import "MRRequestParameter.h"
#import "MRRequestDelegate.h"

FOUNDATION_EXPORT NSErrorDomain const MRRequestErrorDomain;

/**
 MRRequest 错误码
 
 - MRRequestErrorCodeGlobalInProcessingSameRequest:             通用错误码, 正在处理相同请求
 - MRRequestErrorCodeOAuthOrdinaryBusinessTolerableFailed:      OAuth错误码, 可容忍的普通业务失败, 不需要重新登录
 - MRRequestErrorCodeOAuthOrdinaryBusinessIntolerableFailed:    OAuth错误码, 不可容忍的普通业务失败, 需要重新登录
 - MRRequestErrorCodeOAuthRequestAccessTokenFailed:             OAuth错误码, 获取 access token 失败
 - MRRequestErrorCodeOAuthRefreshAccessTokenFailed:             OAuth错误码, 刷新 access token 失败
 */
typedef NS_ENUM(NSUInteger, MRRequestErrorCode) {
    
    
    MRRequestErrorCodeGlobalInProcessingSameRequest             = 7782001,
    
    MRRequestErrorCodeOAuthOrdinaryBusinessTolerableFailed      = 7782002,
    MRRequestErrorCodeOAuthOrdinaryBusinessIntolerableFailed    = 7782003,
    MRRequestErrorCodeOAuthRequestAccessTokenFailed             = 7782004,
    MRRequestErrorCodeOAuthRefreshAccessTokenFailed             = 7782005,
    MRRequestErrorCodeOAuthCredentialsConfigError               = 7782444,
    
};

typedef void(^Progress)(MRRequest *request, CGFloat progress);
typedef void(^Success)(MRRequest *request, id receiveObject);
typedef void(^Failure)(MRRequest *request, id requestObject, NSData *data, NSError *error);

@interface MRRequest : NSMutableURLRequest

@property (nonatomic, copy) Progress progress;
@property (nonatomic, copy) Success success;
@property (nonatomic, copy) Failure failure;

@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, strong, readonly) MRRequestParameter *parameter;
@property (nonatomic, weak, readonly) id <MRRequestDelegate> delegate;

#pragma mark - life cycle

- (instancetype)initWithPath:(NSString *)path parameter:(MRRequestParameter *)parameter delegate:(id <MRRequestDelegate>)delegate;

+ (void)requestWithPath:(NSString *)path
              parameter:(MRRequestParameter *)parameter
                success:(Success)success
                failure:(Failure)failure;

+ (void)requestWithPath:(NSString *)path
              parameter:(MRRequestParameter *)parameter
               progress:(Progress)progress
                success:(Success)success
                failure:(Failure)failure;

/**
 执行
 */
- (void)execute;

/**
 退出
 */
- (void)exit;

@end




@interface MRRequest (Extension)

@end



@interface MRRequest (OAuthPublicMethod)


/**
 开启oauth请求

 @param clientId 客户端ID
 @param clientSecret 客户端密钥
 @param autodestructTimeInterval 凭证自动销毁时间间隔
 @param error 开启失败的错误信息
 @return 是否开启成功
 */
+ (BOOL)enableOAuthRequestWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret autodestructTimeInterval:(NSTimeInterval)autodestructTimeInterval anyError:(NSError **)error;

#pragma mark - OAuth - 分析并返回oauth授权信息状态, 可以获得一份分析报告

/**
 OAuth - 分析并返回 oauth token 状态, 可以获得一份分析报告
 
 @param report 分析结果报告
 @return oauth token 状态
 */
+ (MROAuthTokenState)analyseOAuthTokenStateAndGenerateReport:(NSDictionary **)report;


@end



#pragma mark - OAuthSetting

@interface MRRequest (OAuthSetting)

#pragma mark - OAuth - oauth request 总开关

/**
 OAuth request 总开关

 @param enabled 是否开启, 默认关闭
 
 @Instructions: 当开启或关闭时, 会连锁的同步设置一系列开关
 
 *
 */
+ (void)setOAuthEnabled:(BOOL)enabled;
+ (BOOL)isOAuthEnabled;



#pragma mark - OAuth - 设置oauth客户端凭证信息

/**
 OAuth - 设置oauth客户端ID

 @param clientId ID
 */
+ (void)setOAuthClientId:(NSString *)clientId;
+ (NSString *)oAuthClientId;

/**
 OAuth - 设置oauth客户端密钥

 @param secret 密钥
 */
+ (void)setOAuthClientSecret:(NSString *)secret;
+ (NSString *)oAuthClientSecret;


#pragma mark - OAuth - oauth授权信息自动销毁时间间隔

/**
 OAuth - oauth授权信息自动销毁时间间隔

 @param timeInterval 时间间隔
 
 @Instructions:     相当于 refresh_token 可用时长, 设置授权状态强制性失效的时间间隔, 当从获取到授权到下一次使用或检测的时间不小于该时间间隔,
                    则会强制性的让授权失效(清空储存在NSUserdefault中的相关信息),
                    如果你设置了回调方法会同时执行回调方法.
                    如果你可以从其他途径或者从服务器来获取这个值, 那么当你在获取到之后需要进行设置, 否则请在使用前就进行设置,
                    这个值是一种约定成俗的为了保证授权安全的前提下又不必频繁更新的技术手段, 可能是1周或者1个月, 也有可能不到5分钟.
 *
 */
+ (void)setOAuthInfoAutodestructTimeInterval:(NSTimeInterval)timeInterval;
+ (NSTimeInterval)oAuthInfoAutodestructTimeInterval;



#pragma mark - OAuth - oauth授权信息周期性检查的开关

/**
 OAuth - oauth授权信息周期性检查的开关

 @param enabled 是否开启, 开关状态随着 isOAuthEnabled 同步, 可手动关闭
 
 @Instructions: 检查周期默认为 25秒(系统最小锁频时间为30秒), 正常网络情况下完成一次更新授权的耗时小于5秒.
 *
 */
+ (void)setOAuthStatePeriodicCheckEnabled:(BOOL)enabled;
+ (BOOL)isOAuthStatePeriodicCheckEnabled;



#pragma mark - OAuth - oauth授权信息周期性检查的时间间隔

/**
 OAuth - oauth授权信息周期性检查的时间间隔

 @param timeInterval 时间间隔, 如果不设置或设置为0, 则使用默认值 25秒
 */
+ (void)setOAuthStatePeriodicCheckTimeInterval:(NSTimeInterval)timeInterval;
+ (NSTimeInterval)oAuthStatePeriodicCheckTimeInterval;



#pragma mark - OAuth - 当一个oauth请求完成后是否检查oauth授权信息的开关

/**
 OAuth - 当一个oauth请求完成后是否检查 oauth授权信息的开关

 @param enabled 是否开启, 开关状态随着 isOAuthEnabled 同步, 可手动关闭
 */
+ (void)setOAuthStateAfterOrdinaryBusinessRequestCheckEnabled:(BOOL)enabled;
+ (BOOL)isOAuthStateAfterOrdinaryBusinessRequestCheckEnabled;



#pragma mark - OAuth - 当oauth授权信息不正常时执行框架预设方案的开关

/**
 OAuth - 当oauth授权信息不正常时执行框架预设方案的开关(access_token 失效时自动修复和自定义方法, 当 refresh_token 失效时执行自定义方法)
 
 @param enabled 是否开启, 开关状态随着 isOAuthEnabled 同步, 可手动关闭
 */
+ (void)setOAuthAutoExecuteTokenAbnormalPresetPlanEnabled:(BOOL)enabled;
+ (BOOL)isOAuthAutoExecuteTokenAbnormalPresetPlanEnabled;



#pragma mark - oauth授权信息不正常自定义方案代码块

/**
 OAuth - access_token授权信息不正常自定义方案代码块, 可以选择与框架默认预设进行替换或者两者保留.

 @param planBlock 代码块
 @param replaceOrKeepBoth 如果 YES 则用 planBlock 替换掉框架默认预设方法, NO 则两者保留, 即既执行框架预设也执行 planBlock
 */
+ (void)setOAuthAccessTokenAbnormalCustomPlanBlock:(dispatch_block_t)planBlock replaceOrKeepBoth:(BOOL)replaceOrKeepBoth;

/**
 OAuth - refresh_token授权信息不正常自定义方案代码块, 可以选择与框架默认预设进行替换或者两者保留.
 
 @param planBlock 代码块
 @param replaceOrKeepBoth 如果 YES 则用 planBlock 替换掉框架默认预设方法, NO 则两者保留, 即既执行框架预设也执行 planBlock
 */
+ (void)setOAuthRefreshTokenAbnormalCustomPlanBlock:(dispatch_block_t)planBlock replaceOrKeepBoth:(BOOL)replaceOrKeepBoth;

@end
