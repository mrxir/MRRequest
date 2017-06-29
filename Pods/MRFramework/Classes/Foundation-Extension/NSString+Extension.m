//
//  NSString+Extension.m
//  MRFramework
//
//  Created by MrXir on 2017/6/27.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

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
    
    CC_MD5_Update(&md5HashContext, input, (CC_LONG) [self length]);
    
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
            boundingRect.size.width += ceilf(boundingRect.size.width);
            
        } else {
            maxSize = CGSizeMake(frame.size.width, CGFLOAT_MAX);
            boundingRect = [self boundingRectWithSize:maxSize options:opts attributes:attributes context:nil];
            boundingRect.size.height = ceilf(boundingRect.size.height);
        }
        
        return boundingRect;
        
    }
    
}

@end
