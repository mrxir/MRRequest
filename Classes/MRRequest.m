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
            
            if ([MRRequest logLevel] <= MRRequestLogLevelError) {
                
                NSLog(@"[ERROR] URL 无效, 已对 path 进行编码, 编码后得到的 URL 依然无效, 若要解决此问题, 请检查 path 及 parameter");
                NSLog(@"[ERROR] path \"%@\"", originPath);
                NSLog(@"[ERROR] parameter %@", parameter.source);
                NSLog(@"[ERROR] URL \"%@\"", path);
                NSLog(@"[ERROR] EncodedURL \"%@\"", url.absoluteString);
                
            }
            
        } else {
            
            if ([MRRequest logLevel] <= MRRequestLogLevelError) {
                
                NSLog(@"[CAUTION] URL 无效, 已对 path 进行编码, 编码后的 URL 可用, 若要解决此问题, 请检查 path 及 parameter.");
                NSLog(@"[CAUTION] path \"%@\"", originPath);
                NSLog(@"[CAUTION] parameter %@", parameter.source);
                NSLog(@"[CAUTION] URL \"%@\"", path);
                NSLog(@"[CAUTION] EncodedURL \"%@\"", url.absoluteString);

            }
            
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
                    
                    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelWarning) {
                        NSLog(@"[MRREQUEST] URL 中未找到查询标志符 \"?\", 这可能导致服务器无法正确获取业务参数, 如果没有问题, 请忽略这条提示信息, 否则请检查 URL.");
                        NSLog(@"[MRREQUEST] URL \"%@\"", url.absoluteString);
                    }
                    
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
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[MRREQUEST] %s", __FUNCTION__);
    }
}

- (void)execute
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[MRREQUEST] %s", __FUNCTION__);
    }
    
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
        
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
            NSLog(@"[MRREQUEST] %@", error);
        }
        
        self.anyError = error;
        
        [self failed];
        
    } else {
        
        [self started];
    }
    
}

- (void)started
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[MRREQUEST] %s", __FUNCTION__);
        NSLog(@"[MRREQUEST] %@", self);
        NSLog(@"[MRREQUEST] %@", self.parameter);
        
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [[MRRequestManager defaultManager].processingRequestIdentifierSet addObject:self.requestIdentifier];
    
    self.receiveData = [[NSMutableData alloc] init];
    
    self.connection = [NSURLConnection connectionWithRequest:self delegate:self];
}

- (void)exit
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[MRREQUEST] %s", __FUNCTION__);
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [self.connection cancel];
}

- (void)failed
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[MRREQUEST] %s", __FUNCTION__);
    }
    
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
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[MRREQUEST] %s", __FUNCTION__);
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [[MRRequestManager defaultManager].processingRequestIdentifierSet removeObject:self.requestIdentifier];
    
    // block success
    if (self.success != NULL) {
        self.success(self, self.receiveObject);
    }
    
    // delegate success
    

}

- (void)dealloc
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[MRREQUEST] %s", __FUNCTION__);
    }
}

#pragma mark - NSURLConnectionDataDelegate

/*
 {(
 "not found",
 "unsupported version",
 "payment required",
 "proxy authentication required",
 forbidden,
 "reset content",
 created,
 "gateway timed out",
 conflict,
 "partial content",
 "no content",
 informational,
 "not modified",
 redirected,
 continue,
 "requested URL too long",
 "no error",
 unimplemented,
 "length required",
 "bad request",
 "service unavailable",
 "method not allowed",
 "request too large",
 "unsupported media type",
 "client error",
 found,
 "switching protocols",
 "multiple choices",
 "no longer exists",
 "moved permanently",
 "server error",
 "request timed out",
 "requested range not satisfiable",
 "expectation failed",
 unauthorized,
 accepted,
 "precondition failed",
 "needs proxy",
 "internal server error",
 "bad gateway",
 "temporarily redirected",
 "see other",
 success,
 unacceptable,
 "non-authoritative information"
 )}
 */

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
            NSLog(@"[MRREQUEST] %@", httpResponse);
        }
        
        NSInteger statusCode = httpResponse.statusCode;
        
        if (statusCode != 200) {
            
            NSError *error = [NSError errorWithDomain:MRRequestErrorDomain
                                                 code:statusCode
                                             userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString([NSHTTPURLResponse localizedStringForStatusCode:statusCode], nil)}];
            
            if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
                NSLog(@"[MRREQUEST] %@", error);
            }
            
            [self exit];
            
            self.anyError = error;

            [self failed];
            
        }
        
    }
}

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
            
            if ([MRRequest isOAuthStatePeriodicCheckEnabled] == YES) {
                [[MROAuthRequestManager defaultManager] resumeOAuthStatePeriodicCheckTimer];
            }
            
            
            if ([MRRequest isOAuthStateAfterOrdinaryBusinessRequestCheckEnabled] == YES) {
                [[MROAuthRequestManager defaultManager] analyseOAuthTokenStateAndGenerateReport:nil];
            }
            
            [MROAuthRequestManager defaultManager].processingOAuthAbnormalPresetPlan = NO;
            
        } else {
            
            NSError *error = nil;
            
            if ([self searchAndHandleForExceptionCharacteristicsInReceiveDictionary:&error] == NO) {
                
                self.anyError = error;
                
                [self failed];
                
            } else {
                
                [[MROAuthRequestManager defaultManager] updateOAuthArchiveWithResultDictionary:self.receiveObject
                                                                                  requestScope:self.parameter.oAuthRequestScope];
                
                [self succeeded];
                
                if ([MRRequest isOAuthStatePeriodicCheckEnabled] == YES) {
                    [[MROAuthRequestManager defaultManager] resumeOAuthStatePeriodicCheckTimer];
                }
                
                
                if ([MRRequest isOAuthStateAfterOrdinaryBusinessRequestCheckEnabled] == YES) {
                    [[MROAuthRequestManager defaultManager] analyseOAuthTokenStateAndGenerateReport:nil];
                }
                
                [MROAuthRequestManager defaultManager].processingOAuthAbnormalPresetPlan = NO;
                
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
    
    if (exception != nil || oAuthErrorCode != nil || oAuthErrorReason != nil) {
        
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
        
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
            NSLog(@"[OAUTH] %@", *error);
        }
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}

@end



@implementation MRRequest (Extension)

@end



@implementation MRRequest (PublicConfig)

+ (void)setLogLevel:(MRRequestLogLevel)level
{
    [MRRequestManager defaultManager].logLevel = level;
}

+ (MRRequestLogLevel)logLevel
{
    return [MRRequestManager defaultManager].logLevel;
}

@end



@implementation MRRequest (OAuthPublicMethod)

+ (BOOL)enableOAuthRequestWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret autodestructTimeInterval:(NSTimeInterval)autodestructTimeInterval anyError:(NSError *__autoreleasing *)error
{
    BOOL enabled = NO;
    
    if ([NSString isValidString:clientId] && [NSString isValidString:clientSecret]) {
        
        if (clientId.length >= 6 && clientSecret.length >= 6) {
            
            if (autodestructTimeInterval >= 10) {
                
                enabled = YES;
                
                [MROAuthRequestManager defaultManager].clientId = clientId;
                [MROAuthRequestManager defaultManager].clientSecret = clientSecret;
                [MROAuthRequestManager defaultManager].oAuthInfoAutodestructTimeInterval = autodestructTimeInterval;
                
                [MRRequestManager defaultManager].oAuthEnabled = YES;
                
                
            }
            
        }
        
    }
    
    if (enabled == NO) {
        
        if (error != nil) {
            
            *error = [NSError errorWithDomain:MRRequestErrorDomain
                                         code:MRRequestErrorCodeOAuthCredentialsConfigError
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"客户端凭证有误, 请检查 😨", nil),
                                                @"credentials": @{@"clientId": [NSString stringWithFormat:@"%@", clientId],
                                                                  @"clientSecret": [NSString stringWithFormat:@"%@", clientSecret],
                                                                  @"autodestructTimeInterval": @(autodestructTimeInterval)}}];
            
            if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
                NSLog(@"[OAUTH] %@", *error);
            }
            
            
        }
        
    }
    
    return enabled;
}

#pragma mark - OAuth - 分析并返回oauth授权信息状态, 可以获得一份分析报告

+ (MROAuthTokenState)analyseOAuthTokenStateAndGenerateReport:(NSDictionary *__autoreleasing *)report
{
    return [[MROAuthRequestManager defaultManager] analyseOAuthTokenStateAndGenerateReport:report];
}

@end



#pragma mark - OAuthSetting

@implementation MRRequest (OAuthSetting)

#pragma mark - OAuth - oauth request 总开关

+ (void)setOAuthEnabled:(BOOL)enabled
{
    [MRRequestManager defaultManager].oAuthEnabled = enabled;
}

+ (BOOL)isOAuthEnabled
{
    return [MRRequestManager defaultManager].isOAuthEnabled;
}



#pragma mark - OAuth - oauth授权信息自动销毁时间间隔

+ (void)setOAuthClientId:(NSString *)clientId
{
    [MROAuthRequestManager defaultManager].clientId = clientId;
}

+ (NSString *)oAuthClientId
{
    return [MROAuthRequestManager defaultManager].clientId;
}

+ (void)setOAuthClientSecret:(NSString *)secret
{
    [MROAuthRequestManager defaultManager].clientSecret = secret;
}

+ (NSString *)oAuthClientSecret
{
    return [MROAuthRequestManager defaultManager].clientSecret;
}

+ (void)setOAuthInfoAutodestructTimeInterval:(NSTimeInterval)timeInterval
{
    [MROAuthRequestManager defaultManager].oAuthInfoAutodestructTimeInterval = timeInterval;
}

+ (NSTimeInterval)oAuthInfoAutodestructTimeInterval
{
    return [MROAuthRequestManager defaultManager].oAuthInfoAutodestructTimeInterval;
}



#pragma mark - OAuth - oauth授权信息周期性检查的开关

+ (void)setOAuthStatePeriodicCheckEnabled:(BOOL)enabled
{
    if ([MRRequestManager defaultManager].isOAuthEnabled == YES) {
        [MROAuthRequestManager defaultManager].oAuthStatePeriodicCheckEnabled = enabled;
    } else {
        
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
            NSLog(@"[OAUTH] oauth未开启, 无法设置 OAuthStatePeriodicCheckEnabled 😨");
        }
        
    }
    
}

+ (BOOL)isOAuthStatePeriodicCheckEnabled
{
    return [MROAuthRequestManager defaultManager].isOAuthStatePeriodicCheckEnabled;
}



#pragma mark - OAuth - oauth授权信息周期性检查的时间间隔

+ (void)setOAuthStatePeriodicCheckTimeInterval:(NSTimeInterval)timeInterval
{
    if ([MRRequestManager defaultManager].isOAuthEnabled == YES) {
        [MROAuthRequestManager defaultManager].oAuthStatePeriodicCheckTimeInterval = timeInterval;
    } else {
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
            NSLog(@"[OAUTH] oauth未开启, 无法设置 OAuthStatePeriodicCheckTimeInterval 😨");
        }
    }
    
}

+ (NSTimeInterval)oAuthStatePeriodicCheckTimeInterval
{
    return [MROAuthRequestManager defaultManager].oAuthStatePeriodicCheckTimeInterval;
}



#pragma mark - OAuth - 当一个oauth请求完成后是否检查oauth授权信息的开关

+ (void)setOAuthStateAfterOrdinaryBusinessRequestCheckEnabled:(BOOL)enabled
{
    if ([MRRequestManager defaultManager].isOAuthEnabled == YES) {
        [MROAuthRequestManager defaultManager].oAuthStateAfterOrdinaryBusinessRequestCheckEnabled = enabled;
    } else {
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
            NSLog(@"[OAUTH] oauth未开启, 无法设置 OAuthStateAfterOrdinaryBusinessRequestCheckEnabled 😨");
        }
    }
}

+ (BOOL)isOAuthStateAfterOrdinaryBusinessRequestCheckEnabled
{
    return [MROAuthRequestManager defaultManager].isOAuthStateAfterOrdinaryBusinessRequestCheckEnabled;
}



#pragma mark - OAuth - 当oauth授权信息不正常时执行设方案的开关

+ (void)setOAuthAutoExecuteTokenAbnormalPresetPlanEnabled:(BOOL)enabled
{
    if ([MRRequestManager defaultManager].isOAuthEnabled == YES) {
        [MROAuthRequestManager defaultManager].oAuthAutoExecuteTokenAbnormalPresetPlanEnabled = enabled;
    } else {
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
            NSLog(@"[OAUTH] oauth未开启, 无法设置 OAuthAutoExecuteTokenAbnormalPresetPlanEnabled 😨");
        }
    }
}

+ (BOOL)isOAuthAutoExecuteTokenAbnormalPresetPlanEnabled
{
    return [MROAuthRequestManager defaultManager].isOAuthAutoExecuteTokenAbnormalPresetPlanEnabled;
}



#pragma mark - oauth授权信息不正常自定义方案代码块

+ (void)setOAuthAccessTokenAbnormalCustomPlanBlock:(dispatch_block_t)planBlock replaceOrKeepBoth:(BOOL)replaceOrKeepBoth;
{
    if ([MRRequestManager defaultManager].isOAuthEnabled == YES) {
        [MROAuthRequestManager defaultManager].oAuthAccessTokenAbnormalCustomPlanBlock = planBlock;
        [MROAuthRequestManager defaultManager].oAuthAccessTokenAbnormalCustomPlanBlockReplaceOrKeepBoth = replaceOrKeepBoth;
    } else {
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
            NSLog(@"[OAUTH] oauth未开启, 无法设置 OAuthAccessTokenAbnormalCustomPlanBlock 😨");
        }
    }
   
}

+ (void)setOAuthRefreshTokenAbnormalCustomPlanBlock:(dispatch_block_t)planBlock replaceOrKeepBoth:(BOOL)replaceOrKeepBoth;
{
    if ([MRRequestManager defaultManager].isOAuthEnabled == YES) {
        [MROAuthRequestManager defaultManager].oAuthRefreshTokenAbnormalCustomPlanBlock = planBlock;
        [MROAuthRequestManager defaultManager].oAuthRefreshTokenAbnormalCustomPlanBlockReplaceOrKeepBoth = replaceOrKeepBoth;
    } else {
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
            NSLog(@"[OAUTH] oauth未开启, 无法设置 OAuthRefreshTokenAbnormalCustomPlanBlock 😨");
        }
    }
    
}

@end
