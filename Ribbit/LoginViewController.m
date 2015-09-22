//
//  LoginViewController.m
//  Ribbit
//
//  Created by Joao Pescada on 03/06/2014.
//  Copyright (c) 2014 Joao Pescada. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
    if ([UIScreen mainScreen].bounds.size.height == 568) {
        NSLog(@"Swapping login background for 568 version");
        self.backgroundImageView.image = [UIImage imageNamed:@"loginBackground-568h"];
    }
    */
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)login:(id)sender {
    //collect user input
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //validate user input
    if ( username.length == 0 || password.length == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure you enter a username and password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
            else
            {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
}


@end
