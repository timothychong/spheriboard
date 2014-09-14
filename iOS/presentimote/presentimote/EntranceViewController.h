//
//  EntranceViewController.h
//  presentimote
//
//  Created by Timothy Chong on 9/14/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EntranceViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *roomCodeTextField;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
