//
//  HomeViewController.h
//  Espy
//
//  Created by Bardan Gauchan on 6/15/13.
//  Copyright (c) 2013 Bardan Gauchan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "EvernoteNoteStore.h"
#import "Note.h"

@interface HomeViewController : PFQueryTableViewController

@property (nonatomic, strong) Note *selectedNote;

- (IBAction)pickNoteToShare:(id)sender;

@end
