//
//  MRRequestManager.m
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "MRRequestManager.h"

#import <UIKit/UIKit.h>

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
    _oAuthEnabled = oAuthEnabled;
    
    [MROAuthRequestManager defaultManager].oAuthStateMandatoryInvalidTimeInterval =
    ([MROAuthRequestManager defaultManager].oAuthStateMandatoryInvalidTimeInterval == 0 ?
     604800.0f : [MROAuthRequestManager defaultManager].oAuthStateMandatoryInvalidTimeInterval);
    
    [MROAuthRequestManager defaultManager].oAuthStatePeriodicCheckEnabled = _oAuthEnabled;
    
    [MROAuthRequestManager defaultManager].oAuthStateAfterOrdinaryBusinessRequestCheckEnabled = _oAuthEnabled;
    
    [MROAuthRequestManager defaultManager].oAuthautoRefreshAccessTokenWhenNecessaryEnabled = _oAuthEnabled;
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

@synthesize oAuthStatePeriodicCheckTimer = _oAuthStatePeriodicCheckTimer;

+ (instancetype)defaultManager
{
    static MROAuthRequestManager *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[MROAuthRequestManager alloc] init];
    });
    return s_manager;
}

- (void)updateOAuthArchiveWithResultDictionary:(NSDictionary *)dictionary
{
    NSLog(@"%s", __FUNCTION__);
    
    self.oAuthResultInfo = dictionary;
    
    NSDate *systemDate = [NSDate date];
    
    NSDictionary *oAuthResultInfo = dictionary;
    
    self.access_token = oAuthResultInfo[@"access_token"];
    self.access_token_storage_date = systemDate;
    
    self.refresh_token = oAuthResultInfo[@"refresh_token"];
    self.refresh_token_storage_date = systemDate;
    
    self.expires_in = oAuthResultInfo[@"expires_in"];
    
}

#pragma mark - rewrite setter

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

- (void)setOAuthStateAfterOrdinaryBusinessRequestCheckEnabled:(BOOL)oAuthStateAfterOrdinaryBusinessRequestCheckEnabled
{
    _oAuthStateAfterOrdinaryBusinessRequestCheckEnabled = oAuthStateAfterOrdinaryBusinessRequestCheckEnabled;
}

- (void)setOAuthautoRefreshAccessTokenWhenNecessaryEnabled:(BOOL)oAuthautoRefreshAccessTokenWhenNecessaryEnabled
{
    _oAuthautoRefreshAccessTokenWhenNecessaryEnabled = oAuthautoRefreshAccessTokenWhenNecessaryEnabled;
}

#pragma mark - rewrite getter

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

- (NSTimer *)oAuthStatePeriodicCheckTimer
{
    if (!_oAuthStatePeriodicCheckTimer) {
        _oAuthStatePeriodicCheckTimer =
        [NSTimer scheduledTimerWithTimeInterval:(self.oAuthStatePeriodicCheckTimeInterval == 0 ? 25.0f : self.oAuthStatePeriodicCheckTimeInterval)
                                         target:self
                                       selector:@selector(checkOAuthStateAndExecutePresetMethodIfNeed:checkOption:checkResult:)
                                       userInfo:nil
                                        repeats:YES];
        
        [self freezeOAuthStatePeriodicCheckTimer];
        
    }
    
    return _oAuthStatePeriodicCheckTimer;
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

- (void)resumeOAuthStatePeriodicCheckTimer
{
    self.oAuthStatePeriodicCheckTimer.fireDate = [NSDate distantPast];
}

- (void)freezeOAuthStatePeriodicCheckTimer
{
    self.oAuthStatePeriodicCheckTimer.fireDate = [NSDate distantFuture];
}

#pragma mark - public method

/**
 检查 OAuth 授权状态并且在需要时执行预设方法
 */
- (BOOL)checkOAuthStateAndExecutePresetMethodIfNeed:(id)sender checkOption:(MROAuthStateCheckOption)option checkResult:(NSDictionary **)result
{
    
    NSDate *systemDate = [NSDate date];
    
    // check if access_token exist or expired
    
    BOOL is_access_token_invalid = NO;

    if (self.access_token == nil) {
        
        is_access_token_invalid = YES;
        
        self.access_token_storage_date = [NSDate distantPast];
        
        if (option == MROAuthStateCheckOptionCheckAccessToken) {
            
            NSMutableDictionary *oAuthResultInfo = [NSMutableDictionary dictionaryWithDictionary:self.oAuthResultInfo];
            
            NSDictionary *addition = @{@"+_refresh_token_expires_in": @(self.oAuthStateMandatoryInvalidTimeInterval),
                                       @"+_access_token_available": @(!is_access_token_invalid),
                                       @"+_access_token_durability_rate": @(kAccessTokenDurabilityRate),
                                       @"+_access_token_durability_timeInterval": @(0),
                                       @"+_access_token_storage_date": self.access_token_storage_date,
                                       @"+_access_token_used_timeInterval": @(0),
                                       @"+_access_token_usable_timeInterval": @(0)};
            
            [oAuthResultInfo setValuesForKeysWithDictionary:addition];
            
            *result = oAuthResultInfo;
            
        }
        
    } else {
        
        NSTimeInterval access_token_durability_timeInterval = self.expires_in.doubleValue * kAccessTokenDurabilityRate;
        
        NSTimeInterval access_token_used_timeInterval = systemDate.timeIntervalSinceReferenceDate - self.access_token_storage_date.timeIntervalSinceReferenceDate;
        
        NSTimeInterval access_token_usable_timeInterval = access_token_durability_timeInterval - access_token_used_timeInterval;
        
        is_access_token_invalid = (access_token_durability_timeInterval == 0 || access_token_durability_timeInterval < access_token_used_timeInterval);
        
        if (option == MROAuthStateCheckOptionCheckAccessToken) {
            
            NSMutableDictionary *oAuthResultInfo = [NSMutableDictionary dictionaryWithDictionary:self.oAuthResultInfo];
            
            NSDictionary *addition = @{@"+_refresh_token_expires_in": @(self.oAuthStateMandatoryInvalidTimeInterval),
                                       @"+_access_token_available": @(!is_access_token_invalid),
                                       @"+_access_token_durability_rate": @(kAccessTokenDurabilityRate),
                                       @"+_access_token_durability_timeInterval": @(access_token_durability_timeInterval),
                                       @"+_access_token_storage_date": self.access_token_storage_date,
                                       @"+_access_token_used_timeInterval": @(access_token_used_timeInterval),
                                       @"+_access_token_usable_timeInterval": @(access_token_usable_timeInterval)};
            
            [oAuthResultInfo setValuesForKeysWithDictionary:addition];
            
            *result = oAuthResultInfo;
            
        }
        
    }
    
    
    
    // check if refresh_token exist or expired
    
    BOOL is_refresh_token_invalid = NO;

    if (self.refresh_token == nil) {
        
        is_refresh_token_invalid = YES;
        
        self.refresh_token_storage_date = [NSDate distantPast];
        
        if (option == MROAuthStateCheckOptionCheckRefreshToken) {
            
            NSMutableDictionary *oAuthResultInfo = [NSMutableDictionary dictionaryWithDictionary:self.oAuthResultInfo];
            
            NSDictionary *addition = @{@"+_refresh_token_expires_in": @(self.oAuthStateMandatoryInvalidTimeInterval),
                                       @"+_refresh_token_available": @(!is_refresh_token_invalid),
                                       @"+_refresh_token_durability_rate": @(kRefreshTokenDurabilityRate),
                                       @"+_refresh_token_durability_timeInterval": @(0),
                                       @"+_refresh_token_storage_date": self.refresh_token_storage_date,
                                       @"+_refresh_token_used_timeInterval": @(0),
                                       @"+_refresh_token_usable_timeInterval": @(0)};
            
            [oAuthResultInfo setValuesForKeysWithDictionary:addition];
            
            *result = oAuthResultInfo;
            
        }
        
    } else {
        
        NSTimeInterval refresh_token_durability_timeInterval = (self.oAuthStateMandatoryInvalidTimeInterval == 0 ?
                                                                604800.0f : self.oAuthStateMandatoryInvalidTimeInterval) * kRefreshTokenDurabilityRate;
        
        NSTimeInterval refresh_token_used_timeInterval = systemDate.timeIntervalSinceReferenceDate - self.refresh_token_storage_date.timeIntervalSinceReferenceDate;
        
        NSTimeInterval refresh_token_usable_timeInterval = refresh_token_durability_timeInterval - refresh_token_used_timeInterval;
        
        is_refresh_token_invalid = (refresh_token_durability_timeInterval == 0 || refresh_token_durability_timeInterval < refresh_token_used_timeInterval);
        
        if (option == MROAuthStateCheckOptionCheckRefreshToken) {
            
            NSMutableDictionary *oAuthResultInfo = [NSMutableDictionary dictionaryWithDictionary:self.oAuthResultInfo];
            
            NSDictionary *addition = @{@"+_refresh_token_expires_in": @(self.oAuthStateMandatoryInvalidTimeInterval),
                                       @"+_refresh_token_available": @(!is_refresh_token_invalid),
                                       @"+_refresh_token_durability_rate": @(kRefreshTokenDurabilityRate),
                                       @"+_refresh_token_durability_timeInterval": @(refresh_token_durability_timeInterval),
                                       @"+_refresh_token_storage_date": self.refresh_token_storage_date,
                                       @"+_refresh_token_used_timeInterval": @(refresh_token_used_timeInterval),
                                       @"+_refresh_token_usable_timeInterval": @(refresh_token_usable_timeInterval)};
            
            [oAuthResultInfo setValuesForKeysWithDictionary:addition];
            
            *result = oAuthResultInfo;
            
        }
        
    }
    
    
    BOOL ifNeed = self.isOAuthAutoRefreshAccessTokenWhenNecessaryEnabled;
    if ([sender isKindOfClass:[NSNumber class]]) {
        ifNeed = [sender boolValue];
    }
    
    if (is_access_token_invalid == YES && is_refresh_token_invalid == NO) {
        NSLog(@"The access_token is invalid, but the refresh_token is available.");
        
        if (ifNeed == YES) {
            [self executeFrameworkPresetMethodRefreshNewAccessToken];
        }
        
        
    }
    
    if (is_refresh_token_invalid == YES) {
        NSLog(@"The refresh_token is invalid.");
        
        if (ifNeed == YES) {
            [self executeFrameworkPresetMethodRequestNewAccessToken];
        }
        
    }
    
    
    if (is_access_token_invalid == NO && is_refresh_token_invalid == NO) {
        NSLog(@"The access_token and refresh_token are both available.");
    }
    
    BOOL isAvailable = NO;
    
    if (option == MROAuthStateCheckOptionCheckAccessToken) {
        isAvailable = !is_access_token_invalid;
    }
    
    if (option == MROAuthStateCheckOptionCheckRefreshToken) {
        isAvailable = !is_refresh_token_invalid;
    }

    
    return isAvailable;
    
}

#pragma mark - framework preset method

- (void)executeFrameworkPresetMethodRequestNewAccessToken
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)executeFrameworkPresetMethodRefreshNewAccessToken
{
    NSLog(@"%s", __FUNCTION__);
}

@end
