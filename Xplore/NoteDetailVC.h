//
//  NoteDetailVC.h
//  Memorandum
//
//  Created by Bardan Gauchan on 1/1/13.
//  Copyright (c) 2013 Bardan Gauchan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDAMNoteStore.h"
#import "Note.h"

@interface NoteDetailVC : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSString *segueType;
@property (nonatomic, strong) Note *selectedNote;

@property (nonatomic, strong) IBOutlet UIWebView *noteContentView;

- (IBAction)cancel:(id)sender;

@end
