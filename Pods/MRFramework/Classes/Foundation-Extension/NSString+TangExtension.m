//
//  NSString+Extension.m
//  MRFramework
//
//  Created by MrXir on 2017/6/27.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "NSString+TangExtension.h"

@implementation NSString (TangExtension)

@end



#pragma mark - verify extension

@implementation NSString (Verify)

+ (BOOL)isValidString:(id)obj
{
    BOOL isValid = NO;
    
    NSString *someString = (NSString *)obj;
    
    if ([someString respondsToSelector:@selector(isEqualToString:)]) {
        
        if (![someString isEqualToString:@"null"]
            && ![someString isEqualToString:@"(null)"]
            && ![someString isEqualToString:@"<null>"])
        {
            isValid = YES;
        }
        
    }
    
    return isValid;
}

+ (BOOL)isNotEmpty:(id)obj
{
    BOOL isNotEmpty = NO;
    
    NSString *someString = (NSString *)obj;
    
    if ([someString respondsToSelector:@selector(isEqualToString:)]) {
        if (![someString isEqualToString:@"nil"]
            && ![someString isEqualToString:@"null"]
            && ![someString isEqualToString:@"(null)"]
            && ![someString isEqualToString:@"<null>"]
            && [someString length] > 0) {
            isNotEmpty = YES;
        }
    }
    
    return isNotEmpty;
}

- (void)detectForeignWordCompletion:(DetectForeignWordCompletion)detectCompletion
{
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        
        NSString *match = @"(^[\u4e00-\u9fa5]+$)";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
        BOOL isChinese = [predicate evaluateWithObject:substring];
        
        if (!isChinese) {
            
            *stop = YES;
            
            if (detectCompletion != NULL) detectCompletion(YES, substring, substringRange);
        }
        
    }];
}

- (NSString *)filterWithCharactersInString:(NSString *)characters
{
    NSScanner *scanner = [NSScanner scannerWithString:self];
    
    // Intermediate
    NSMutableString *numberString = [NSMutableString string];
    
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:characters];
    
    NSString *tempStr;
    
    while (![scanner isAtEnd]) {
        
        // Throw away characters before the first number.
        [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
        
        // Collect numbers.
        [scanner scanCharactersFromSet:numbers intoString:&tempStr];
        
        if (tempStr != nil) {
            [numberString appendString:tempStr];
        }
        
        tempStr = @"";
    }
    
    // Result.
    
    return numberString;
}

@end



#pragma mark - cipher extension

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Cipher)

#pragma mark - cipher - MD5

- (NSString *)md5Hash
{
    const char* input = [self UTF8String];
    
    CC_MD5_CTX md5HashContext;
    
    CC_MD5_Init(&md5HashContext);
    
    CC_MD5_Update(&md5HashContext, input, (CC_LONG) strlen(input));
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5_Final(digest, &md5HashContext);
    
    NSMutableString *md5HashString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5HashString appendFormat:@"%02x", digest[i]];
    }
    
    return md5HashString;
}

+ (NSString *)md5HashWithFile:(NSString *)filePath
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (handle == nil) return nil;
    
    NSData *fileData = [[NSData alloc] initWithData:[handle readDataOfLength:4096]];
    const char* input = [fileData bytes];
    
    CC_MD5_CTX md5HashContext;
    
    CC_MD5_Init (&md5HashContext);
    
    BOOL done = NO;
    
    while (!done) {
        
        CC_MD5_Update (&md5HashContext, input, (CC_LONG) [fileData length]);
        
        if ([fileData length] == 0) {
            done = YES;
        }
        
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5_Final (digest, &md5HashContext);
    
    NSMutableString *md5HashString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5HashString appendFormat:@"%02x", digest[i]];
    }
    
    return md5HashString;
}


@end



@implementation NSString (Drawing)

- (CGRect)boundingRectWithFont:(UIFont *)font frame:(CGRect)frame CalculateOption:(CalculateOption)option
{
    if (!self.length) {
        return CGRectMake(frame.origin.x, frame.origin.y, 0, 0);
    } else {
        
        NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin;
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        
        NSDictionary *attributes = @{NSFontAttributeName: font,
                                     NSParagraphStyleAttributeName: style};
        
        CGSize maxSize = CGSizeZero;
        
        CGRect boundingRect = frame;
        
        if (option == CalculateOptionWidth) {
            maxSize = CGSizeMake(CGFLOAT_MAX, frame.size.height);
            boundingRect = [self boundingRectWithSize:maxSize options:opts attributes:attributes context:nil];
            boundingRect.size.width = ceilf(boundingRect.size.width);
            boundingRect.size.height = ceilf(boundingRect.size.height);
            
        } else {
            maxSize = CGSizeMake(frame.size.width, CGFLOAT_MAX);
            boundingRect = [self boundingRectWithSize:maxSize options:opts attributes:attributes context:nil];
            boundingRect.size.width = ceilf(boundingRect.size.width);
            boundingRect.size.height = ceilf(boundingRect.size.height);
        }
        
        return boundingRect;
        
    }
    
}

@end
