//
//  NotePickerTVC.m
//  Memorandum
//
//  Created by Bardan Gauchan on 12/30/12.
//  Copyright (c) 2012 Bardan Gauchan. All rights reserved.
//

#import "NotePickerTVC.h"
#import "EvernoteNoteStore+Extras.h"
#import "EvernoteUserStore+Extras.h"
#import "EvernoteSession.h"
#import "Helper.h"
#import "SaveOrShareVC.h"
#import "Note.h"

@interface NotePickerTVC ()

@end

@implementation NotePickerTVC

@synthesize notebookGuid, notes;

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

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addLoadingAnimation];
    
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    EDAMNoteFilter *filter = [[EDAMNoteFilter alloc] init];
    [filter setNotebookGuid:self.notebookGuid];
    
    [noteStore findNotesWithFilter:filter offset:0 maxNotes:100 success:^(EDAMNoteList *list) {
        
        self.notes = list.notes;
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        NSLog(@"error retrieving notes for Recipes - %@", error);
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
    if([self.notes count] <1)
        [(UIActivityIndicatorView *)[self.view viewWithTag:12] stopAnimating];
    
    return [self.notes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"note cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    EDAMNote *note = [self.notes objectAtIndex:[indexPath row]];
    cell.textLabel.text = note.title;
    cell.textLabel.font = [Helper getDefaultRegularFont];
    
    // returning cell means that the loading is done and now the view controller is creating cells with data retrieved
    [(UIActivityIndicatorView *)[self.view viewWithTag:12] stopAnimating];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    if([[segue identifier] isEqualToString:@"share note"])
    {
        SaveOrShareVC *shareVC = segue.destinationViewController;
        EDAMNote *noteObject = (EDAMNote *)[self.notes objectAtIndex:[indexPath row]];
        Note *note = [[Note alloc] init];
        note.noteObject = noteObject;
        shareVC.selectedNote = note;
        shareVC.segueType = @"share note";
    }
}

@end
