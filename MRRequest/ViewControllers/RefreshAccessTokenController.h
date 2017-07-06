//
//  RefreshAccessTokenController.h
//  MRRequest
//
//  Created by MrXir on 2017/7/6.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MRFramework/UIStoryboard+Extension.h>
#import <MRFramework/UIControl+Extension.h>
#import <MRFramework/NSDictionary+Extension.h>
#import <MRFramework/NSString+Extension.h>
#import <MRFramework/NSObject+Extension.h>

#import <SVProgressHUD.h>

@interface RefreshAccessTokenController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *resetItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fillItem;

@property (weak, nonatomic) IBOutlet UIView *tableViewHeaderView;

@property (weak, nonatomic) IBOutlet UITextField *oauth_server;
@property (weak, nonatomic) IBOutlet UITextField *oauth_autodestruct;

@property (weak, nonatomic) IBOutlet UITextField *oauth_client_id;
@property (weak, nonatomic) IBOutlet UITextField *oauth_client_secret;
@property (weak, nonatomic) IBOutlet UITextField *oauth_grant_type;

@property (weak, nonatomic) IBOutlet UITextField *oauth_access_token;
@property (weak, nonatomic) IBOutlet UITextField *oauth_refresh_token;

@property (weak, nonatomic) IBOutlet UITextField *oauth_format;
@property (weak, nonatomic) IBOutlet UITextField *oauth_timestamp;
@property (weak, nonatomic) IBOutlet UITextField *oauth_sign;

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

@end
