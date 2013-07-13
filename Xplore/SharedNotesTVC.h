//
//  SharedNotesVC.h
//  Xplore
//
//  Created by Bardan Gauchan on 7/3/13.
//  Copyright (c) 2013 Bardan Gauchan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Note.h"

@interface SharedNotesTVC : PFQueryTableViewController

@property (nonatomic, strong) Note *selectedNote;

@end
