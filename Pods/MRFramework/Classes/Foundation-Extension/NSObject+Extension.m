//
//  NSObject+Extension.m
//  MRFramework
//
//  Created by MrXir on 2017/6/27.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "NSObject+Extension.h"

@implementation NSObject (Extension)

@end



#pragma mark - property extension

@implementation NSObject (Property)

@dynamic objectIndexPath;

- (NSIndexPath *)objectIndexPath
{
    return objc_getAssociatedObject(self, @"objectIndexPath");
}

- (void)setObjectIndexPath:(NSIndexPath *)objectIndexPath
{
    objc_setAssociatedObject(self, @"objectIndexPath", objectIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end



#pragma mark - object to dictionary converter

@implementation NSObject (ModelConverter)

+ (NSDictionary *)propertyWithObject:(__kindof NSObject *)object
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    unsigned int propertyCount;
    
    objc_property_t *properties = class_copyPropertyList([object class], &propertyCount);
    
    for (int i=0; i<propertyCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        id value = [self getObjectInternalValue:[object valueForKey:propertyName]];
        dictionary[propertyName] = value;
    }
    
    free(properties);
    return dictionary;
}

- (id)getObjectInternalValue:(id)obj
{
    if (!obj
        || [obj isKindOfClass:[NSNull class]]
        || [obj isKindOfClass:[NSNumber class]]
        || [obj isKindOfClass:[NSString class]]) {
        
        return obj;
    }
    
    if ([obj isKindOfClass:[NSArray class]]) {
        NSArray *arrayObj = obj;
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:arrayObj.count];
        for (int i=0; i<arrayObj.count; i++) {
            [array setObject:[self getObjectInternalValue:[arrayObj objectAtIndex:i]] atIndexedSubscript:i];
        }
        
        return array;
    }
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionaryObj = obj;
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[dictionaryObj count]];
        for (NSString *key in dictionaryObj.allKeys) {
            [dictionary setObject:[self getObjectInternalValue:[dictionaryObj objectForKey:key]] forKey:key];
        }
        
        return dictionary;
    }
    
    return obj;
    
}

@end



#pragma mark - desctiption extension

@implementation NSObject (Description)

- (NSString *)stringWithUTF8
{
    BOOL isString = [self isKindOfClass:[NSString class]];
    
    BOOL isArray = [self isKindOfClass:[NSArray class]];
    
    BOOL isDictionary = [self isKindOfClass:[NSDictionary class]];
    
    BOOL isSet = [self isKindOfClass:[NSSet class]];
    
    BOOL isData = [self isKindOfClass:[NSData class]];
    
    if (isString || isArray || isDictionary || isSet) {
        
        if ([self respondsToSelector:@selector(length)]) {
            if (![self performSelector:@selector(length)]) return self.description;
        }
        
        if ([self respondsToSelector:@selector(count)]) {
            if (![self performSelector:@selector(count)]) return self.description;
        }
        
        NSString *tempString0 = self.description;
        
        NSString *tempString1 = [tempString0 stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
        NSString *tempString2 = [tempString1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        NSString *tempString3 = [[@"\"" stringByAppendingString:tempString2] stringByAppendingString:@"\""];
        NSData *tempData = [tempString3 dataUsingEncoding:NSUTF8StringEncoding];
        
        return [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:nil error:nil];
        
    } else if (isData) {
        
        return [[NSString alloc] initWithData:(NSData *)self encoding:NSUTF8StringEncoding];
        
    } else {
        
        return self.description.stringWithUTF8;
        
    }
}

@end
