//
//  MobileLoginViewController.h
//  MRRequest
//
//  Created by MrXir on 2017/7/6.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MobileLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *resetItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fillItem;

@property (weak, nonatomic) IBOutlet UIView *tableViewHeaderView;

@property (weak, nonatomic) IBOutlet UITextField *mobile;
@property (weak, nonatomic) IBOutlet UITextField *captcha;

@property (weak, nonatomic) IBOutlet UIButton *captchaButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

@end
