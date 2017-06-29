//
//  MRRequestParameter.m
//  MRRequest
//
//  Created by MrXir on 2017/6/29.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "MRRequestParameter.h"

#import "MRRequest.h"

#import <MRFramework/NSObject+Extension.h>
#import <MRFramework/NSDictionary+Extension.h>
#import <MRFramework/NSString+Extension.h>
#import <MRFramework/NSJSONSerialization+Extension.h>

@interface MRRequestParameter ()
{
    NSDateFormatter *_timestampDateFormatter;
}

@end

@implementation MRRequestParameter

#pragma mark - life cycle

- (void)dealloc
{
    // 释放所有的强引用属性
}

- (instancetype)initWithObject:(id)obj
{
    if (self = [super init]) {
        
        _source = obj;
        
        _timestampDateFormatter = [[NSDateFormatter alloc] init];
        _timestampDateFormatter.dateFormat = @"yyyyMMddHHmmssSSS";
        
    }
    return self;
}

- (id)result
{
    return [self constructResultWithSource:self.source];
}

- (NSString *)description
{
    return @"description";
}


#pragma mark - private tool method

- (id)constructResultWithSource:(id)source
{
    
    
    
    
    // >>>>> 处理自定义对象 <<<<<
    /* custom object to dictionary */
    /*=======================================================================*/
    id sourceObject = nil;
    
    if (![NSJSONSerialization isValidJSONObject:source]) {
        
        // Maybe the 'source' is kind of custom object, so get its property dictionary and use it.
        
        sourceObject = [NSObject propertyWithObject:source];
        
    } else {
        
        sourceObject = source;
    }
    /*=======================================================================*/
    
    
    
    
    // >>>>> 处理OAuth开关 <<<<<
    /* edit source object if need */
    /*=======================================================================*/
    id editedSourceObject = nil;
    
    // 根据 OAuthEnabled 判定是否开启 OAuth 认证, 从而决定是否要对参数进行再处理.
    if ([MRRequest getOAuthEnabled] == YES) {
        
        // sourceObject 必须为 NSDictionary 类型
        if ([sourceObject isKindOfClass:[NSDictionary class]]) {
            
            
            
            
            // >>>>> 处理请求范围 <<<<<
            /*=======================================================================*/
            NSMutableDictionary *sourceDictionary = [NSMutableDictionary dictionaryWithDictionary:sourceObject];

            // 根据 requestScope 判定应该增加哪些特定参数
            if (self.requestScope == MRRequestParameterRequestScopeNormal) {
                
                sourceDictionary[@"access_token"]   = @"****** - access_token - ******";
                
            }
            
            if (self.requestScope == MRRequestParameterRequestScopeRequestAccessToken) {
                
                sourceDictionary[@"client_id"]      = @"****** - client_id - ******";
                
                sourceDictionary[@"client_secret"]  = @"****** - client_secret - ******";
                
                sourceDictionary[@"grant_type"]     = @"password";
                
            }
            
            if (self.requestScope == MRRequestParameterRequestScopeRefreshAccessToken) {
                
                sourceDictionary[@"client_id"]      = @"****** - client_id - ******";
                
                sourceDictionary[@"client_secret"]  = @"****** - client_secret - ******";
                
                sourceDictionary[@"refresh_token"]  = @"****** - refresh_token - ******";
                
                sourceDictionary[@"grant_type"]     = @"refresh_token";
                
            }
            /*=======================================================================*/
            
            // 设置欲返回数据的数据格式为 json
            sourceDictionary[@"format"] = @"json";
            
            // 设置本次请求的 timestamp
            sourceDictionary[@"timestamp"] = [_timestampDateFormatter stringFromDate:[NSDate date]];
            
            // 使用非空的键值对进行签名
            NSMutableDictionary *notEmptyKeyValueMap = [NSMutableDictionary dictionaryWithDictionary:sourceDictionary];
            [notEmptyKeyValueMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj respondsToSelector:@selector(length)]) {
                    if ([obj performSelector:@selector(length)] == 0) {
                        [notEmptyKeyValueMap removeObjectForKey:key];
                    }
                }
            }];
            
            // 签名
            sourceDictionary[@"sign"] = notEmptyKeyValueMap.formattedIntoFormStyleString.md5Hash;
            
            editedSourceObject = sourceDictionary;
            
        } else {
            
            NSLog(@"[ERROR] OAuth request only accept NSDictionary to be source object.");
            
            editedSourceObject = sourceObject;
            
        }
        
    } else {
        
        editedSourceObject = sourceObject;
        
    }
    /*=======================================================================*/
    
    
    
    
    // >>>>> 处理格式化样式 <<<<<
    /* formatted style */
    /*=======================================================================*/
    NSString *formattedParamString = nil;
    
    if (self.formattedStyle == MRRequestParameterFormattedStyleJSON) {
        
        NSError *error = nil;
        formattedParamString = [NSJSONSerialization stringWithJSONObject:editedSourceObject options:0 error:&error];
        if (error) NSLog(@"Class:%s line:%d\n%@", __FUNCTION__, __LINE__, error);
        if (!formattedParamString) formattedParamString = @"";
        
    }
    
    if (self.formattedStyle == MRRequestParameterFormattedStyleForm) {
        
        formattedParamString = [editedSourceObject formattedIntoFormStyleString];
        
    }
    /*=======================================================================*/
    
    
    
    
    // >>>>> 处理参数前缀 <<<<<
    /* prefix */
    /*=======================================================================*/
    if (self.sourcePrefix.length) {
        
        formattedParamString = [self.sourcePrefix stringByAppendingString:formattedParamString];
    }
    /*=======================================================================*/
    
    
    
    
    // >>>>> 处理请求方式 <<<<<
    /* if request method is POST generate NSData  */
    /*=======================================================================*/
    id returnObject = nil;
    
    if (self.requestMethod == MRRequestParameterRequestMethodGet) {
        returnObject = self.resultEncoding == 0 ? formattedParamString : [formattedParamString stringByAddingPercentEscapesUsingEncoding:self.resultEncoding];
    }
    
    if (self.requestMethod == MRRequestParameterRequestMethodPost) {
        returnObject = [formattedParamString dataUsingEncoding:self.resultEncoding == 0 ? NSUTF8StringEncoding : self.resultEncoding];
    }
    /*=======================================================================*/
    
    
    NSLog(@"%@", returnObject);
    
    return returnObject;
    
}

@end
