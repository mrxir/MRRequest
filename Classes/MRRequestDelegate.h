//
//  MRRequestDelegate.h
//  MRRequest
//
//  Created by MrXir on 2017/6/30.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRRequest;

@protocol MRRequestDelegate <NSObject>

@optional

- (void)request:(MRRequest *)request progress:(CGFloat)progress;

@required

- (void)request:(MRRequest *)request success:(NSDictionary *)receiveInfo data:(NSData *)data;

- (void)request:(MRRequest *)request failure:(NSDictionary *)requestInfo data:(NSData *)data error:(NSError *)error;


@end
