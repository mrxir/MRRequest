//
//  MRRequest.h
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MRRequestManager.h"
#import "MRRequestParameter.h"
#import "MRRequestDelegate.h"

typedef NS_ENUM(NSUInteger, MRRequestErrorCode) {
    
    MRRequestErrorCodeInvalidAccessToken = 7782567,
    MRRequestErrorCodeInvalidRefreshToken = 7782568,
    MRRequestErrorCodeHandlingSameRequest = 7782777,
    
    
};

typedef void(^Progress)(MRRequest *request, CGFloat progress);

typedef void(^Success)(MRRequest *request, id receiveObject);

typedef void(^Failure)(MRRequest *request, id requestObject, NSData *data, NSError *error);

@interface MRRequest : NSMutableURLRequest

@property (nonatomic, copy) Progress progress;
@property (nonatomic, copy) Success success;
@property (nonatomic, copy) Failure failure;

@property (nonatomic, copy, readonly) NSString *path;

@property (nonatomic, strong, readonly) MRRequestParameter *parameter;

@property (nonatomic, weak, readonly) id <MRRequestDelegate> delegate;

#pragma mark - life cycle

- (instancetype)initWithPath:(NSString *)path parameter:(MRRequestParameter *)parameter delegate:(id <MRRequestDelegate>)delegate;

+ (void)requestWithPath:(NSString *)path
              parameter:(MRRequestParameter *)parameter
                success:(Success)success
                failure:(Failure)failure;

+ (void)requestWithPath:(NSString *)path
              parameter:(MRRequestParameter *)parameter
               progress:(Progress)progress
                success:(Success)success
                failure:(Failure)failure;

- (void)resume;

- (void)cancel;

- (void)dealloc;

@end



#pragma mark - default config

@interface MRRequest (DefaultConfig)

+ (void)setOAuthEnabled:(BOOL)enabled;
+ (BOOL)oAuthEnabled;

@end
