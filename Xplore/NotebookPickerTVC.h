//
//  NotebookPickerTVC.h
//  Espy
//
//  Created by Bardan Gauchan on 6/15/13.
//  Copyright (c) 2013 Bardan Gauchan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvernoteNoteStore+Extras.h"

@protocol NotebookPickerDelegate <NSObject>

- (void)updateNotebookName:(NSString *)notebookName andGuid:(EDAMGuid)guid;

@end

@interface NotebookPickerTVC : UITableViewController

@property (nonatomic, strong) NSArray *allNotebooks;
@property (nonatomic, strong) id <NotebookPickerDelegate> delegate;

- (IBAction)cancel:(id)sender;

@end
