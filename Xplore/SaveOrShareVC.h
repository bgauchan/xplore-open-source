//
//  ShareViewController.h
//  Xplore
//
//  Created by Bardan Gauchan on 6/17/13.
//  Copyright (c) 2013 Bardan Gauchan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "EDAMNoteStore.h"
#import "NotebookPickerTVC.h"
#import "Note.h"

@interface SaveOrShareVC : UIViewController <UIWebViewDelegate, NotebookPickerDelegate, UITextViewDelegate>

@property (nonatomic, strong) Note *selectedNote;
@property (nonatomic, strong) NSString *segueType;

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UITextView *titleTextView;
@property (nonatomic, strong) IBOutlet UILabel *urlOrNotebookLabel;
@property (nonatomic, strong) IBOutlet UILabel *urlLabel;
@property (nonatomic, strong) IBOutlet UILabel *tagsLabel;
@property (nonatomic, strong) IBOutlet UITextView *tagsTextView;
@property (nonatomic, strong) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) IBOutlet UIButton *viewButton;
@property (nonatomic, strong) IBOutlet UIView *backgroundView;

- (IBAction)cancel:(id)sender;

@end
