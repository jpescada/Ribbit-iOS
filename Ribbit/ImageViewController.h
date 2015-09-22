//
//  ImageViewController.h
//  Ribbit
//
//  Created by Joao Pescada on 04/06/2014.
//  Copyright (c) 2014 Joao Pescada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface ImageViewController : UIViewController

@property (nonatomic, strong) PFObject *message;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
