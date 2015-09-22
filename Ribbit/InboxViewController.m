//
//  InboxViewController.m
//  Ribbit
//
//  Created by Joao Pescada on 03/06/2014.
//  Copyright (c) 2014 Joao Pescada. All rights reserved.
//

#import "InboxViewController.h"
#import "ImageViewController.h"
#import "MSCellAccessory/MSCellAccessory.h"

@interface InboxViewController ()

@end

@implementation InboxViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.moviePlayer = [[MPMoviePlayerViewController alloc] init];
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser){
        NSLog(@"Current User: %@", currentUser);
    }
    else
    {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(retrieveMessages) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:NO];
    
    [self retrieveMessages];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PFObject *message = [self.messages objectAtIndex:indexPath.row];
    cell.textLabel.text = message[@"senderName"];
    
    UIColor *disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1.0];
    cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:disclosureColor];
    
    NSString *fileType = message[@"fileType"];
    if ([fileType isEqualToString:@"image"])
    {
        //cell filetype is image
        cell.imageView.image = [UIImage imageNamed:@"icon_image"];
    }
    else
    {
        //cell filetype is movie
        cell.imageView.image = [UIImage imageNamed:@"icon_video"];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
    
    NSString *fileType = self.selectedMessage[@"fileType"];
    if ([fileType isEqualToString:@"image"])
    {
        //selected filetype is image
        [self performSegueWithIdentifier:@"showImage" sender:self];
    }
    else
    {
        //selected filetype is video
        PFFile *videoFile = [self.selectedMessage objectForKey:@"file"];
        NSURL *fileURL = [NSURL URLWithString:videoFile.url];
        self.moviePlayer.contentURL = fileURL;
        [self.moviePlayer prepareToPlay];
        //[self.moviePlayer thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];
    }
    
    //delete it
    NSMutableArray *recipientIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"recipientIds"]];
    NSLog(@"Recipients: %@", recipientIds);
    
    if (recipientIds.count == 1)
    {
        //last recipient, delete from backend
        [self.selectedMessage deleteInBackground];
        
        //TODO: delete file from backend using REST API
        //use NSMutableURLRequest to create a DELETE request (https://www.parse.com/questions/how-can-i-delete-a-file)
    }
    else
    {
        //remove recipient and save to backend
        [recipientIds removeObject:[[PFUser currentUser] objectId]];
        [self.selectedMessage setObject:recipientIds forKey:@"recipientIds"];
        [self.selectedMessage saveInBackground];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.identifier isEqualToString:@"showLogin"] )
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
    else if( [segue.identifier isEqualToString:@"showImage"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        ImageViewController *imageViewController = (ImageViewController *)segue.destinationViewController;
        imageViewController.message = self.selectedMessage;
    }
}

- (IBAction)logout:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}


#pragma mark - Helper methods

- (void)retrieveMessages
{
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"recipientIds" equalTo:[[PFUser currentUser] objectId]];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else
        {
            //messages found for current user
            self.messages = objects;
            [self.tableView reloadData];
            NSLog(@"Retrieved %lu messages", (unsigned long)self.messages.count);
        }
        
        if ([self.refreshControl isRefreshing]){
            [self.refreshControl endRefreshing];
        }
    }];
}

@end
