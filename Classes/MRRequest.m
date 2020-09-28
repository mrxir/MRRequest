//
//  MRRequest.m
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "MRRequest.h"

#import <MRFramework/NSString+TangExtension.h>

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
        NSString *theParameterOfGetRequest = parameter.structure;
        
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
                
                NSLog(@"[MRREQUEST] ❗️ URL 无效, 已对 path 进行编码, 编码后得到的 URL 依然无效, 若要解决此问题, 请检查 path 及 parameter.");
                NSLog(@"[MRREQUEST] ❗️ path \"%@\".", originPath);
                NSLog(@"[MRREQUEST] ❗️ parameter %@", parameter.object);
                NSLog(@"[MRREQUEST] ❗️ URL \"%@\".", path);
                NSLog(@"[MRREQUEST] ❗️ EncodedURL \"%@\".", url.absoluteString);
                
            }
            
        } else {
            
            if ([MRRequest logLevel] <= MRRequestLogLevelError) {
                
                NSLog(@"[MRREQUEST] ❗️ URL 无效, 已对 path 进行编码, 编码后的 URL 可用, 若要解决此问题, 请检查 path 及 parameter.");
                NSLog(@"[MRREQUEST] ❗️ path \"%@\".", originPath);
                NSLog(@"[MRREQUEST] ❗️ parameter %@", parameter.object);
                NSLog(@"[MRREQUEST] ❗️ URL \"%@\".", path);
                NSLog(@"[MRREQUEST] ❗️ EncodedURL \"%@\".", url.absoluteString);
                
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
                        NSLog(@"[MRREQUEST] ⚠️ URL 中未找到查询标志符 \"?\", 这可能导致服务器无法正确获取业务参数, 如果没有问题, 请忽略这条提示信息, 否则请检查 URL.");
                        NSLog(@"[MRREQUEST] ⚠️ URL \"%@\".", url.absoluteString);
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
            
            NSData *data = parameter.structure;
            
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
        NSLog(@"[MRREQUEST] ▫️ %s", __FUNCTION__);
    }
}

- (void)execute
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[MRREQUEST] ▫️ %s", __FUNCTION__);
    }
    
    // 获取oauth开关
    // OAuth 开关状态
    BOOL oAuthEnabled = NO;
    if (self.parameter.isOAuthIndependentSwitchHasBeenSetted == YES) {
        oAuthEnabled = self.parameter.isOAuthIndependentSwitchState;
    } else {
        oAuthEnabled = [MRRequestManager defaultManager].isOAuthEnabled;
    }
    
    if (oAuthEnabled == YES) {
        
        // 普通业务请求时当两个令牌失效时抛出错误
        if (self.parameter.oAuthRequestScope == MRRequestParameterOAuthRequestScopeOrdinaryBusiness) {
            
            // 判断令牌状态
            MROAuthTokenState tokenState = [[MROAuthRequestManager defaultManager] analyseOAuthTokenStateAndGenerateReport:nil];
            
            // 访问和刷新令牌都失效
            if (tokenState == MROAuthTokenStateBothInvalid) {
                
                NSString *errorDesc = @"OAuth业务请求发起前检测到严重错误, 因为访问和续约令牌都已失效.";
                NSError *error = [NSError errorWithDomain:MRRequestErrorDomain
                                                     code:MRRequestErrorCodeOAuthCommonRequestHeavilyError
                                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(errorDesc, nil)}];
                
                if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
                    NSLog(@"[MRREQUEST] ❗️ 地址 %@", self.URL);
                    NSLog(@"[MRREQUEST] ❗️ 参数 %@", self.parameter.object);
                    NSLog(@"[MRREQUEST] ❗️ 错误 %@", errorDesc);
                }
                
                self.anyError = error;
                
                [self failed];
                
                return;
                
            }
            
            
            // 续约令牌请求时当续约令牌失效时抛出错误
        } else if (self.parameter.oAuthRequestScope == MRRequestParameterOAuthRequestScopeRefreshAccessToken) {
            
            // 判断令牌状态
            MROAuthTokenState tokenState = [[MROAuthRequestManager defaultManager] analyseOAuthTokenStateAndGenerateReport:nil];
            
            // 刷新令牌失效
            if (tokenState == MROAuthTokenStateOnlyAccessTokenAvailable) {
                
                NSString *errorDesc = @"OAuth续约请求发起前检测到严重错误, 因为续约令牌已失效.";
                NSError *error = [NSError errorWithDomain:MRRequestErrorDomain
                                                     code:MRRequestErrorCodeOAuthRenewalError
                                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(errorDesc, nil)}];
                
                if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
                    NSLog(@"[MRREQUEST] ❗️ 地址 %@", self.URL);
                    NSLog(@"[MRREQUEST] ❗️ 参数 %@", self.parameter.object);
                    NSLog(@"[MRREQUEST] ❗️ 错误 %@", errorDesc);
                }
                
                self.anyError = error;
                
                [self failed];
                
                return;
                
            }
            
            
        }
        
    }
    
    // 判断重复请求
    if ([NSString isValidString:self.parameter.identifier] == YES) {
        self.requestIdentifier = self.parameter.identifier;
    } else {
        
        NSString *path = self.path;
        NSString *relativelyStableParameterString = self.parameter.relativelyStableParameterString;
        
        if ([NSString isValidString:relativelyStableParameterString] == YES) {
            self.requestIdentifier = [path stringByAppendingString:relativelyStableParameterString];
        } else {
            self.requestIdentifier = path;
        }
        
    }
    
    if ([NSString isValidString:self.requestIdentifier] == YES) {
        
        if ([[MRRequestManager defaultManager].processingRequestIdentifierSet containsObject:self.requestIdentifier]) {
            
            NSString *errorDesc = @"MRRequest队列中存在完全相同的请求, 此次请求无法发起失败.";
            NSError *error = [NSError errorWithDomain:MRRequestErrorDomain
                                                 code:MRRequestErrorCodeEqualRequestError
                                             userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(errorDesc, nil)}];
            
            if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
                NSLog(@"[MRREQUEST] ❗️ 地址 %@", self.URL);
                NSLog(@"[MRREQUEST] ❗️ 参数 %@", self.parameter.object);
                NSLog(@"[MRREQUEST] ❗️ 错误 %@", errorDesc);
            }
            
            self.anyError = error;
            
            [self failed];
            
            return;
            
        }
        
    }
    
    
    
    [self started];
    
}

- (void)started
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[MRREQUEST] ▫️ %s", __FUNCTION__);
        NSLog(@"[MRREQUEST] ▫️ %@", self);
        
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if ([NSString isValidString:self.requestIdentifier] == YES) {
        [[MRRequestManager defaultManager].processingRequestIdentifierSet addObject:self.requestIdentifier];
    }
    
    self.receiveData = [[NSMutableData alloc] init];
    
    self.connection = [NSURLConnection connectionWithRequest:self delegate:self];
}

- (void)exit
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[MRREQUEST] ▫️ %s", __FUNCTION__);
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [self.connection cancel];
}

- (void)failed
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
        NSLog(@"[MRREQUEST] ❗️ %s", __FUNCTION__);
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([NSString isValidString:self.requestIdentifier] == YES) {
        [[MRRequestManager defaultManager].processingRequestIdentifierSet removeObject:self.requestIdentifier];
    }
    
    // block failure
    if (self.failure != NULL) {
        self.failure(self, self.parameter.dynamicParameter, self.receiveData, self.anyError);
    }
    
    // delegate failure
}

- (void)succeeded
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[MRREQUEST] ▫️ %s", __FUNCTION__);
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([NSString isValidString:self.requestIdentifier] == YES) {
        [[MRRequestManager defaultManager].processingRequestIdentifierSet removeObject:self.requestIdentifier];
    }
    
    // block success
    if (self.success != NULL) {
        self.success(self, self.receiveObject);
    }
    
    // delegate success
    
    
}

- (void)dealloc
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[MRREQUEST] ▫️ %s", __FUNCTION__);
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
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[MRREQUEST] ▫️ %s", __FUNCTION__);
    }
    
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            
            NSInteger statusCode = httpResponse.statusCode;
            
            if (statusCode != 200) {
                
                NSLog(@"[MRREQUEST] ❗️ %@", httpResponse);
                
            }
            
        }
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receiveData appendData:data];
    
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[MRREQUEST] ▫️ %s + LENGTH %06d = LENGTH %06d",
              __FUNCTION__,
              (unsigned)data.length,
              (unsigned)self.receiveData.length);
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[MRREQUEST] ▫️ %s", __FUNCTION__);
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([NSString isValidString:self.requestIdentifier] == YES) {
        [[MRRequestManager defaultManager].processingRequestIdentifierSet removeObject:self.requestIdentifier];
    }
    
    // OAuth 开关状态
    BOOL oAuthEnabled = NO;
    if (self.parameter.isOAuthIndependentSwitchHasBeenSetted == YES) {
        oAuthEnabled = self.parameter.isOAuthIndependentSwitchState;
    } else {
        oAuthEnabled = [MRRequestManager defaultManager].isOAuthEnabled;
    }
    
    if (oAuthEnabled == YES) {
        
        [self handleOAuthReceiveData];
        
    } else {
        
        [self handleOrdinaryReceiveData];
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelVerbose) {
        NSLog(@"[MRREQUEST] ❗️ %s", __FUNCTION__);
    }
    
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
    NSString *oAuthErrorDesc = nil;
    
    NSDictionary *exception = receiveDictionary[@"exception"];
    
    if ([exception isKindOfClass:[NSDictionary class]]) {
        
        oAuthErrorCode = exception[@"error"];
        oAuthErrorDesc = exception[@"error_description"];
        
        if (!oAuthErrorDesc) {
            oAuthErrorDesc = exception[@"localizedMessage"];
        }
        
    } else {
        
        oAuthErrorCode = receiveDictionary[@"error"];
        oAuthErrorDesc = receiveDictionary[@"error_description"];
        
    }
    
    if (exception != nil || oAuthErrorCode != nil || oAuthErrorDesc != nil) {
        
        oAuthErrorCode = [NSString stringWithFormat:@"%@", oAuthErrorCode];
        oAuthErrorDesc = [NSString stringWithFormat:@"%@", oAuthErrorDesc];
        
        if ([NSString isValidString:oAuthErrorCode] == NO) oAuthErrorCode = @"unknown_oauth_error_code";
        if ([NSString isValidString:oAuthErrorDesc] == NO) oAuthErrorDesc = @"unknown_oauth_error_desc";
        
        NSString *oAuthErrorCodeDesc = [NSString stringWithFormat:@"%@, %@", oAuthErrorCode, oAuthErrorDesc];
        
        MRRequestErrorCode requestErrorCode = 0;
        
        NSString *requestErrorDesc = nil;
        
        if (self.parameter.oAuthRequestScope == MRRequestParameterOAuthRequestScopeRequestAccessToken) {
            
            if ([oAuthErrorCode isEqualToString:@"new_device"]) {
                
                requestErrorCode = MRRequestErrorCodeOAuthDeviceInit;
                requestErrorDesc = [NSString stringWithFormat:@"OAuth获取授权时需要初始化设备, %@", oAuthErrorCodeDesc];
                
            } else if ([oAuthErrorCode isEqualToString:@"no_mobile"]) {
                
                requestErrorCode = MRRequestErrorCodeOAuthNoMobile;
                requestErrorDesc = [NSString stringWithFormat:@"OAuth获取授权时未找到手机号, %@", oAuthErrorCodeDesc];
                
            } else {
                
                requestErrorCode = MRRequestErrorCodeOAuthRequestError;
                requestErrorDesc = [NSString stringWithFormat:@"OAuth获取授权的结果中捕获到异常, %@", oAuthErrorCodeDesc];
                
            }
            
        } else if (self.parameter.oAuthRequestScope == MRRequestParameterOAuthRequestScopeRefreshAccessToken) {
            
            requestErrorCode = MRRequestErrorCodeOAuthRenewalError;
            requestErrorDesc = [NSString stringWithFormat:@"OAuth续约授权的结果中捕获到异常, %@", oAuthErrorCodeDesc];
            
        } else if (self.parameter.oAuthRequestScope == MRRequestParameterOAuthRequestScopeOrdinaryBusiness) {
            
            if ([oAuthErrorCode isEqualToString:@"unknown_oauth_error_code"]
                || [oAuthErrorCode isEqualToString:@"access_denied"]
                || [oAuthErrorCode isEqualToString:@"error_uri"]
                || [oAuthErrorCode isEqualToString:@"invalid_request"]
                || [oAuthErrorCode isEqualToString:@"invalid_scope"]
                || [oAuthErrorCode isEqualToString:@"invalid_sign"]
                || [oAuthErrorCode isEqualToString:@"insufficient_scope"]
                || [oAuthErrorCode isEqualToString:@"redirect_uri_mismatch"]
                || [oAuthErrorCode isEqualToString:@"unsupported_response_type"])
            {
                
                requestErrorCode = MRRequestErrorCodeOAuthCommonRequestLightlyError;
                requestErrorDesc = [NSString stringWithFormat:@"OAuth业务请求时捕获到轻微异常, %@", oAuthErrorCodeDesc];
                
            }
            
            else if ([oAuthErrorCode isEqualToString:@"invalid_client"]
                     || [oAuthErrorCode isEqualToString:@"invalid_grant"]
                     || [oAuthErrorCode isEqualToString:@"invalid_token"]
                     || [oAuthErrorCode isEqualToString:@"unauthorized"]
                     || [oAuthErrorCode isEqualToString:@"unauthorized_client"]
                     || [oAuthErrorCode isEqualToString:@"unsupported_grant_type"])
            {
                
                requestErrorCode = MRRequestErrorCodeOAuthCommonRequestHeavilyError;
                requestErrorDesc = [NSString stringWithFormat:@"OAuth业务请求时捕获到严重异常, %@", oAuthErrorCodeDesc];
                
            }
            
        }
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"oAuthErrorCode"] = oAuthErrorCode;
        userInfo[NSURLPathKey] = self.URL;
        userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(requestErrorDesc, nil);
        userInfo[NSLocalizedFailureReasonErrorKey] = NSLocalizedString(oAuthErrorCodeDesc, nil);
        userInfo[NSURLLocalizedLabelKey] = receiveDictionary;
        
        *error = [NSError errorWithDomain:MRRequestErrorDomain
                                     code:requestErrorCode
                                 userInfo:userInfo];
        
        if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
            
            NSLog(@"[MRREQUEST] ❗️ 地址 %@", self.URL);
            NSLog(@"[MRREQUEST] ❗️ 参数 %@", self.parameter.object);
            NSLog(@"[MRREQUEST] ❗️ 错误 %@", oAuthErrorCodeDesc);
            NSLog(@"[MRREQUEST] ❗️ 描述 %@", requestErrorDesc);
            
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

+ (void)setHandleBlock:(dispatch_block_t)block forErrorCode:(MRRequestErrorCode)code
{
    [[MRRequestErrorHandler defaultManager] setHandleBlock:block forErrorCode:code];
}

+ (dispatch_block_t)handleBlockForErrorCode:(MRRequestErrorCode)code
{
    return [[MRRequestErrorHandler defaultManager] handleBlockForErrorCode:code];
}

+ (void)handleError:(NSError *)error
{
    [[MRRequestErrorHandler defaultManager] handleError:error];
}

+ (NSError *)currentError
{
    return [[MRRequestErrorHandler defaultManager] currentError];
}

+ (void)setCustomAdditionalParameter:(NSDictionary *)parameter
{
    [MRRequestManager defaultManager].customAdditionalParameter = parameter;
}

+ (NSDictionary *)customAdditionalParameter
{
    return [MRRequestManager defaultManager].customAdditionalParameter;
}

@end



@implementation MRRequest (OAuthPublicMethod)

+ (BOOL)enableOAuthRequestWithServer:(NSString *)server
                            clientId:(NSString *)clientId
                        clientSecret:(NSString *)clientSecret
            autodestructTimeInterval:(NSTimeInterval)autodestructTimeInterval
                            anyError:(NSError *__autoreleasing *)error
{
    [MROAuthRequestManager defaultManager].server = server;
    [MROAuthRequestManager defaultManager].client_id = clientId;
    [MROAuthRequestManager defaultManager].client_secret = clientSecret;
    [MROAuthRequestManager defaultManager].oAuthInfoAutodestructTimeInterval = autodestructTimeInterval;
    
    return [[MRRequestManager defaultManager] activeOAuth:error];
    
    
    
    
    BOOL shouldEnabled = NO;
    
    if ([NSString isValidString:server] && [NSString isValidString:clientId] && [NSString isValidString:clientSecret]) {
        if (clientId.length >= 6 && clientSecret.length >= 6 && autodestructTimeInterval >= 10) {
            shouldEnabled = YES;
        }
    }
    
    if (shouldEnabled == YES) {
        
        
        
        
    } else {
        
        if (error != nil) {
            
            NSString *errorDesc = @"OAuth信息设置有误, 请检查 😨";
            
            *error = [NSError errorWithDomain:MRRequestErrorDomain
                                         code:666
                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(errorDesc, nil),
                                                @"oauth": @{@"server": [NSString stringWithFormat:@"%@", server],
                                                            @"client_id": [NSString stringWithFormat:@"%@", clientId],
                                                            @"client_secret": [NSString stringWithFormat:@"%@", clientSecret],
                                                            @"autodestructTimeInterval": @(autodestructTimeInterval)}}];
            
            if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelError) {
                NSLog(@"[OAUTH] ❗️ %@", errorDesc);
            }
            
            
        }
        
        
    }
    
    return shouldEnabled;
}

#pragma mark - OAuth - 分析并返回oauth授权信息状态, 可以获得一份分析报告

+ (MROAuthTokenState)analyseOAuthTokenStateAndGenerateReport:(NSDictionary *__autoreleasing *)report
{
    return [[MROAuthRequestManager defaultManager] analyseOAuthTokenStateAndGenerateReport:report];
}

@end



#pragma mark - OAuthSetting

@implementation MRRequest (OAuthSetting)

#pragma mark - OAuth 开关

+ (BOOL)activeOAuth:(NSError *__autoreleasing *)error
{
    return [[MRRequestManager defaultManager] activeOAuth:error];
}

+ (void)deactiveOAuth
{
    [[MRRequestManager defaultManager] deactiveOAuth];
}



#pragma mark - OAuth 设置oauth服务器

+ (void)setOAuthServer:(NSString *)server
{
    if ([MRRequestManager defaultManager].logLevel <= MRRequestLogLevelInfo) {
        NSLog(@"[OAUTH] 🔘 OAuth server is \"%@\".", server);
    }
    
    [MROAuthRequestManager defaultManager].server = server;
}

+ (NSString *)oAuthServer
{
    return [MROAuthRequestManager defaultManager].server;
}



#pragma mark - OAuth - 设置oauth客户端凭证信息

+ (void)setOAuthClientId:(NSString *)clientId
{
    [MROAuthRequestManager defaultManager].client_id = clientId;
}

+ (NSString *)oAuthClientId
{
    return [MROAuthRequestManager defaultManager].client_id;
}

+ (void)setOAuthClientSecret:(NSString *)secret
{
    [MROAuthRequestManager defaultManager].client_secret = secret;
}

+ (NSString *)oAuthClientSecret
{
    return [MROAuthRequestManager defaultManager].client_secret;
}



#pragma mark - OAuth - oauth授权信息自动销毁时间间隔

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
            NSLog(@"[OAUTH] ❗️ OAuth未开启, 无法设置 OAuthStatePeriodicCheckEnabled 😨");
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
            NSLog(@"[OAUTH] ❗️ OAuth未开启, 无法设置 OAuthStatePeriodicCheckTimeInterval 😨");
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
            NSLog(@"[OAUTH] ❗️ OAuth未开启, 无法设置 OAuthStateAfterOrdinaryBusinessRequestCheckEnabled 😨");
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
            NSLog(@"[OAUTH] ❗️ OAuth未开启, 无法设置 OAuthAutoExecuteTokenAbnormalPresetPlanEnabled 😨");
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
            NSLog(@"[OAUTH] ❗️ OAuth未开启, 无法设置 OAuthAccessTokenAbnormalCustomPlanBlock 😨");
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
            NSLog(@"[OAUTH] ❗️ OAuth未开启, 无法设置 OAuthRefreshTokenAbnormalCustomPlanBlock 😨");
        }
    }
    
}

@end
