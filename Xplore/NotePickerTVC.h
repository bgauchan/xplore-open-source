//
//  NotePickerTVC.h
//  Memorandum
//
//  Created by Bardan Gauchan on 12/30/12.
//  Copyright (c) 2012 Bardan Gauchan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotePickerTVC : UITableViewController

@property (nonatomic, strong) NSString *notebookGuid;
@property (nonatomic, strong) NSArray *notes;

@end
