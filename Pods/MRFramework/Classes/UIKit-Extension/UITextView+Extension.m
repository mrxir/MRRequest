//
//  UITextView+Extension.m
//  MRFramework
//
//  Created by Valentine on 2018/4/9.
//  Copyright © 2018年 MrXir. All rights reserved.
//

#import "UITextView+Extension.h"

@implementation UITextView (Extension)

- (void)setPlaceholder:(NSString *)placeholder
{
    UILabel *placeHolderLabel = [self viewWithTag:1924];
    
    if (!placeHolderLabel) {
        placeHolderLabel = [[UILabel alloc] init];
        placeHolderLabel.tag = 1924;
        [self addSubview:placeHolderLabel];
        [self setValue:placeHolderLabel forKey:@"_placeholderLabel"];
    }
    
    placeHolderLabel.text = placeholder;
    placeHolderLabel.numberOfLines = 0;
    placeHolderLabel.textColor = [UIColor lightGrayColor];
    [placeHolderLabel sizeToFit];
    placeHolderLabel.font = self.font;
    
}

@end
