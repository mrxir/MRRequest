//
//  OAuthErrorCodeHandleController.h
//  MRRequest
//
//  Created by MrXir on 2017/7/7.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OAuthErrorCodeHandleController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *generateOAuthButton;

@property (weak, nonatomic) IBOutlet UIButton *generateUpdateButton;

@property (weak, nonatomic) IBOutlet UIButton *generateCommonButton;

@property (weak, nonatomic) IBOutlet UIButton *executeOAuthButton;

@property (weak, nonatomic) IBOutlet UIButton *executeUpdateButton;

@property (weak, nonatomic) IBOutlet UIButton *executeCommonButton;

@property (weak, nonatomic) IBOutlet UIButton *invalidate_client_id;

@property (weak, nonatomic) IBOutlet UIButton *invalidate_client_secret;

@property (weak, nonatomic) IBOutlet UIButton *invalidate_username;

@property (weak, nonatomic) IBOutlet UIButton *invalidate_password;

@property (weak, nonatomic) IBOutlet UIButton *invalidate_grant_type;

@property (weak, nonatomic) IBOutlet UIButton *invalidate_sign;

@property (weak, nonatomic) IBOutlet UIButton *invalidate_format;

@property (weak, nonatomic) IBOutlet UIButton *invalidate_access_token;

@property (weak, nonatomic) IBOutlet UIButton *invalidate_refresh_token;

@property (weak, nonatomic) IBOutlet UIButton *invalidate_parameter;

@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

@end
