//
//  MRRequestManager.h
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "MRRequestParameter.h"

typedef NS_ENUM(NSUInteger, MRRequestLogLevel) {
    MRRequestLogLevelVerbose,
    MRRequestLogLevelDebug,
    MRRequestLogLevelInfo,
    MRRequestLogLevelWarning,
    MRRequestLogLevelError,
    MRRequestLogLevelNone,
};

@interface MRRequestManager : NSObject

@property (nonatomic, assign) MRRequestLogLevel logLevel;

@property (nonatomic, strong, readonly) NSMutableSet *processingRequestIdentifierSet;

@property (nonatomic, assign, getter = isOAuthEnabled) BOOL oAuthEnabled;

+ (instancetype)defaultManager;

@end



typedef NS_ENUM(NSUInteger, MROAuthTokenState) {
    MROAuthTokenStateBothInvalid = 1,
    MROAuthTokenStateBothAvailable = 2,
    MROAuthTokenStateOnlyAccessTokenAvailable = 3,
    MROAuthTokenStateOnlyRefreshTokenAvailable = 4,
};

@interface MROAuthRequestManager : MRRequestManager


/**
 oauth验证服务器地址
 */
@property (nonatomic, copy) NSString *server;

/**
 客户端ID
 */
@property (nonatomic, copy) NSString *client_id;

/**
 客户端secret
 */
@property (nonatomic, copy) NSString *client_secret;

/**
 oauth授权信息自动销毁时间间隔
 */
@property (nonatomic, assign) NSTimeInterval oAuthInfoAutodestructTimeInterval;

/**
 oauth授权信息周期性检查时间间隔
 */
@property (nonatomic, assign) NSTimeInterval oAuthStatePeriodicCheckTimeInterval;

/**
 oauth授权信息周期性检查开关
 */
@property (nonatomic, assign, getter = isOAuthStatePeriodicCheckEnabled) BOOL oAuthStatePeriodicCheckEnabled;

/**
 当一个oauth请求完成后是否检查oauth授权信息的开关
 */
@property (nonatomic, assign, getter = isOAuthStateAfterOrdinaryBusinessRequestCheckEnabled) BOOL oAuthStateAfterOrdinaryBusinessRequestCheckEnabled;

/**
 当oauth授权信息不正常时执行预设方案的开关
 */
@property (nonatomic, assign, getter = isOAuthAutoExecuteTokenAbnormalPresetPlanEnabled) BOOL oAuthAutoExecuteTokenAbnormalPresetPlanEnabled;

/**
 是否正在执行OAuth不正常预案中
 */
@property (nonatomic, assign, getter = isProcessingOAuthAbnormalPresetPlan) BOOL processingOAuthAbnormalPresetPlan;

/**
 access_token授权信息不正常自定义方案代码块
 */
@property (nonatomic, copy) dispatch_block_t oAuthAccessTokenAbnormalCustomPlanBlock;

/**
 access_token授权信息不正常自定义方案代码块是否与框架预设方案进行替换或保留两者, YES 替换, NO 保留两者
 */
@property (nonatomic, assign, getter = isOAuthAccessTokenAbnormalCustomPlanBlockReplaceOrKeepBoth) BOOL oAuthAccessTokenAbnormalCustomPlanBlockReplaceOrKeepBoth;

/**
 refresh_token授权信息不正常自定义方案代码块
 */
@property (nonatomic, copy) dispatch_block_t oAuthRefreshTokenAbnormalCustomPlanBlock;

/**
 refresh_token授权信息不正常自定义方案代码块是否与框架预设方案进行替换或保留两者, YES 替换, NO 保留两者
 */
@property (nonatomic, assign, getter = isOAuthRefreshTokenAbnormalCustomPlanBlockReplaceOrKeepBoth) BOOL oAuthRefreshTokenAbnormalCustomPlanBlockReplaceOrKeepBoth;

@property (nonatomic, strong) NSDictionary *oAuthResultInfo;

@property (nonatomic, copy) NSString *access_token;

@property (nonatomic, copy) NSString *refresh_token;

@property (nonatomic, strong) NSNumber *expires_in;

@property (nonatomic, strong) NSDate *access_token_storage_date;

@property (nonatomic, strong) NSDate *refresh_token_storage_date;

+ (instancetype)defaultManager;

- (void)updateOAuthArchiveWithResultDictionary:(NSDictionary *)dictionary requestScope:(MRRequestParameterOAuthRequestScope)scope;

- (MROAuthTokenState)analyseOAuthTokenStateAndGenerateReport:(NSDictionary **)report;

- (void)resumeOAuthStatePeriodicCheckTimer;

- (void)freezeOAuthStatePeriodicCheckTimer;

@end
