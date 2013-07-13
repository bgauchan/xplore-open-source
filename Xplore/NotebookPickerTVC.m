//
//  NotebookPickerTVC.m
//  Espy
//
//  Created by Bardan Gauchan on 6/15/13.
//  Copyright (c) 2013 Bardan Gauchan. All rights reserved.
//

#import "NotebookPickerTVC.h"
#import "EvernoteNoteStore+Extras.h"
#import "NotePickerTVC.h"
#import "Helper.h"

@interface NotebookPickerTVC ()

@end

@implementation NotebookPickerTVC

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addLoadingAnimation
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.tag = 12;
    [self.view addSubview:spinner];
    [spinner startAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addLoadingAnimation];
    
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    
    [noteStore listNotebooksWithSuccess:^(NSArray *notebooks) {
        
        self.allNotebooks = notebooks;
        [self.tableView reloadData];
        
        [(UIActivityIndicatorView *)[self.view viewWithTag:12] stopAnimating];
        
    } failure:^(NSError *error) {
        NSLog(@"Error listing notebooks. Cause => %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allNotebooks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"notebook cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    EDAMNotebook *notebook = (EDAMNotebook *)[self.allNotebooks objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = notebook.name;
    cell.textLabel.font = [Helper getDefaultRegularFont];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EDAMNotebook *notebook = (EDAMNotebook *)[self.allNotebooks objectAtIndex:[indexPath row]];
    [self.delegate updateNotebookName:notebook.name andGuid:notebook.guid];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    if([[segue identifier] isEqualToString:@"choose note"])
    {
        EDAMNotebook *selectedNotebook = (EDAMNotebook *)[self.allNotebooks objectAtIndex:[indexPath row]];
        NotePickerTVC *notePickerTVC = segue.destinationViewController;
        notePickerTVC.notebookGuid = selectedNotebook.guid;
    }
}


@end
