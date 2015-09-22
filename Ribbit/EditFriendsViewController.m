//
//  EditFriendsViewController.m
//  Ribbit
//
//  Created by Joao Pescada on 03/06/2014.
//  Copyright (c) 2014 Joao Pescada. All rights reserved.
//

#import "EditFriendsViewController.h"
#import "MSCellAccessory/MSCellAccessory.h"

@interface EditFriendsViewController ()

@end

@implementation EditFriendsViewController

UIColor *disclosureColor;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
        else
        {
            self.allUsers = objects;
            //NSLog(@"All users: %@", self.allUsers);
            [self.tableView reloadData];
        }
    }];
    
    self.currentUser = [PFUser currentUser];
    
    disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1.0];
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
    return self.allUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    if ([self isFriend:user])
    {
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:disclosureColor];
    }
    else
    {
        //cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    PFRelation *friendsRelation = [self.currentUser relationForKey:@"friendsRelation"];
    
    //NSLog(@"Is %@ a friend? %hhd", user.username, [self isFriend:user]);
    
    if ( [self isFriend:user] ) {

        //removing friend
        
        //1. remove checkmark
        //cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        
        //2. remove from local array of friends
        for (PFUser *friend in self.friends) {
            if ([friend.objectId isEqualToString:user.objectId])
            {
                [self.friends removeObject:friend];
                break;
            }
        }
        
        //3. remove from backend
        [friendsRelation removeObject:user];
    }
    else
    {
        //adding friend
        
        //1. add checkmark
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:disclosureColor];
        
        //2. add to local array of friends
        [self.friends addObject:user];
        
        //3. add to backend
        [friendsRelation addObject:user];

    }
    
    //save change to backend
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
    }];
    
}

#pragma mark - Helper methods

- (BOOL)isFriend:(PFUser *)user {
    for (PFUser *friend in self.friends) {
        if ([friend.objectId isEqualToString:user.objectId])
        {
            return YES;
        }
    }
    
    return NO;
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

@end
