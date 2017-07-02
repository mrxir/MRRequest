//
//  MRRequestManager.h
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRRequestManager : NSObject

@property (nonatomic, strong, readonly) NSMutableSet *processingRequestIdentifierSet;

@property (nonatomic, assign, getter = isOAuthEnabled) BOOL oAuthEnabled;

+ (instancetype)defaultManager;

@end



typedef NS_ENUM(NSUInteger, MROAuthStateCheckOption) {
    MROAuthStateCheckOptionCheckAccessToken,
    MROAuthStateCheckOptionCheckRefreshToken,
};

@interface MROAuthRequestManager : MRRequestManager

@property (nonatomic, assign, getter = isOAuthStatePeriodicCheckEnabled) BOOL oAuthStatePeriodicCheckEnabled;

@property (nonatomic, assign) NSTimeInterval oAuthStatePeriodicCheckTimeInterval;

@property (nonatomic, assign, getter = isOAuthStateAfterOrdinaryBusinessRequestCheckEnabled) BOOL oAuthStateAfterOrdinaryBusinessRequestCheckEnabled;

@property (nonatomic, assign, getter = isOAuthAutoRefreshAccessTokenWhenNecessaryEnabled) BOOL oAuthautoRefreshAccessTokenWhenNecessaryEnabled;

@property (nonatomic, assign) NSTimeInterval oAuthStateMandatoryInvalidTimeInterval;

@property (nonatomic, strong) NSDictionary *oAuthResultInfo;
@property (nonatomic, copy) NSString *access_token;
@property (nonatomic, copy) NSString *refresh_token;
@property (nonatomic, strong) NSNumber *expires_in;

+ (instancetype)defaultManager;

- (BOOL)checkOAuthStateAndExecutePresetMethodIfNeed:(id)sender checkOption:(MROAuthStateCheckOption)option checkResult:(NSDictionary **)result;

@end
