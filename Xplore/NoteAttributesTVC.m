//
//  NoteAttributesTVC.m
//  Xplore
//
//  Created by Bardan Gauchan on 6/27/13.
//  Copyright (c) 2013 Bardan Gauchan. All rights reserved.
//

#import "NoteAttributesTVC.h"
#import "EvernoteUserStore+Extras.h"
#import "Helper.h"
#import "NSDate+EDAMAdditions.h"

@interface NoteAttributesTVC ()

@end

@implementation NoteAttributesTVC

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 5;
}

- (void)openSafari:(NSString *)url
{
    if([url length] > 0)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == 2)
    {
        NSString *url = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
        [self openSafari:url];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"attribute cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.font = [Helper getDefaultMainFont];
    cell.detailTextLabel.font = [Helper getDefaultRegularFont];
    
    
    if([indexPath row] == 0)
    {
        cell.textLabel.text = @"Title";
        cell.detailTextLabel.text = self.selectedNote.title;
    }
    else if([indexPath row] == 1)
    {
        if(self.selectedNote.createdDate)
        {
            cell.textLabel.text = @"Shared By";
            cell.detailTextLabel.text = self.selectedNote.user;
        }
        else
        {
            cell.textLabel.text = @"Created By";
            cell.detailTextLabel.text = [[PFUser currentUser] valueForKey:@"name"];
        }
        
    }
    else if ([indexPath row] == 2)
    {
        cell.textLabel.text = @"Source Url";
        cell.detailTextLabel.text = self.selectedNote.sourceUrl;
        cell.detailTextLabel.textColor = [UIColor blueColor];
    }
    else if ([indexPath row] == 3)
    {
        cell.textLabel.text = @"Tags";
        cell.detailTextLabel.text = [Helper getStringFromArrayOfStrings:self.selectedNote.tags];
    }
    else if ([indexPath row] == 4)
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd-MMM-yyyy HH:mm:ss"];
        
        if(self.selectedNote.createdDate)
        {
            cell.textLabel.text = @"Shared On";
            cell.detailTextLabel.text = [dateFormat stringFromDate:self.selectedNote.createdDate];
        }
        else
        {
            cell.textLabel.text = @"Created On";
            cell.detailTextLabel.text = [dateFormat stringFromDate:[NSDate endateFromEDAMTimestamp:self.selectedNote.noteObject.created]];
        }
        
    }
    
    return cell;
}


@end
