//
//  MRRequest.m
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "MRRequest.h"

@interface MRRequest ()<NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableData *receiveData;

@property (nonatomic, weak) NSURLConnection *connection;

@property (nonatomic, copy) NSString *requestIdentifier;

@end

@implementation MRRequest

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
        
        url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:parameter.resultEncoding == 0 ? NSUTF8StringEncoding : parameter.resultEncoding]];
        
        // 如果 URL 仍然无效, 则返回错误信息.
        if ([[UIApplication sharedApplication] canOpenURL:url] == NO) {
            
            NSLog(@"[ERROR] URL 无效, 已对 path 进行编码, 编码后得到的 URL 依然无效, 若要解决此问题, 请检查 path 及 parameter");
            NSLog(@"[ERROR] path \"%@\"", originPath);
            NSLog(@"[ERROR] parameter %@", parameter.source);
            NSLog(@"[ERROR] URL \"%@\"", path);
            NSLog(@"[ERROR] EncodedURL \"%@\"", url.absoluteString);
            
            return nil;
            
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
        }
        /*=======================================================================*/
        
    }
    
    return self;
    
}

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
    
    [request resume];
}

- (void)resume
{
    self.requestIdentifier = self.parameter.identifier;
    
    if (!self.requestIdentifier) {
        
        NSString *currentRequestIdentifier = [self.path stringByAppendingString:
                                              self.parameter.relativelyStableParameterString ?
                                              self.parameter.relativelyStableParameterString : @""];
        
        self.requestIdentifier = currentRequestIdentifier;
    }
    
    NSMutableSet *processingRequestIdentifierSet = [MRRequestManager defaultManager].processingRequestIdentifierSet;
    
    if ([processingRequestIdentifierSet containsObject:self.requestIdentifier]) {
        
        NSError *error = [NSError errorWithDomain:@"MRRequestErrorDomain"
                                             code:MRRequestErrorCodeHandlingSameRequest
                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"正在处理上次请求 😨", nil)}];
        
        // block
        if (self.failure != NULL) {
            self.failure(self, self.parameter.result, self.receiveData, error);
        }
        
        // delegate
        
        
    } else {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        self.receiveData = [[NSMutableData alloc] init];
        
        self.connection = [NSURLConnection connectionWithRequest:self delegate:self];
        
        [[MRRequestManager defaultManager].processingRequestIdentifierSet addObject:self.requestIdentifier];
        
    }
    
}

- (void)cancel
{
    [self.connection cancel];
}

- (void)dealloc
{
    NSLog(@"[MRRequest] %s", __FUNCTION__);
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receiveData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    NSError *error = nil;
    id value = [NSJSONSerialization JSONObjectWithData:self.receiveData options:NSJSONReadingMutableLeaves error:&error];
    
    NSLog(@"%@", value);
    
    // OAuth 开关状态
    BOOL oAuthEnabled = NO;
    if (self.parameter.isOAuthIndependentSwitchHasBeenSetted == YES) {
        oAuthEnabled = self.parameter.isOAuthEnabled;
    } else {
        oAuthEnabled = [MRRequestManager defaultManager].isOAuthEnabled;
    }
    
    // 如果开关开启, 则找错误 key, 如果找到错误 key, 则抛错, 否则执行业务, 注意使用 request scope 来区分返回结果异同情况.
    
    // 如果开关关闭, 不查找错误 key.
    
    
    [[MRRequestManager defaultManager].processingRequestIdentifierSet removeObject:self.requestIdentifier];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [[MRRequestManager defaultManager].processingRequestIdentifierSet removeObject:self.requestIdentifier];
}

@end



#pragma mark - default config

@implementation MRRequest (DefaultConfig)

+ (void)setOAuthEnabled:(BOOL)enabled
{
    [MRRequestManager defaultManager].oAuthEnabled = enabled;
}

+ (BOOL)oAuthEnabled
{
    return [MRRequestManager defaultManager].isOAuthEnabled;
}

@end
