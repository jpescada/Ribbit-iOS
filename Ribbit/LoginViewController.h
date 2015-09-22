//
//  LoginViewController.h
//  Ribbit
//
//  Created by Joao Pescada on 03/06/2014.
//  Copyright (c) 2014 Joao Pescada. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (IBAction)login:(id)sender;

@end
