//
//  NSDictionary+Extension.m
//  MRFramework
//
//  Created by MrXir on 2017/6/28.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "NSDictionary+Extension.h"

@implementation NSDictionary (Extension)

@end



#pragma mark - dictionary formatter extension

@implementation NSDictionary (Formatter)

/* formatted into form style string */
/*================================================================*/

- (NSString *)formattedIntoFormStyleString
{
    NSDictionary *encodedDictionary = [self encodeKeyAndObjectWithFormStyle];
    
    NSMutableString *string = [NSMutableString string];
    
    id key;
    id obj;
    
    for (NSUInteger i = 0, n = [encodedDictionary allKeys].count; i < n; i++) {
        
        key = [[encodedDictionary allKeys] sortedArrayUsingSelector:@selector(compare:)][i];
        obj = encodedDictionary[key];
        
        if (![obj isKindOfClass:[NSDictionary class]]) {
            
            [string appendFormat:@"%@=%@", key, obj];
            
        } else {
            
            if ([NSJSONSerialization isValidJSONObject:obj]) {
                
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [string appendFormat:@"%@=%@", key, jsonString];
                
            }
            
        }
        
        if (i < (n - 1)) {
            [string appendString:@"&"];
        } else {
            break;
        }
        
    }
    
    return [self decodeStringWithSomeSpecialSymbol:string];
}

- (NSDictionary *)encodeKeyAndObjectWithFormStyle
{
    __block NSMutableDictionary *encodedDictionary = [NSMutableDictionary dictionary];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString *encodedKey = [self encodeStringWithSomeSpecialSymbol:key];
        
        if (![obj isKindOfClass:[NSDictionary class]]) {
            
            NSString *encodedObj = [self encodeStringWithSomeSpecialSymbol:[NSString stringWithFormat:@"%@", obj]];
            
            encodedDictionary[encodedKey] = encodedObj;
            
        } else {
            encodedDictionary[encodedKey] = [obj encodeKeyAndObjectWithFormStyle];
        }
        
    }];
    
    return encodedDictionary;
}

NSString *leftCurlyBrace = @"[left curly brace]";

NSString *rightCurlyBrace = @"[right curly brace]";

NSString *colon = @"[colon]";

NSString *comma = @"[comma]";

- (NSString *)encodeStringWithSomeSpecialSymbol:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"{" withString:leftCurlyBrace];
    string = [string stringByReplacingOccurrencesOfString:@"}" withString:rightCurlyBrace];
    string = [string stringByReplacingOccurrencesOfString:@":" withString:colon];
    string = [string stringByReplacingOccurrencesOfString:@"," withString:comma];
    
    return string;
}

- (NSString *)decodeStringWithSomeSpecialSymbol:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:leftCurlyBrace withString:@"{"];
    string = [string stringByReplacingOccurrencesOfString:rightCurlyBrace withString:@"}"];
    string = [string stringByReplacingOccurrencesOfString:colon withString:@":"];
    string = [string stringByReplacingOccurrencesOfString:comma withString:@","];
    return string;
}

/*================================================================*/

@end
