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
    
    /* 开启方式:1 */
    NSError *error = nil;
    BOOL enabled = [MRRequest enableOAuthRequestWithClientId:@"123456"
                                                clientSecret:@"000000"
                                    autodestructTimeInterval:60.0f
                                                    anyError:&error];
    if (!enabled) {
        NSLog(@"OAuth开启失败!");
        NSLog(@"%@", error);
    } else {
        NSLog(@"OAuth开启成功");
        
        [MRRequest setOAuthStatePeriodicCheckTimeInterval:5];
        NSLog(@"OAuth 每 %02.2f 秒检查一次状态", [MRRequest oAuthStatePeriodicCheckTimeInterval]);
        
        [MRRequest setOAuthAccessTokenAbnormalCustomPlanBlock:^{
            NSLog(@"我是自定义access_token失效预案方法");
        } replaceOrKeepBoth:NO];
        [MRRequest setOAuthRefreshTokenAbnormalCustomPlanBlock:^{
            NSLog(@"我是自定义refresh_token失效预案方法");
        } replaceOrKeepBoth:NO];
        
        
    }
    
    
    
    /* 开启方式:2 */
    /*
    [MRRequest setOAuthClientId:@"123456"];
    [MRRequest setOAuthClientSecret:@"000000"];
    [MRRequest setOAuthInfoAutodestructTimeInterval:60.0f];
    [MRRequest setOAuthEnabled:YES];
    [MRRequest setOAuthStatePeriodicCheckTimeInterval:5];
    [MRRequest setOAuthAccessTokenAbnormalCustomPlanBlock:^{
        NSLog(@"access_token失效时执行我");
    } replaceOrKeepBoth:NO];
    [MRRequest setOAuthRefreshTokenAbnormalCustomPlanBlock:^{
        NSLog(@"refresh_token失效时执行我");
    } replaceOrKeepBoth:NO];
     */
    
    
    
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
