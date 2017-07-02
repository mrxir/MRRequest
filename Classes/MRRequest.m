//
//  MRRequest.m
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "MRRequest.h"

#import <MRFramework/NSString+Extension.h>

NSString * const MRRequestErrorDomain = @"MRRequestErrorDomain";

@interface MRRequest ()<NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableData *receiveData;

@property (nonatomic, weak) NSURLConnection *connection;

@property (nonatomic, copy) NSString *requestIdentifier;

@property (nonatomic, strong) NSError *anyError;

@property (nonatomic, strong) id receiveObject;

- (void)execute;
- (void)exit;

- (void)initialized;
- (void)started;
- (void)failed;
- (void)succeeded;

@end

@implementation MRRequest

+ (void)requestWithPath:(NSString *)path parameter:(MRRequestParameter *)parameter success:(Success)success failure:(Failure)failure
{
    [MRRequest requestWithPath:path parameter:parameter progress:NULL success:success failure:failure];
}

+ (void)requestWithPath:(NSString *)path parameter:(MRRequestParameter *)parameter progress:(Progress)progress success:(Success)success failure:(Failure)failure
{
    MRRequest *request = [[MRRequest alloc] initWithPath:path parameter:parameter delegate:nil];
    
    request.progress = progress;
    
    request.success = success;
    
    request.failure = failure;
    
    [request execute];
}

#pragma mark - life cycle

- (instancetype)initWithPath:(NSString *)path parameter:(MRRequestParameter *)parameter delegate:(id<MRRequestDelegate>)delegate
{
    NSString *originPath = path;
    
    // >>>>> 判断请求方式, 并生成 URL <<<<<
    /*=======================================================================*/
    if (parameter.requestMethod == MRRequestParameterRequestMethodGet) {
        
        // 防止多次调用 parameter get result 方法, 因为该方法已被重写切相对较为复杂.
        NSString *theParameterOfGetRequest = parameter.result;
        
        if ([theParameterOfGetRequest isKindOfClass:[NSString class]]) {
            
            path = [path stringByAppendingString:theParameterOfGetRequest];
            
        }
        
    }
    
    NSURL *url = [NSURL URLWithString:path];
    
    // 如果 URL 无效, 尝试将 path 进行编码
    if ([[UIApplication sharedApplication] canOpenURL:url] == NO) {
        
        url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:
                                    (parameter.resultEncoding == 0 ?
                                     NSUTF8StringEncoding : parameter.resultEncoding)]];
        
        // 如果 URL 仍然无效, 则返回错误信息.
        if ([[UIApplication sharedApplication] canOpenURL:url] == NO) {
            
            NSLog(@"[ERROR] URL 无效, 已对 path 进行编码, 编码后得到的 URL 依然无效, 若要解决此问题, 请检查 path 及 parameter");
            NSLog(@"[ERROR] path \"%@\"", originPath);
            NSLog(@"[ERROR] parameter %@", parameter.source);
            NSLog(@"[ERROR] URL \"%@\"", path);
            NSLog(@"[ERROR] EncodedURL \"%@\"", url.absoluteString);
            
        } else {
            
            NSLog(@"[CAUTION] URL 无效, 已对 path 进行编码, 编码后的 URL 可用, 若要解决此问题, 请检查 path 及 parameter.");
            NSLog(@"[CAUTION] path \"%@\"", originPath);
            NSLog(@"[CAUTION] parameter %@", parameter.source);
            NSLog(@"[CAUTION] URL \"%@\"", path);
            NSLog(@"[CAUTION] EncodedURL \"%@\"", url.absoluteString);
            
        }
        
    }
    
    // 可能漏掉的GET请求 "?" 符号
    if (parameter.requestMethod == MRRequestParameterRequestMethodGet) {
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            
            // 如果整个路径中找到 "="
            if ([path rangeOfString:@"="].location != NSNotFound) {
                
                BOOL foundInOriginPath = NO;
                if (originPath != nil && [originPath rangeOfString:@"?"].location != NSNotFound) {
                    foundInOriginPath = YES;
                }
                
                BOOL foundInSourcePrefix = NO;
                if (parameter.sourcePrefix != nil && [parameter.sourcePrefix rangeOfString:@"?"].location != NSNotFound) {
                    foundInSourcePrefix = YES;
                }
                
                if (foundInOriginPath == NO && foundInSourcePrefix == NO) {
                    NSLog(@"[HINT] URL 中未找到查询标志符 \"?\", 这可能导致服务器无法正确获取业务参数, 如果没有问题, 请忽略这条提示信息, 否则请检查 URL.");
                    NSLog(@"[HINT] URL \"%@\"", url.absoluteString);
                }
                
            }
            
        }
    }
    /*=======================================================================*/
    
    if (self = [super initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f]) {
        
        [self initialized];
        
        // set request path
        /*=======================================================================*/
        _path = originPath;
        /*=======================================================================*/
        
        // set request parameter
        /*=======================================================================*/
        _parameter = parameter;
        /*=======================================================================*/
        
        // set request delegate
        /*=======================================================================*/
        _delegate = delegate;
        /*=======================================================================*/
        
        // set request method
        /*=======================================================================*/
        if (parameter.requestMethod == MRRequestParameterRequestMethodGet) {
            self.HTTPMethod = @"GET";
        }
        
        if (parameter.requestMethod == MRRequestParameterRequestMethodPost) {
            self.HTTPMethod = @"POST";
            
            NSData *data = parameter.result;
            
            if ([data isKindOfClass:[NSData class]]) {
                self.HTTPBody = data;
            }
        }
        /*=======================================================================*/
        
        
    }
    
    return self;
    
}

- (void)initialized
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)execute
{
    NSLog(@"%s", __FUNCTION__);
    
    self.requestIdentifier = self.parameter.identifier;
    
    if (!self.requestIdentifier) {
        
        NSString *currentRequestIdentifier = [self.path stringByAppendingString:
                                              (self.parameter.relativelyStableParameterString ?
                                               self.parameter.relativelyStableParameterString : @"")];
        
        self.requestIdentifier = currentRequestIdentifier;
    }
    
    NSMutableSet *processingRequestIdentifierSet = [MRRequestManager defaultManager].processingRequestIdentifierSet;
    
    if ([processingRequestIdentifierSet containsObject:self.requestIdentifier]) {
        
        NSError *error = [NSError errorWithDomain:MRRequestErrorDomain
                                             code:MRRequestErrorCodeGlobalInProcessingSameRequest
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"正在处理上次请求 😨", nil)}];
        
        self.anyError = error;
        
        [self failed];
        
    } else {
        
        [self started];
    }
    
}

- (void)started
{
    NSLog(@"%s", __FUNCTION__);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [[MRRequestManager defaultManager].processingRequestIdentifierSet addObject:self.requestIdentifier];
    
    self.receiveData = [[NSMutableData alloc] init];
    
    self.connection = [NSURLConnection connectionWithRequest:self delegate:self];
}

- (void)exit
{
    NSLog(@"%s", __FUNCTION__);
    
    [self.connection cancel];
}

- (void)failed
{
    NSLog(@"%s", __FUNCTION__);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [[MRRequestManager defaultManager].processingRequestIdentifierSet removeObject:self.requestIdentifier];
    
    // block failure
    if (self.failure != NULL) {
        self.failure(self, self.parameter.result, self.receiveData, self.anyError);
    }
    
    // delegate failure
}

- (void)succeeded
{
    NSLog(@"%s", __FUNCTION__);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [[MRRequestManager defaultManager].processingRequestIdentifierSet removeObject:self.requestIdentifier];
    
    // block success
    if (self.success != NULL) {
        self.success(self, self.receiveObject);
    }
    
    // delegate success
    
    
    if ([MRRequest isOAuthStateAfterOrdinaryBusinessRequestCheckEnabled] == YES) {
        
        
        
    }
    

}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receiveData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [[MRRequestManager defaultManager].processingRequestIdentifierSet removeObject:self.requestIdentifier];
    
    // OAuth 开关状态
    BOOL oAuthEnabled = NO;
    if (self.parameter.isOAuthIndependentSwitchHasBeenSetted == YES) {
        oAuthEnabled = self.parameter.isOAuthIndependentSwitchState;
    } else {
        oAuthEnabled = [MRRequest isOAuthEnabled];
    }
    
    if (oAuthEnabled == YES) {
        
        [self handleOAuthReceiveData];
        
    } else {
        
        [self handleOrdinaryReceiveData];
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.anyError = error;
    
    [self failed];
}

#pragma mark - private method

- (void)handleOAuthReceiveData
{
    NSError *error = nil;
    self.receiveObject = [NSJSONSerialization JSONObjectWithData:self.receiveData options:NSJSONReadingMutableLeaves error:&error];
    
    if (error != nil) {
        
        self.anyError = error;
        
        [self failed];
        
    } else {
        
        if (![self.receiveObject isKindOfClass:[NSDictionary class]]) {
            
            [self succeeded];
            
        } else {
            
            NSError *error = nil;
            
            if ([self searchAndHandleForExceptionCharacteristicsInReceiveDictionary:&error] == NO) {
                
                self.anyError = error;
                
                [self failed];
                
            } else {
                
                [self handleOAuthResultDictionary];
                
            }
            
        }

        
    }
    
}

- (void)handleOrdinaryReceiveData
{
    NSError *error = nil;
    
    self.receiveObject = [NSJSONSerialization JSONObjectWithData:self.receiveData options:NSJSONReadingMutableLeaves error:&error];
    
    if (error != nil) {
        
        self.anyError = error;
        
        [self failed];
        
    } else {
        
        [self succeeded];
        
    }
}

- (BOOL)searchAndHandleForExceptionCharacteristicsInReceiveDictionary:(NSError **)error
{
    NSDictionary *receiveDictionary = [NSDictionary dictionaryWithDictionary:self.receiveObject];
    
    NSString *oAuthErrorCode = nil;
    NSString *oAuthErrorReason = nil;
    
    NSDictionary *exception = receiveDictionary[@"exception"];
    
    if (exception != nil && [exception isKindOfClass:[NSDictionary class]]) {
        
        oAuthErrorCode = exception[@"error"];
        oAuthErrorReason = exception[@"error_description"];
        
    } else {
        
        oAuthErrorCode = receiveDictionary[@"error"];
        oAuthErrorReason = receiveDictionary[@"error_description"];
        
    }
    
    if (oAuthErrorCode != nil || oAuthErrorReason != nil) {
        
        oAuthErrorCode = [NSString stringWithFormat:@"%@", oAuthErrorCode];
        oAuthErrorReason = [NSString stringWithFormat:@"%@", oAuthErrorReason];
        
        if ([NSString isValidString:oAuthErrorCode] == NO) oAuthErrorCode = @"unknown_oauth_error";
        if ([NSString isValidString:oAuthErrorReason] == NO) oAuthErrorReason = @"unknown_oauth_error_reason";
        
        NSString *failureReason = [NSString stringWithFormat:@"%@, %@", oAuthErrorCode, oAuthErrorReason];
        
        MRRequestErrorCode requestErrorCode = 0;
        
        NSString *oAuthRequestErrorDescription = nil;
        
        if (self.parameter.oAuthRequestScope == MRRequestParameterOAuthRequestScopeRequestAccessToken) {
            
            requestErrorCode = MRRequestErrorCodeOAuthRequestAccessTokenFailed;
            
            oAuthRequestErrorDescription = [NSString stringWithFormat:@"获取 access token 失败, %@", failureReason];
            
        } else if (self.parameter.oAuthRequestScope == MRRequestParameterOAuthRequestScopeRefreshAccessToken) {
            
            requestErrorCode = MRRequestErrorCodeOAuthRefreshAccessTokenFailed;
            
            oAuthRequestErrorDescription = [NSString stringWithFormat:@"刷新 access token 失败, %@", failureReason];
            
        } else if (self.parameter.oAuthRequestScope == MRRequestParameterOAuthRequestScopeOrdinaryBusiness) {
            
            if ([oAuthErrorCode isEqualToString:@"unknown_oauth_error"]
                || [oAuthErrorCode isEqualToString:@"access_denied"]
                || [oAuthErrorCode isEqualToString:@"error_uri"]
                || [oAuthErrorCode isEqualToString:@"invalid_request"]
                || [oAuthErrorCode isEqualToString:@"invalid_scope"]
                || [oAuthErrorCode isEqualToString:@"invalid_sign"]
                || [oAuthErrorCode isEqualToString:@"insufficient_scope"]
                || [oAuthErrorCode isEqualToString:@"redirect_uri_mismatch"]
                || [oAuthErrorCode isEqualToString:@"unsupported_response_type"])
            {
                
                requestErrorCode = MRRequestErrorCodeOAuthOrdinaryBusinessTolerableFailed;
                
                oAuthRequestErrorDescription = [NSString stringWithFormat:@"可容忍的业务请求失败, %@", failureReason];
                
            }
            
            else if ([oAuthErrorCode isEqualToString:@"invalid_client"]
                     || [oAuthErrorCode isEqualToString:@"invalid_grant"]
                     || [oAuthErrorCode isEqualToString:@"invalid_token"]
                     || [oAuthErrorCode isEqualToString:@"unauthorized"]
                     || [oAuthErrorCode isEqualToString:@"unauthorized_client"]
                     || [oAuthErrorCode isEqualToString:@"unsupported_grant_type"])
            {
                
                requestErrorCode = MRRequestErrorCodeOAuthOrdinaryBusinessIntolerableFailed;
                
                oAuthRequestErrorDescription = [NSString stringWithFormat:@"不可容忍的业务请求失败, %@", failureReason];
                
            }
            
        }
        
        *error = [NSError errorWithDomain:MRRequestErrorDomain
                                     code:requestErrorCode
                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(oAuthRequestErrorDescription, nil),
                                            NSLocalizedFailureReasonErrorKey: NSLocalizedString(failureReason, nil)}];
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}

- (void)handleOAuthResultDictionary
{
    NSDictionary *oAuthResultDictionary = [NSDictionary dictionaryWithDictionary:self.receiveObject];
    
    MROAuthRequestManager *oAuthManager = [MROAuthRequestManager defaultManager];
    
    oAuthManager.oAuthResultInfo = oAuthResultDictionary;
    
    oAuthManager.access_token = oAuthResultDictionary[@"access_token"];
    oAuthManager.refresh_token = oAuthResultDictionary[@"refresh_token"];
    oAuthManager.expires_in = oAuthResultDictionary[@"expires_in"];
    
    [self succeeded];
}

@end



#pragma mark - default config

@implementation MRRequest (DefaultConfig)

+ (void)setOAuthEnabled:(BOOL)enabled
{
    [MRRequestManager defaultManager].oAuthEnabled = enabled;
}

+ (BOOL)isOAuthEnabled
{
    return [MRRequestManager defaultManager].isOAuthEnabled;
}

+ (void)setOAuthStatePeriodicCheckEnabled:(BOOL)enabled
{
    [MROAuthRequestManager defaultManager].oAuthStatePeriodicCheckEnabled = enabled;
}

+ (BOOL)isOAuthStatePeriodicCheckEnabled
{
    return [MROAuthRequestManager defaultManager].isOAuthStatePeriodicCheckEnabled;
}

+ (void)setOAuthStatePeriodicCheckTimeInterval:(NSTimeInterval)timeInterval
{
    [MROAuthRequestManager defaultManager].oAuthStatePeriodicCheckTimeInterval = timeInterval;
}

+ (NSTimeInterval)oAuthStatePeriodicCheckTimeInterval
{
    return [MROAuthRequestManager defaultManager].oAuthStatePeriodicCheckTimeInterval;
}

+ (void)setOAuthAutoRefreshAccessTokenWhenNecessaryEnabled:(BOOL)enabled
{
    [MROAuthRequestManager defaultManager].oAuthautoRefreshAccessTokenWhenNecessaryEnabled = enabled;
}

+ (BOOL)isOAuthAutoRefreshAccessTokenWhenNecessaryEnabled
{
    return [MROAuthRequestManager defaultManager].isOAuthAutoRefreshAccessTokenWhenNecessaryEnabled;
}

+ (void)setOAuthStateAfterOrdinaryBusinessRequestCheckEnabled:(BOOL)enabled
{
    [MROAuthRequestManager defaultManager].oAuthStateAfterOrdinaryBusinessRequestCheckEnabled = enabled;
}

+ (BOOL)isOAuthStateAfterOrdinaryBusinessRequestCheckEnabled
{
    return [MROAuthRequestManager defaultManager].isOAuthStateAfterOrdinaryBusinessRequestCheckEnabled;
}

+ (void)setOAuthStateMandatoryInvalidTimeInterval:(NSTimeInterval)timeInterval
{
    [MROAuthRequestManager defaultManager].oAuthStateMandatoryInvalidTimeInterval = timeInterval;
}

+ (NSTimeInterval)oAuthStateMandatoryInvalidTimeInterval
{
    return [MROAuthRequestManager defaultManager].oAuthStateMandatoryInvalidTimeInterval;
}

+ (BOOL)checkOAuthAccessTokenStateAndExecutePresetMethodIfNeed:(BOOL)ifNeed checkReport:(NSDictionary **)report
{
    return [[MROAuthRequestManager defaultManager] checkOAuthStateAndExecutePresetMethodIfNeed:@(ifNeed)
                                                                                   checkOption:MROAuthStateCheckOptionCheckAccessToken
                                                                                   checkResult:report];
}

+ (BOOL)checkOAuthRefreshTokenStateAndExecutePresetMethodIfNeed:(BOOL)ifNeed checkReport:(NSDictionary **)report
{
    return [[MROAuthRequestManager defaultManager] checkOAuthStateAndExecutePresetMethodIfNeed:@(ifNeed)
                                                                                   checkOption:MROAuthStateCheckOptionCheckRefreshToken
                                                                                   checkResult:report];
}


@end
