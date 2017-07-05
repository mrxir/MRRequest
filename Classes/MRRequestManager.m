//
//  MRRequestManager.m
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "MRRequestManager.h"

#import "MRRequest.h"

#import <MRFramework/NSString+Extension.h>

@class MROAuthRequestManager;

@implementation MRRequestManager

@synthesize processingRequestIdentifierSet = _processingRequestIdentifierSet;

+ (instancetype)defaultManager
{
    static MRRequestManager *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[MRRequestManager alloc] init];
    });
    return s_manager;
}

- (NSMutableSet *)processingRequestIdentifierSet
{
    if (!_processingRequestIdentifierSet) {
        _processingRequestIdentifierSet = [NSMutableSet set];
    }
    return _processingRequestIdentifierSet;
}

- (void)setOAuthEnabled:(BOOL)oAuthEnabled
{
    BOOL shouldEnabled = NO;
    
    NSString *clientId = [MROAuthRequestManager defaultManager].clientId;
    NSString *clientSecret = [MROAuthRequestManager defaultManager].clientSecret;
    NSTimeInterval autodestructTimeInterval = [MROAuthRequestManager defaultManager].oAuthInfoAutodestructTimeInterval;
    
    if ([NSString isValidString:clientId] && [NSString isValidString:clientSecret]) {
        
        if (clientId.length >= 6 && clientSecret.length >= 6) {
            
            if (autodestructTimeInterval >= 10) {
                
                shouldEnabled = YES;
                
            }
            
        }
        
    }
    
    if (shouldEnabled == NO) {
        
        NSError *error = [NSError errorWithDomain:MRRequestErrorDomain
                                             code:MRRequestErrorCodeOAuthCredentialsConfigError
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"客户端凭证有误, 请检查 😨", nil),
                                                    @"credentials": @{@"clientId": [NSString stringWithFormat:@"%@", clientId],
                                                                      @"clientSecret": [NSString stringWithFormat:@"%@", clientSecret],
                                                                      @"autodestructTimeInterval": @(autodestructTimeInterval)}}];
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
            NSLog(@"[OAUTH] %@", error);
        }
        
    } else {
        
        _oAuthEnabled = oAuthEnabled;
        
        [MROAuthRequestManager defaultManager].oAuthInfoAutodestructTimeInterval = autodestructTimeInterval;
        [MROAuthRequestManager defaultManager].oAuthStatePeriodicCheckEnabled = _oAuthEnabled;
        [MROAuthRequestManager defaultManager].oAuthStateAfterOrdinaryBusinessRequestCheckEnabled = _oAuthEnabled;
        [MROAuthRequestManager defaultManager].oAuthAutoExecuteTokenAbnormalPresetPlanEnabled = _oAuthEnabled;
        
        
    }
}



@end




CGFloat const kAccessTokenDurabilityRate = 0.85f;
CGFloat const kRefreshTokenDurabilityRate = 1.0f;

@interface MROAuthRequestManager ()

@property (nonatomic, strong) NSTimer *oAuthStatePeriodicCheckTimer;

@property (nonatomic, strong) NSDate *access_token_storage_date;

@property (nonatomic, strong) NSDate *refresh_token_storage_date;

@end

@implementation MROAuthRequestManager

#pragma mark - rewrite setter

- (void)setClientId:(NSString *)clientId
{
    [MROAuthRequestManager setValue:clientId forKey:@"clientId"];
}

- (void)setClientSecret:(NSString *)clientSecret
{
    [MROAuthRequestManager setValue:clientSecret forKey:@"clientSecret"];
}

- (void)setOAuthResultInfo:(NSDictionary *)oAuthResultInfo
{
    [MROAuthRequestManager setValue:oAuthResultInfo forKey:@"oAuthResultInfo"];
}

- (void)setAccess_token:(NSString *)access_token
{
    [MROAuthRequestManager setValue:access_token forKey:@"access_token"];
}

- (void)setRefresh_token:(NSString *)refresh_token
{
    [MROAuthRequestManager setValue:refresh_token forKey:@"refresh_token"];
}

- (void)setExpires_in:(NSNumber *)expires_in
{
    [MROAuthRequestManager setValue:expires_in forKey:@"expires_in"];
}

- (void)setAccess_token_storage_date:(NSDate *)access_token_storage_date
{
    [MROAuthRequestManager setValue:access_token_storage_date forKey:@"access_token_storage_date"];
}

- (void)setRefresh_token_storage_date:(NSDate *)refresh_token_storage_date
{
    [MROAuthRequestManager setValue:refresh_token_storage_date forKey:@"refresh_token_storage_date"];
}

- (void)setOAuthStatePeriodicCheckEnabled:(BOOL)oAuthStatePeriodicCheckEnabled
{
    _oAuthStatePeriodicCheckEnabled = oAuthStatePeriodicCheckEnabled;
    
    if (_oAuthStatePeriodicCheckEnabled == YES) {
        
        [self resumeOAuthStatePeriodicCheckTimer];
        
    } else {
        
        [self freezeOAuthStatePeriodicCheckTimer];
    }
}

- (void)setOAuthStatePeriodicCheckTimeInterval:(NSTimeInterval)oAuthStatePeriodicCheckTimeInterval
{
    _oAuthStatePeriodicCheckTimeInterval = oAuthStatePeriodicCheckTimeInterval;
    
    [self freezeOAuthStatePeriodicCheckTimer];
    
    self.oAuthStatePeriodicCheckTimer = nil;
    
    [self resumeOAuthStatePeriodicCheckTimer];
}

#pragma mark - rewrite getter

- (NSString *)clientId
{
    return [MROAuthRequestManager valueForKey:@"clientId"];
}

- (NSString *)clientSecret
{
    return [MROAuthRequestManager valueForKey:@"clientSecret"];
}

- (NSTimer *)oAuthStatePeriodicCheckTimer
{
    if (!_oAuthStatePeriodicCheckTimer) {
        _oAuthStatePeriodicCheckTimer =
        [NSTimer scheduledTimerWithTimeInterval:self.oAuthStatePeriodicCheckTimeInterval
                                         target:self
                                       selector:@selector(didCallOAuthStatePeriodicCheckWithTimer:)
                                       userInfo:nil
                                        repeats:YES];
        
        [self freezeOAuthStatePeriodicCheckTimer];
        
    }
    
    return _oAuthStatePeriodicCheckTimer;
}

- (NSDictionary *)oAuthResultInfo
{
    return [MROAuthRequestManager valueForKey:@"oAuthResultInfo"];
}

- (NSString *)access_token
{
    return [MROAuthRequestManager valueForKey:@"access_token"];
}

- (NSString *)refresh_token
{
    return [MROAuthRequestManager valueForKey:@"refresh_token"];
}

- (NSNumber *)expires_in
{
    return [MROAuthRequestManager valueForKey:@"expires_in"];
}

- (NSDate *)access_token_storage_date
{
    return [MROAuthRequestManager valueForKey:@"access_token_storage_date"];
}

- (NSDate *)refresh_token_storage_date
{
    return [MROAuthRequestManager valueForKey:@"refresh_token_storage_date"];
}

#pragma mark - public method

+ (instancetype)defaultManager
{
    static MROAuthRequestManager *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[MROAuthRequestManager alloc] init];
    });
    return s_manager;
}

- (void)updateOAuthArchiveWithResultDictionary:(NSDictionary *)dictionary requestScope:(MRRequestParameterOAuthRequestScope)scope;
{

    // 获取 access_token
    if (scope == MRRequestParameterOAuthRequestScopeRequestAccessToken) {
        
        NSDate *date = [NSDate date];
        
        self.oAuthResultInfo = dictionary;
        
        self.expires_in = dictionary[@"expires_in"];
        self.access_token = dictionary[@"access_token"];
        self.refresh_token = dictionary[@"refresh_token"];
        
        self.access_token_storage_date = date;
        self.refresh_token_storage_date = date;
        
    // 刷新 access_token
    } else if (scope == MRRequestParameterOAuthRequestScopeRefreshAccessToken) {
        
        NSDate *date = [NSDate date];

        self.oAuthResultInfo = dictionary;
        
        self.access_token = dictionary[@"access_token"];
        self.expires_in = dictionary[@"expires_in"];
        
        self.access_token_storage_date = date;
        
    }
    
    
}

/**
 检查 OAuth 授权状态并且在需要时执行预设方法
 */
- (MROAuthTokenState)analyseOAuthTokenStateAndGenerateReport:(NSDictionary *__autoreleasing *)report
{
    
    NSDate *date = [NSDate date];
    
    // analyse access token
    BOOL isAccessInvalid = NO;
    
    NSTimeInterval access_token_durability_timeInterval = 0;
    
    NSTimeInterval access_token_used_timeInterval = 0;
    
    NSTimeInterval access_token_usable_timeInterval = 0;
    
    if (self.access_token == nil) {
        
        isAccessInvalid = YES;
        
        self.access_token_storage_date = [NSDate distantPast];
        
    } else {
        
        access_token_durability_timeInterval = self.expires_in.doubleValue * kAccessTokenDurabilityRate;
        
        access_token_used_timeInterval = date.timeIntervalSinceReferenceDate - self.access_token_storage_date.timeIntervalSinceReferenceDate;
        
        access_token_usable_timeInterval = access_token_durability_timeInterval - access_token_used_timeInterval;
        
        isAccessInvalid = (access_token_durability_timeInterval == 0 || access_token_durability_timeInterval < access_token_used_timeInterval);
        
    }
    
    // analyse refresh token
    BOOL isRefreshInvalid = NO;
    
    NSTimeInterval refresh_token_durability_timeInterval = 0;
    
    NSTimeInterval refresh_token_used_timeInterval = 0;
    
    NSTimeInterval refresh_token_usable_timeInterval = 0;
    
    if (self.refresh_token == nil) {
        
        isRefreshInvalid = YES;
        
        self.refresh_token_storage_date = [NSDate distantPast];
        
    } else {
        
        refresh_token_durability_timeInterval = self.oAuthInfoAutodestructTimeInterval * kRefreshTokenDurabilityRate;
        
        refresh_token_used_timeInterval = date.timeIntervalSinceReferenceDate - self.refresh_token_storage_date.timeIntervalSinceReferenceDate;
        
        refresh_token_usable_timeInterval = refresh_token_durability_timeInterval - refresh_token_used_timeInterval;
        
        isRefreshInvalid = (refresh_token_durability_timeInterval == 0 || refresh_token_durability_timeInterval < refresh_token_used_timeInterval);
        
    }
    
    // report
    
    if (report != nil) {
        
        NSMutableDictionary *analysisInfo = [NSMutableDictionary dictionary];
        
        NSDictionary *oAuthResultInfo = [NSDictionary dictionaryWithDictionary:self.oAuthResultInfo];
        
        NSDictionary *accessTokenInfo = @{@"access_token_available": @(!isAccessInvalid),
                                          @"access_token_value": self.access_token,
                                          @"access_token_storage_date": self.access_token_storage_date,
                                          @"access_token_expires_in": oAuthResultInfo[@"expires_in"],
                                          @"access_token_durability_rate": @(kAccessTokenDurabilityRate),
                                          @"access_token_durability_timeInterval": @(access_token_durability_timeInterval),
                                          @"access_token_used_timeInterval": @(access_token_used_timeInterval),
                                          @"access_token_usable_timeInterval": @(access_token_usable_timeInterval)};
        
        NSDictionary *refreshTokenInfo = @{@"refresh_token_available": @(!isRefreshInvalid),
                                           @"refresh_token_value": self.refresh_token,
                                           @"refresh_token_storage_date": self.refresh_token_storage_date,
                                           @"refresh_token_expires_in": @(self.oAuthInfoAutodestructTimeInterval),
                                           @"refresh_token_durability_rate": @(kRefreshTokenDurabilityRate),
                                           @"refresh_token_durability_timeInterval": @(refresh_token_durability_timeInterval),
                                           @"refresh_token_used_timeInterval": @(refresh_token_used_timeInterval),
                                           @"refresh_token_usable_timeInterval": @(refresh_token_usable_timeInterval)};
        
        [analysisInfo setValue:oAuthResultInfo forKey:@"oAuthResultInfo"];
        
        [analysisInfo setValue:accessTokenInfo forKey:@"oAuthReportAccessTokenInfo"];
        
        [analysisInfo setValue:refreshTokenInfo forKey:@"oAuthReportRefreshTokenInfo"];
        
        *report = analysisInfo;
        
    }
    
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelDebug) {
        
        NSString *accessMark = isAccessInvalid == YES ? @"🚫" : @"✅";
        
        NSString *refreshMark = isRefreshInvalid == YES ? @"🚫" : @"✅";
        
        NSLog(@"[OAUTH] AK %010.2fs / %010.2fs %@ RK %010.2fs / %010.2fs %@",
              access_token_used_timeInterval, access_token_durability_timeInterval, accessMark,
              refresh_token_used_timeInterval, refresh_token_durability_timeInterval, refreshMark);
        
    }
    
    // result
    
    MROAuthTokenState tokenState = 0;
    
    if (isAccessInvalid == YES && isRefreshInvalid == YES) {
        tokenState = MROAuthTokenStateBothInvalid;
    }
    
    if (isAccessInvalid == NO && isRefreshInvalid == NO) {
        tokenState = MROAuthTokenStateBothAvailable;
    }
    
    if (isAccessInvalid == NO && isRefreshInvalid == YES) {
        tokenState = MROAuthTokenStateOnlyAccessTokenAvailable;
    }
    
    if (isAccessInvalid == YES && isRefreshInvalid == NO) {
        tokenState = MROAuthTokenStateOnlyRefreshTokenAvailable;
    }
    
    
    // execute abnormal preset plan
    
    if (self.isOAuthAutoExecuteTokenAbnormalPresetPlanEnabled == YES) {
        
        // 替换
        if (self.isOAuthAccessTokenAbnormalCustomPlanBlockReplaceOrKeepBoth == YES) {
            
            if (tokenState == MROAuthTokenStateOnlyAccessTokenAvailable || tokenState == MROAuthTokenStateBothInvalid) {
                [self executeCustomPresetPlanForRefreshTokenAbnormal];
            }
            
            if (tokenState == MROAuthTokenStateOnlyRefreshTokenAvailable) {
                if (self.isProcessingOAuthAbnormalPresetPlan == NO) {
                    [self executeCustomPresetPlanForAccessTokenAbnormal];
                } else {
                    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelDebug) {
                        NSLog(@"[OAUTH] The oauth manager is processing framework oauth access token abnormal preset plan now.");
                    }
                }
            }
            
            // 保留两者
        } else {
            
            if (tokenState == MROAuthTokenStateOnlyAccessTokenAvailable || tokenState == MROAuthTokenStateBothInvalid) {
                [self executeFrameworkPresetPlanForRefreshTokenAbnormal];
                [self executeCustomPresetPlanForRefreshTokenAbnormal];
                
            }
            
            if (tokenState == MROAuthTokenStateOnlyRefreshTokenAvailable) {
                if (self.isProcessingOAuthAbnormalPresetPlan == NO) {
                    [self executeFrameworkPresetPlanForAccessTokenAbnormal];
                    [self executeCustomPresetPlanForAccessTokenAbnormal];
                } else {
                    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelDebug) {
                        NSLog(@"[OAUTH] The oauth manager is processing framework oauth access token abnormal preset plan now.");
                    }
                }
            }
            
        }
        
    }
    
    return tokenState;
}

#pragma mark - private method

+ (void)setValue:(id)value forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)valueForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

- (void)didCallOAuthStatePeriodicCheckWithTimer:(NSTimer *)timer
{
    NSDictionary *report = nil;
    [self analyseOAuthTokenStateAndGenerateReport:&report];
    report = nil;
}

- (void)resumeOAuthStatePeriodicCheckTimer
{
    self.oAuthStatePeriodicCheckTimer.fireDate = [NSDate distantPast];
}

- (void)freezeOAuthStatePeriodicCheckTimer
{
    self.oAuthStatePeriodicCheckTimer.fireDate = [NSDate distantFuture];
}

#pragma mark - framework preset method

- (void)executeFrameworkPresetPlanForAccessTokenAbnormal
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[OAUTH] 执行框架预设_刷新授权信息");
    }
    
    self.processingOAuthAbnormalPresetPlan = YES;
}

- (void)executeFrameworkPresetPlanForRefreshTokenAbnormal
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[OAUTH] 执行框架预设_销毁授权信息");
    }
    
    [self freezeOAuthStatePeriodicCheckTimer];
    
    self.processingOAuthAbnormalPresetPlan = YES;
}

- (void)executeCustomPresetPlanForAccessTokenAbnormal
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[OAUTH] 执行自定义access_token失效预案");
    }
    
    if (self.oAuthAccessTokenAbnormalCustomPlanBlock != nil) {
        self.oAuthAccessTokenAbnormalCustomPlanBlock();
    }
}

- (void)executeCustomPresetPlanForRefreshTokenAbnormal
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[OAUTH] 执行自定义refresh_token失效预案");
    }
    
    if (self.oAuthRefreshTokenAbnormalCustomPlanBlock != nil) {
        self.oAuthRefreshTokenAbnormalCustomPlanBlock();
    }
}

@end
