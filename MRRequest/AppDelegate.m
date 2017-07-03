//
//  AppDelegate.m
//  MRRequest
//
//  Created by MrXir on 2017/6/27.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import "AppDelegate.h"

#import <MRFramework/UIStoryboard+Extension.h>

#import "MRRequest.h"

#import <SVProgressHUD.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [MRRequest setOAuthEnabled:YES];
    [MRRequest setOAuthInfoAutodestructTimeInterval:60.0f];
    [MRRequest setOAuthStatePeriodicCheckTimeInterval:5.0f];
    
    [MRRequest setOAuthAccessTokenAbnormalCustomPlanBlock:^{
        
        NSLog(@"正在帮你刷新token");
        
    } replaceOrKeepBoth:NO];
    
//    // 模拟设置 OAuth 授权信息
//    NSDictionary *simulateOAuthInfo = @{@"access_token": @"123456789012345678",
//                                        @"refresh_token": @"000000000000000000",
//                                        @"expires_in": @(10)};
//    
//    [[MROAuthRequestManager defaultManager] updateOAuthArchiveWithResultDictionary:simulateOAuthInfo
//                                                                      requestScope:MRRequestParameterOAuthRequestScopeRequestAccessToken];
    
    [UIStoryboard setStoryboardNames:@[@"Main",
                                       @"LoginModule",
                                       @"BusinessQueriesModule"]];
    
    [SVProgressHUD setMinimumSize:CGSizeMake(100.0f, 100.0f)];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
