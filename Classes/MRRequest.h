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
 
 - MRRequestErrorCodeGlobalInvalidJSONSerializationFormat:      通用错误码, 不可用的JSON序列化格式
 - MRRequestErrorCodeGlobalInProcessingSameRequest:             通用错误码, 正在处理相同请求
 - MRRequestErrorCodeOAuthOrdinaryBusinessTolerableFailed:      OAuth错误码, 可容忍的普通业务失败, 不需要重新登录
 - MRRequestErrorCodeOAuthOrdinaryBusinessIntolerableFailed:    OAuth错误码, 不可容忍的普通业务失败, 需要重新登录
 - MRRequestErrorCodeOAuthRequestAccessTokenFailed:             OAuth错误码, 获取 access token 失败
 - MRRequestErrorCodeOAuthRefreshAccessTokenFailed:             OAuth错误码, 刷新 access token 失败
 */
typedef NS_ENUM(NSUInteger, MRRequestErrorCode) {
    
    MRRequestErrorCodeGlobalInvalidJSONSerializationFormat      = 7782000,
    MRRequestErrorCodeGlobalInProcessingSameRequest             = 7782001,
    
    MRRequestErrorCodeOAuthOrdinaryBusinessTolerableFailed      = 7782002,
    MRRequestErrorCodeOAuthOrdinaryBusinessIntolerableFailed    = 7782003,
    MRRequestErrorCodeOAuthRequestAccessTokenFailed             = 7782004,
    MRRequestErrorCodeOAuthRefreshAccessTokenFailed             = 7782005,
    
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



#pragma mark - default config

@interface MRRequest (DefaultConfig)

/**
 OAuth 当一次网络请求发起时, 是否对发出参数进行包装, 是否对返回结果进行处理

 @param enabled 是否开启, 默认关闭
 
 @Instructions: 当开启或关闭时, 会连锁的同步设置一系列开关
                [setOAuthStatePeriodicCheckEnabled]
                [setOAuthStateAfterOrdinaryBusinessRequestCheckEnabled]
                [setOAuthAutoRefreshAccessTokenWhenNecessaryEnabled]
 *
 */
+ (void)setOAuthEnabled:(BOOL)enabled;
+ (BOOL)isOAuthEnabled;

/**
 OAuth 当获取到授权后, 是否周期性对授权的可用性(是否过期或即将过期)进行检查

 @param enabled 是否开启, 开关状态随着 isOAuthEnabled 同步, 可手动关闭
 
 @Instructions: 检查周期默认为 25秒(系统最小锁频时间为30秒), 正常网络情况下完成一次更新授权的耗时小于5秒.
 *
 */
+ (void)setOAuthStatePeriodicCheckEnabled:(BOOL)enabled;
+ (BOOL)isOAuthStatePeriodicCheckEnabled;

/**
 OAuth 设置周期性检查授权状态的时间间隔, 如果需要更新授权状态, 则执行本框架默认的更新方法

 @param timeInterval 时间间隔, 如果不设置或设置为0, 则使用默认值 25秒
 */
+ (void)setOAuthStatePeriodicCheckTimeInterval:(NSTimeInterval)timeInterval;
+ (NSTimeInterval)oAuthStatePeriodicCheckTimeInterval;

/**
 OAuth 当普通(MRRequestParameterOAuthRequestScopeOrdinaryBusiness)的业务请求完成后, 是否对授权状态进行检查, 即检查凭证是否或即将过期

 @param enabled 是否开启, 开关状态随着 isOAuthEnabled 同步, 可手动关闭
 */
+ (void)setOAuthStateAfterOrdinaryBusinessRequestCheckEnabled:(BOOL)enabled;
+ (BOOL)isOAuthStateAfterOrdinaryBusinessRequestCheckEnabled;

/**
 OAuth 当进行了凭证状态检查后发现凭证即将过期或已过期时, 是否自动通过网络更新授权状态.

 @param enabled 是否开启, 开关状态随着 isOAuthEnabled 同步, 可手动关闭
 */
+ (void)setOAuthAutoRefreshAccessTokenWhenNecessaryEnabled:(BOOL)enabled;
+ (BOOL)isOAuthAutoRefreshAccessTokenWhenNecessaryEnabled;

/**
 OAuth  相当于 refresh_token 可用时长, 设置授权状态强制性失效的时间间隔, 当从获取到授权到下一次使用或检测的时间不小于该时间间隔, 则会强制性的让授权失效(清空储存在NSUserdefault中的相关信息),
        如果你设置了回调方法会同时执行回调方法.

 @param timeInterval 时间间隔, 如果不设置会设置为0, 则使用默认值 604800秒(7天)
 
 @Instructions: 如果你可以从其他途径或者从服务器来获取这个值, 那么当你在获取到之后需要进行设置, 否则请在使用前就进行设置, 
                这个值是一种约定成俗的为了保证授权安全的前提下又不必频繁更新的技术手段, 可能是1周或者1个月, 也有可能不到5分钟.
 *
 */
+ (void)setOAuthStateMandatoryInvalidTimeInterval:(NSTimeInterval)timeInterval;
+ (NSTimeInterval)oAuthStateMandatoryInvalidTimeInterval;


/**
 检查 OAuth access token 状态, 并且根据 ifNeed 决定是否执行预设方法

 @param ifNeed 是否执行预设方法
 @param report 检查报告
 @return access token 是否仍然可用
 */
+ (BOOL)checkOAuthAccessTokenStateAndExecutePresetMethodIfNeed:(BOOL)ifNeed checkReport:(NSDictionary **)report;

/**
 检查 OAuth refresh token 状态, 并且根据 ifNeed 决定是否执行预设方法
 
 @param ifNeed 是否执行预设方法
 @param report 检查报告
 @return refresh token 是否仍然可用
 */
+ (BOOL)checkOAuthRefreshTokenStateAndExecutePresetMethodIfNeed:(BOOL)ifNeed checkReport:(NSDictionary **)report;


@end
