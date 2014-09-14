//
//  EntranceViewController.m
//  presentimote
//
//  Created by Timothy Chong on 9/14/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import "EntranceViewController.h"
#import "BoardViewController.h"
#define MAS_SHORTHAND
#import <Masonry/Masonry.h>


@implementation EntranceViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self.logo makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view.top).offset(150);
//    }];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"mainSegue"])
    {
        // Get reference to the destination view controller
        BoardViewController *vc = [segue destinationViewController];
        
        vc.roomCode = self.roomCodeTextField.text;
    }
}


#pragma  mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
//    [UIView animateWithDuration:0.3 animations:^{
//        [self.logo updateConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.view.top).offset(50);
//        }];
//    }];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end

