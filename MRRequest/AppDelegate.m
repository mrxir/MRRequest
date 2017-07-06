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

#import "RequestAccessTokenController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (UINavigationController *)rootViewController
{
    return (id)self.window.rootViewController;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [MRRequest setLogLevel:MRRequestLogLevelVerbose];
    
    NSError *error = nil;
    [MRRequest enableOAuthRequestWithServer:@"http://10.0.40.119:8080/oauth/token?"
                                   clientId:@"ff2ff059d245ae8cb378ab54a92e966d"
                               clientSecret:@"01f32ac28d7b45e08932f11a958f1d9f"
                   autodestructTimeInterval:41.0f
                                   anyError:&error];
    
    [MRRequest setOAuthStatePeriodicCheckTimeInterval:1];
    [MRRequest setOAuthStatePeriodicCheckEnabled:YES];
    
    [MRRequest setOAuthAccessTokenAbnormalCustomPlanBlock:^{
        NSLog(@"我是自定义access_token失效预案方法");
    } replaceOrKeepBoth:NO];
    
    [MRRequest setOAuthRefreshTokenAbnormalCustomPlanBlock:^{
        NSLog(@"我是自定义refresh_token失效预案方法");
        
        UIViewController *top = [[self rootViewController] topViewController];
        
        if (![top isKindOfClass:[RequestAccessTokenController class]]) {
            UIViewController *vc = [RequestAccessTokenController matchControllerForMyself];
            [[self rootViewController] pushViewController:vc animated:YES];
        }
        
    } replaceOrKeepBoth:NO];
    
    [UIStoryboard setStoryboardNames:@[@"Main",
                                       @"OAuthRequest",
                                       @"CommonRequest"]];
    
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
