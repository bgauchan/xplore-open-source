//
//  NoteAttributesTVC.h
//  Xplore
//
//  Created by Bardan Gauchan on 6/27/13.
//  Copyright (c) 2013 Bardan Gauchan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvernoteNoteStore.h"
#import "Note.h"

@interface NoteAttributesTVC : UITableViewController

@property (nonatomic, strong) Note *selectedNote;

- (IBAction)cancel:(id)sender;

@end
