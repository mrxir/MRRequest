//
//  MRRequestErrorHandler.m
//  MRRequest
//
//  Created by MrXir on 2017/7/7.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "MRRequestErrorHandler.h"

@interface MRRequestErrorHandler ()

@property (nonatomic, strong) NSMutableDictionary *handleBlockInfo;

@property (nonatomic, strong) NSError *currentError;

@end

@implementation MRRequestErrorHandler

@synthesize handleBlockInfo = _handleBlockInfo;

+ (instancetype)defaultManager
{
    static MRRequestErrorHandler *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[MRRequestErrorHandler alloc] init];
    });
    return s_manager;
}

- (NSMutableDictionary *)handleBlockInfo
{
    if (!_handleBlockInfo) {
        _handleBlockInfo = [NSMutableDictionary dictionary];
    }
    return _handleBlockInfo;
}

- (void)setHandleBlock:(dispatch_block_t)block forErrorCode:(MRRequestErrorCode)code
{
    [self.handleBlockInfo setObject:block forKey:[@(code) stringValue]];
}

- (dispatch_block_t)handleBlockForErrorCode:(MRRequestErrorCode)code
{
    return [[MRRequestErrorHandler defaultManager].handleBlockInfo objectForKey:[@(code) stringValue]];
}

- (NSError *)currentError
{
    return _currentError;
}

- (void)handleError:(NSError *)error
{
    self.currentError = error;
    
    NSDictionary *handleBlockInfo = [MRRequestErrorHandler defaultManager].handleBlockInfo;
    
    NSArray *fixedCodes = @[@(MRRequestErrorCodeEqualRequestError),
                            @(MRRequestErrorCodeOAuthRequestError),
                            @(MRRequestErrorCodeOAuthRenewalError),
                            @(MRRequestErrorCodeOAuthCommonRequestLightlyError),
                            @(MRRequestErrorCodeOAuthCommonRequestHeavilyError)];
    
    dispatch_block_t block = nil;
    
    if ([fixedCodes containsObject:@(error.code)]) {
        block = [handleBlockInfo objectForKey:[@(error.code) stringValue]];
    } else {
        block = [handleBlockInfo objectForKey:[@(MRRequestErrorCodeDynamicError) stringValue]];
    }
    
    if (block != nil) {
        block();
    }
    
}

@end
