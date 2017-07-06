//
//  QueryVehicleIdentifierController.h
//  MRRequest
//
//  Created by MrXir on 2017/7/6.
//  Copyright © 2017年 MrXir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QueryVehicleIdentifierController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *resetItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fillItem;

@property (weak, nonatomic) IBOutlet UIView *tableViewHeaderView;

@property (weak, nonatomic) IBOutlet UITextField *vehicleIdentifier;

@property (weak, nonatomic) IBOutlet UIButton *queryButton;

@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

@end
