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

- (BOOL)activeOAuth:(NSError *__autoreleasing *)error
{
    NSString *server = [MROAuthRequestManager defaultManager].server;
    NSString *client_id = [MROAuthRequestManager defaultManager].client_id;
    NSString *client_secret = [MROAuthRequestManager defaultManager].client_secret;
    NSTimeInterval autodestruct = [MROAuthRequestManager defaultManager].oAuthInfoAutodestructTimeInterval;
    
    BOOL shouldActive = NO;
    
    if ([NSString isValidString:server]
        && [NSString isValidString:client_id]
        && [NSString isValidString:client_secret])
    {
        if (client_id.length >= 6
            && client_secret.length >= 6
            && autodestruct >= 10)
        {
            shouldActive = YES;
        }
    }
    
    if (shouldActive == NO) {
        
        if (error != nil) {
            
            *error = [NSError errorWithDomain:MRRequestErrorDomain
                                         code:666
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"OAuth信息设置有误, 请检查 😨", nil),
                                                @"config": @{@"server": [NSString stringWithFormat:@"%@", server],
                                                             @"client_id": [NSString stringWithFormat:@"%@", client_id],
                                                             @"client_secret": [NSString stringWithFormat:@"%@", client_secret],
                                                             @"autodestruct": @(autodestruct)}}];
            
            if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
                NSLog(@"[OAUTH] ❗️ %@", *error);
            }
            
        }
        
        self.oAuthEnabled = NO;
        
    } else {
        
        self.oAuthEnabled = YES;
    }
    
    return shouldActive;
    
}

- (void)deactiveOAuth
{
    self.oAuthEnabled = NO;
}

- (void)setOAuthEnabled:(BOOL)oAuthEnabled
{
    if (_oAuthEnabled != oAuthEnabled) {
        
        _oAuthEnabled = oAuthEnabled;
        
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelInfo) {
            
            if (_oAuthEnabled == YES) {
                NSLog(@"[OAUTH] 🔘🔘🔘 OAuth activated.");
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(didReceiveApplicationWillResignActiveNotification:)
                                                             name:UIApplicationWillResignActiveNotification
                                                           object:nil];
                
            } else {
                NSLog(@"[OAUTH] 🔘🔘🔘 OAuth deactivated.");
                
                [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
            }
            
        }
        
        [MROAuthRequestManager defaultManager].oAuthStateAfterOrdinaryBusinessRequestCheckEnabled = _oAuthEnabled;
        [MROAuthRequestManager defaultManager].oAuthAutoExecuteTokenAbnormalPresetPlanEnabled = _oAuthEnabled;
        
        
        
    }
   
}

- (void)didReceiveApplicationWillResignActiveNotification:(NSNotification *)notification
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[OAUTH] ▫️ %s", __FUNCTION__);
    }
    
    if (self.isThisApplicationHadEverBeenDepressed == NO) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveApplicationDidBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        _thisApplicationHadEverBeenDepressed = YES;
        
    }
    
}

- (void)didReceiveApplicationDidBecomeActiveNotification:(NSNotification *)notification
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[OAUTH] ▫️ %s", __FUNCTION__);
    }
    
    [[MROAuthRequestManager defaultManager] analyseOAuthTokenStateAndGenerateReport:nil];
    
}

@end




CGFloat const kAccessTokenDurabilityRate = 0.85f;
CGFloat const kRefreshTokenDurabilityRate = 1.0f;

@interface MROAuthRequestManager ()

@property (nonatomic, strong) NSTimer *oAuthStatePeriodicCheckTimer;

@property (nonatomic, assign, getter = isProcessingOAuthAbnormalPresetPlan) BOOL processingOAuthAbnormalPresetPlan;

@end

@implementation MROAuthRequestManager

#pragma mark - rewrite setter

- (void)setClient_id:(NSString *)client_id
{
    [MROAuthRequestManager setValue:client_id class:[NSString class] forKey:@"client_id"];
}

- (void)setClient_secret:(NSString *)client_secret
{
    [MROAuthRequestManager setValue:client_secret class:[NSString class] forKey:@"client_secret"];
}

- (void)setOAuthResultInfo:(NSDictionary *)oAuthResultInfo
{
    [MROAuthRequestManager setValue:oAuthResultInfo class:[NSDictionary class] forKey:@"oAuthResultInfo"];
}

- (void)setAccess_token:(NSString *)access_token
{
    [MROAuthRequestManager setValue:access_token class:[NSString class] forKey:@"access_token"];
}

- (void)setRefresh_token:(NSString *)refresh_token
{
    [MROAuthRequestManager setValue:refresh_token class:[NSString class] forKey:@"refresh_token"];
}

- (void)setExpires_in:(NSNumber *)expires_in
{
    [MROAuthRequestManager setValue:expires_in class:[NSNumber class] forKey:@"expires_in"];
}

- (void)setAccess_token_storage_date:(NSDate *)access_token_storage_date
{
    [MROAuthRequestManager setValue:access_token_storage_date class:[NSDate class] forKey:@"access_token_storage_date"];
}

- (void)setRefresh_token_storage_date:(NSDate *)refresh_token_storage_date
{
    [MROAuthRequestManager setValue:refresh_token_storage_date class:[NSDate class] forKey:@"refresh_token_storage_date"];
}

- (void)setOAuthStatePeriodicCheckTimeInterval:(NSTimeInterval)oAuthStatePeriodicCheckTimeInterval
{
    _oAuthStatePeriodicCheckTimeInterval = oAuthStatePeriodicCheckTimeInterval;
    
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelDebug) {
        NSLog(@"[OAUTH] ⚪️ OAuth state periodic check time interval is '%.2f'.", oAuthStatePeriodicCheckTimeInterval);
    }
    
    [self.oAuthStatePeriodicCheckTimer setFireDate:[NSDate distantFuture]];
    [self.oAuthStatePeriodicCheckTimer invalidate];
    self.oAuthStatePeriodicCheckTimer = nil;
    [self.oAuthStatePeriodicCheckTimer setFireDate:[NSDate distantFuture]];
    
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



#pragma mark - rewrite getter

- (NSString *)client_id
{
    return [MROAuthRequestManager valueForKey:@"client_id" class:[NSString class]];
}

- (NSString *)client_secret
{
    return [MROAuthRequestManager valueForKey:@"client_secret" class:[NSString class]];
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
        
        [_oAuthStatePeriodicCheckTimer setFireDate:[NSDate distantFuture]];
        
    }
    
    return _oAuthStatePeriodicCheckTimer;
}

- (NSDictionary *)oAuthResultInfo
{
    return [MROAuthRequestManager valueForKey:@"oAuthResultInfo" class:[NSDictionary class]];
}

- (NSString *)access_token
{
    return [MROAuthRequestManager valueForKey:@"access_token" class:[NSString class]];
}

- (NSString *)refresh_token
{
    return [MROAuthRequestManager valueForKey:@"refresh_token" class:[NSString class]];
}

- (NSNumber *)expires_in
{
    return [MROAuthRequestManager valueForKey:@"expires_in" class:[NSNumber class]];
}

- (NSDate *)access_token_storage_date
{
    return [MROAuthRequestManager valueForKey:@"access_token_storage_date" class:[NSDate class]];
}

- (NSDate *)refresh_token_storage_date
{
    return [MROAuthRequestManager valueForKey:@"refresh_token_storage_date" class:[NSDate class]];
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
                                          @"access_token_expires_in": self.expires_in,
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

        analysisInfo[@"oAuthResultInfo"] = oAuthResultInfo;
        analysisInfo[@"oAuthReportAccessTokenInfo"] = accessTokenInfo;
        analysisInfo[@"oAuthReportRefreshTokenInfo"] = refreshTokenInfo;
        
        *report = analysisInfo;
        
    }
    
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelDebug) {
        
        NSString *accessMark = isAccessInvalid == YES ? @"🚫" : @"✅";
        
        NSString *refreshMark = isRefreshInvalid == YES ? @"🚫" : @"✅";
        
        NSLog(@"[OAUTH] ⚪️ AK %010.2fs / %010.2fs %@ RK %010.2fs / %010.2fs %@",
              access_token_used_timeInterval, access_token_durability_timeInterval, accessMark,
              refresh_token_used_timeInterval, refresh_token_durability_timeInterval, refreshMark);
        
    }
    
    // result
    
    MROAuthTokenState tokenState = 0;
    
    if (isAccessInvalid == YES && isRefreshInvalid == YES) {
        tokenState = MROAuthTokenStateBothInvalid;
        
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelWarning) {
            NSLog(@"[OAUTH] ⚠️ Access_token and refresh_token are both invalid.");
        }
    }
    
    if (isAccessInvalid == NO && isRefreshInvalid == NO) {
        tokenState = MROAuthTokenStateBothAvailable;
    }
    
    if (isAccessInvalid == NO && isRefreshInvalid == YES) {
        tokenState = MROAuthTokenStateOnlyAccessTokenAvailable;
    }
    
    if (isAccessInvalid == YES && isRefreshInvalid == NO) {
        tokenState = MROAuthTokenStateOnlyRefreshTokenAvailable;
        
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelWarning) {
            NSLog(@"[OAUTH] ⚠️ Access_token is invalid.");
        }
    }
    
    
    // execute abnormal preset plan
    
    if (self.isOAuthAutoExecuteTokenAbnormalPresetPlanEnabled == YES) {
        
        // 仅执行自定义
        if (self.isOAuthAccessTokenAbnormalCustomPlanBlockReplaceOrKeepBoth == YES) {
            
            // 访问令牌失效
            if (tokenState == MROAuthTokenStateOnlyRefreshTokenAvailable) {
                [self executeCustomPresetPlanForAccessTokenAbnormal];
            }
            
            // 两者失效
            if (tokenState == MROAuthTokenStateBothInvalid) {
                [self executeCustomPresetPlanForRefreshTokenAbnormal];
            }
            
        // 执行框架和自定义
        } else {
            
            // 访问令牌失效
            if (tokenState == MROAuthTokenStateOnlyRefreshTokenAvailable) {
                [self executeFrameworkPresetPlanForAccessTokenAbnormal];
                [self executeCustomPresetPlanForAccessTokenAbnormal];
            }
            
            // 两者失效
            if (tokenState == MROAuthTokenStateBothInvalid) {
                [self executeFrameworkPresetPlanForRefreshTokenAbnormal];
                [self executeCustomPresetPlanForRefreshTokenAbnormal];
            }
            
        }
        
    }
    
    return tokenState;
}

#pragma mark - private method

+ (void)cleanUserDefaults
{
    
}

+ (void)setValue:(id)value class:(Class)aClass forKey:(NSString *)key
{
    if (![value isKindOfClass:aClass]) {
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelWarning) {
            NSLog(@"[NSUserDefaults] ⚠️ The object <%@: %p> %@ is not a kind of expected class <%@>.", aClass, value, value, aClass);
        }
    }
    
    if (value == nil && aClass == [NSString class]) value = @"";
    if (value == nil && aClass == [NSDictionary class]) value = @{};
    if (value == nil && aClass == [NSDate class]) value = [NSDate distantPast];
    if (value == nil && aClass == [NSNumber class]) value = @(0);
    
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelDebug) {
        
        NSLog(@"[OAUTH] ▫️ NSUserDefaults has changed \"%@\": %@", key, value);
        
    }
    
}

+ (id)valueForKey:(NSString *)key class:(Class)aClass
{
    id value = [[NSUserDefaults standardUserDefaults] valueForKey:key];
        
    if (value == nil && aClass == [NSString class]) value = @"";
    if (value == nil && aClass == [NSDictionary class]) value = @{};
    if (value == nil && aClass == [NSDate class]) value = [NSDate distantPast];
    if (value == nil && aClass == [NSNumber class]) value = @(0);
    
    return value;
}

- (void)didCallOAuthStatePeriodicCheckWithTimer:(NSTimer *)timer
{
    NSDictionary *report = nil;
    [self analyseOAuthTokenStateAndGenerateReport:&report];
    report = nil;
}

- (void)resumeOAuthStatePeriodicCheckTimer
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelInfo) {
        NSLog(@"[OAUTH] 🔘 OAuth state periodic check timer is resume.");
    }
    
    self.oAuthStatePeriodicCheckTimer.fireDate = [NSDate distantPast];
}

- (void)freezeOAuthStatePeriodicCheckTimer
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelDebug) {
        NSLog(@"[OAUTH] 🔘 OAuth state periodic check timer is freeze.");
    }
    
    self.oAuthStatePeriodicCheckTimer.fireDate = [NSDate distantFuture];
}

- (void)frameworkRefreshAccessToken
{
    MRRequestParameter *parameter = [[MRRequestParameter alloc] initWithObject:nil];
    parameter.oAuthIndependentSwitchState = YES;
    parameter.formattedStyle = MRRequestParameterFormattedStyleForm;
    parameter.requestMethod = MRRequestParameterRequestMethodPost;
    parameter.oAuthRequestScope = MRRequestParameterOAuthRequestScopeRefreshAccessToken;
    
    NSString *path = [MROAuthRequestManager defaultManager].server;
    
    self.processingOAuthAbnormalPresetPlan = YES;
    [MRRequest requestWithPath:path parameter:parameter success:^(MRRequest *request, id receiveObject) {
        
        self.processingOAuthAbnormalPresetPlan = NO;
        
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelInfo) {
            NSLog(@"[OAUTH] 🔘 Framework refresh access token succeeded ✅");
        }
        
    } failure:^(MRRequest *request, id requestObject, NSData *data, NSError *error) {
        
        self.processingOAuthAbnormalPresetPlan = NO;
        
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelInfo) {
            NSLog(@"[OAUTH] 🔘 Framework refresh access token failed ❌");
        }
        
        [self executeFrameworkPresetPlanForRefreshTokenAbnormal];
        
        if (self.isOAuthAutoExecuteTokenAbnormalPresetPlanEnabled == YES) {
            [self executeCustomPresetPlanForRefreshTokenAbnormal];
        }
        
    }];

}

#pragma mark - framework preset method

- (void)executeFrameworkPresetPlanForAccessTokenAbnormal
{
    if (self.isProcessingOAuthAbnormalPresetPlan == YES) return;
    
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelInfo) {
        NSLog(@"[OAUTH] 🔘 Execute framework access_token invalid plan.");
    }
    
    [self frameworkRefreshAccessToken];
    
}

- (void)executeFrameworkPresetPlanForRefreshTokenAbnormal
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelDebug) {
        NSLog(@"[OAUTH] 🔘 Execute framework refresh_token invalid plan.");
    }
    
    [MROAuthRequestManager cleanUserDefaults];
    
    [self freezeOAuthStatePeriodicCheckTimer];
    
}

- (void)executeCustomPresetPlanForAccessTokenAbnormal
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[OAUTH] 🔘 Execute custom access_token invalid plan.");
    }
    
    if (self.oAuthAccessTokenAbnormalCustomPlanBlock != nil) {
        self.oAuthAccessTokenAbnormalCustomPlanBlock();
    }
}

- (void)executeCustomPresetPlanForRefreshTokenAbnormal
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[OAUTH] 🔘 Execute custom refresh_token invalid plan.");
    }
    
    if (self.oAuthRefreshTokenAbnormalCustomPlanBlock != nil) {
        self.oAuthRefreshTokenAbnormalCustomPlanBlock();
    }
}

@end
