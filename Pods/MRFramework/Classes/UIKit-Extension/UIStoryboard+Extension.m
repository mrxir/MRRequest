//
//  UIStoryboard+Extension.m
//  MRFramework
//
//  Created by MrXir on 2017/6/27.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "UIStoryboard+Extension.h"

@implementation UIStoryboard (Extension)

@end



#pragma mark - controller manager extension

/**
 - private class - controller manager
 */
@interface _ControllerManager : NSObject

@property (nonatomic, strong) NSArray<__kindof NSString *> *storyboardNames;

@property (nonatomic, strong, readonly) NSArray<__kindof NSDictionary *> *storyboardInfos;

+ (instancetype)defaultControllerManager;

- (void)setStoryboardNames:(NSArray<__kindof NSString *> *)storyboardNames;

- (NSArray *)controllerIdentifierListWithStoryboard:(UIStoryboard *)storyboard;

@end

@implementation _ControllerManager

+ (instancetype)defaultControllerManager
{
    static _ControllerManager *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[_ControllerManager alloc] init];
    });
    return s_manager;
}

- (void)setStoryboardNames:(NSArray *)storyboardNames
{
    _storyboardNames = storyboardNames;
    
    NSMutableArray *m_storyboardFiles = [NSMutableArray arrayWithCapacity:self.storyboardNames.count];

#pragma mark - * 将来需要增加一个 storyboard identifier 重复的检测方法, 来抛出异常告知使用者 *
    
    [self.storyboardNames enumerateObjectsUsingBlock:^(__kindof NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIStoryboard *storyboard = nil;
        
        @try {
            storyboard = [UIStoryboard storyboardWithName:obj bundle:nil];
        } @catch (NSException *exception) {
            NSLog(@" | * [ERROR] bundle 中未找到 name 为 \"%@\" 的故事板", obj);
        }
        
        if (storyboard) {
            
            NSDictionary *storyboardInfo = @{@"name": obj,
                                             @"objc": storyboard,
                                             @"keys": [storyboard controllerIdentifierList]};
            
            [m_storyboardFiles addObject:storyboardInfo];
            
        }
        
    }];
    
    _storyboardInfos = [NSArray arrayWithArray:m_storyboardFiles];
    
}

- (NSArray *)controllerIdentifierListWithStoryboard:(UIStoryboard *)storyboard
{
    unsigned int storyboardPropertyCount;
    
    objc_property_t *storyboardProperties = class_copyPropertyList([storyboard class], &storyboardPropertyCount);
    
    NSArray *controllerIdentifierList = [NSArray array];
    
    for (int i = 0; i < storyboardPropertyCount; i++) {
        
        objc_property_t property = storyboardProperties[i];
        
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        // find the dictionary of controller identifier list in run time
        if ([propertyName isEqualToString:@"identifierToNibNameMap"]) {
            controllerIdentifierList = [NSArray arrayWithArray:[[storyboard valueForKey:propertyName] allKeys]];
            break;
        }
        
    }
    
    free(storyboardProperties);
    
    return controllerIdentifierList;
}

@end

@implementation UIStoryboard (ControllerManager)

+ (void)setStoryboardNames:(NSArray<__kindof NSString *> *)names
{
    [[_ControllerManager defaultControllerManager] setStoryboardNames:names];
}

- (NSArray<NSString *> *)controllerIdentifierList
{
    return [[_ControllerManager defaultControllerManager] controllerIdentifierListWithStoryboard:self];
}

@end



#pragma mark - controller identifier matcher extension

@implementation UIStoryboard (IdentifierMatcher)

+ (UIViewController *)matchControllerForIdentifier:(NSString *)identifier
{
    __block UIViewController *controller = nil;
    
    NSArray *storyboardInfos = [[_ControllerManager defaultControllerManager] storyboardInfos];
    
    if (!storyboardInfos.count) {
        
        NSLog(@" | * [CAUTION] storyboard names array is empty, use 'Main.storyboard' file.");
        
        [[_ControllerManager defaultControllerManager] setStoryboardNames:@[@"Main"]];
        
        return [self matchControllerForIdentifier:identifier];
        
    }
    
    [storyboardInfos enumerateObjectsUsingBlock:^(__kindof NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj[@"keys"] containsObject:identifier]) {
            
            UIStoryboard *storyboard = obj[@"objc"];
            
            if ([[storyboard controllerIdentifierList] containsObject:identifier]) {
                
                controller = [storyboard instantiateViewControllerWithIdentifier:identifier];
                
                *stop = YES;
                
            }
            
        }
        
    }];
    
    if (!controller) NSLog(@" | * [ERROR] 所有故事板中未找到 identifier 为 \"%@\" 的控制器", identifier);
    
    return controller;
}

@end



#pragma mark - controller class name matcher extension

@implementation UIViewController (ClassNameMatcher)

+ (UIViewController *)matchControllerForMyself
{
    return [UIStoryboard matchControllerForIdentifier:NSStringFromClass([self class])];
}

@end

