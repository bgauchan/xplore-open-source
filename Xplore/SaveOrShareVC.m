//
//  ShareViewController.m
//  Xplore
//
//  Created by Bardan Gauchan on 6/17/13.
//  Copyright (c) 2013 Bardan Gauchan. All rights reserved.
//

#import "SaveOrShareVC.h"
#import <Parse/Parse.h>
#import "EvernoteNoteStore+Extras.h"
#import "ENMLUtility.h"
#import "NotebookPickerTVC.h"
#import "NoteDetailVC.h"
#import "NSString+URLEncoding.h"
#import "Helper.h"

@interface SaveOrShareVC ()

@end

@implementation SaveOrShareVC

- (void)updateNotebookName:(NSString *)notebookName andGuid:(EDAMGuid)guid
{
    UIButton *notebookPickerButton = (UIButton *)[self.view viewWithTag:72];
    [notebookPickerButton setTitle:notebookName forState:UIControlStateNormal];
    
    self.selectedNote.notebookGuid = guid;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)giveFeedbackWithMessage:(NSString *)message
{
    UILabel *alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 60, 120, 50)];
    alertLabel.backgroundColor = [UIColor blackColor];
    alertLabel.textColor = [UIColor whiteColor];
    alertLabel.alpha = 0.8f;
    alertLabel.textAlignment = NSTextAlignmentCenter;
    alertLabel.text = message;
    
    [self.view addSubview:alertLabel];
    
    [UIView animateWithDuration:1 animations:^{
        alertLabel.alpha = 0.0;
    } completion:^(BOOL finished){
        [alertLabel removeFromSuperview];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (NSArray *)getNoteTags
{
    NSString *tags = self.tagsTextView.text;
    NSMutableArray *tempArray = [[tags componentsSeparatedByString:@"#"] mutableCopy];
    NSMutableArray *tagsArray = [[NSMutableArray alloc] init];
    
    if([tempArray count] > 0)
    {
        [tempArray removeObjectAtIndex:0];
    
        for(NSString *oldTag in tempArray)
        {
            NSString *newTag = [oldTag stringByReplacingOccurrencesOfString:@" " withString:@""];
            [tagsArray addObject:newTag];
        }
    }
    
    return tagsArray;
}

- (void)shareNote
{
    // atleast one tag needs to be entered
    if([self.tagsTextView.text length] > 0)
    {        
        self.selectedNote.title = self.titleTextView.text;
        self.selectedNote.tags = [self getNoteTags];
        
        [self giveFeedbackWithMessage:@"Shared."];
        [[self.selectedNote getParseNoteObject] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded)
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:nil];
        }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:@"You need to enter atleast one tag"
                                                    delegate:self
                                           cancelButtonTitle:@"Ok"
                                           otherButtonTitles:nil];
        [alert show];
    }
}

- (void)addLoadingAnimation
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 120);
    spinner.tag = 12;
    [self.view addSubview:spinner];
    [spinner startAnimating];
}

- (void)saveNote
{
    [self addLoadingAnimation];
    
    // Create note object
    EDAMNote *ourNote = [[EDAMNote alloc] initWithGuid:nil title:self.titleTextView.text
                                               content:self.selectedNote.noteObject.content contentHash:nil contentLength:self.selectedNote.noteObject.content.length
                                               created:0 updated:0 deleted:0 active:YES updateSequenceNum:0
                                                notebookGuid:self.selectedNote.notebookGuid tagGuids:nil resources:self.selectedNote.noteObject.resources
                                                attributes:self.selectedNote.noteObject.attributes tagNames:[[self getNoteTags] mutableCopy]];
    
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    [noteStore createNote:ourNote success:^(EDAMNote *note) {
        
        // update the number of saves by 1
        PFObject *noteObject = [PFObject objectWithoutDataWithClassName:@"Note" objectId:self.selectedNote.objectId];
        self.selectedNote.numberOfSaves += 1;
        [noteObject setObject:[NSNumber numberWithInt:self.selectedNote.numberOfSaves] forKey:@"saves"];
        [noteObject saveInBackground];
        
        [self giveFeedbackWithMessage:@"Clipped"];
        [(UIActivityIndicatorView *)[self.view viewWithTag:12] stopAnimating];        
        
    } failure:^(NSError *error) {
        [self giveFeedbackWithMessage:@"Failed!"];
        NSLog(@"%@", error);
        [(UIActivityIndicatorView *)[self.view viewWithTag:12] stopAnimating];
    }];
}

- (NSString *)populateTags:(NSArray *)tags
{
    NSMutableString *allTags = [[NSMutableString alloc] init];
    
    for (NSString *tag in tags)
    {
        [allTags appendString:@"#"];
        [allTags appendString:tag];
        [allTags appendString:@" "];
    }
    
    return allTags;
}

- (void)openSafari
{
    if([self.urlLabel.text length] > 0)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlLabel.text]];
}

- (void)pickNotebook
{
    [self performSegueWithIdentifier:@"pick notebook" sender:self];
}

- (void)loadHTML
{
    ENMLUtility *utility = [[ENMLUtility alloc] init];
    [utility convertENMLToHTML:self.selectedNote.noteObject.content withResources:self.selectedNote.noteObject.resources completionBlock:^(NSString *html, NSError *error) {
        
        if(error == nil)
        {
            html = [html stringByReplacingOccurrencesOfString:@"<body>" withString:@"<body style='font-family:HelveticaNeue-Light; font-size:14pt; padding:5px;'>"];
            html = [html stringByReplacingOccurrencesOfString:@"<img" withString:@"<img style='max-width: 100%; width: auto; height: auto;'"];
            [self.webView loadHTMLString:html baseURL:nil];
            self.webView.delegate = self;
        }
    }];
}

- (void)setTagNamesArray:(NSArray *)tagsGuid
{
    NSMutableArray *tags = [[NSMutableArray alloc]init];
    
    for (NSString *guid in tagsGuid)
    {
        [[EvernoteNoteStore noteStore] getTagWithGuid:guid success:^(EDAMTag *tag) {
            
            self.tagsTextView.text = [self.tagsTextView.text stringByAppendingString:@"#"];
            self.tagsTextView.text = [self.tagsTextView.text stringByAppendingString:tag.name];
            self.tagsTextView.text = [self.tagsTextView.text stringByAppendingString:@" "];
            
            [tags addObject:tag.name];
            
            if([tagsGuid lastObject] == guid)
                self.selectedNote.tags = tags;
            
        } failure:^(NSError *error) {
        }];
    }    
}

- (void)populateDataFromEDAMNote:(EDAMNote *)noteObject
{   	
    [[EvernoteNoteStore noteStore] getNoteWithGuid:noteObject.guid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *edamNote) {
        
        [self setTagNamesArray:edamNote.tagGuids];
        self.selectedNote.noteObject = edamNote;
        self.selectedNote.title = edamNote.title;
        self.selectedNote.sourceUrl = edamNote.attributes.sourceURL;
        
        // resources
        EDAMResource *resource;
        
        if(edamNote.resources.count > 0)
            resource = [edamNote.resources objectAtIndex:edamNote.resources.count - 1];
        
        if([resource.mime isEqualToString:@"image/jpeg"]
           || [resource.mime isEqualToString:@"image/png"]
           || [resource.mime isEqualToString:@"image/gif"])
        {
            @try {
                self.selectedNote.thumbnail = [PFFile fileWithName:@"thumbnail.png" data:resource.data.body];
            }
            @catch (NSException *exception) {
                NSLog(@"Exception: %@", [exception description]);
            }
        }
        else
            self.selectedNote.thumbnail = (PFFile *)[NSNull null];
        
        self.titleTextView.text = self.selectedNote.title;
        
        self.urlLabel.text = self.selectedNote.sourceUrl;
        self.urlLabel.numberOfLines = 2;
        [self.urlLabel sizeToFit];
        [(UIActivityIndicatorView *)[self.view viewWithTag:12] stopAnimating];
        
        [self loadHTML];
        
    } failure:^(NSError *error) {
        NSLog(@"Failed to get note : %@",error);
    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    // only load the data once
    // once the fields have been set, no need to do that all over again
    if([self.titleTextView.text length] < 1)
    {
        if([self.segueType isEqualToString:@"share note"])
        {
            [self.shareButton setTitle:@"Share Note" forState:UIControlStateNormal];
            [self.shareButton addTarget:self action:@selector(shareNote) forControlEvents:UIControlEventTouchUpInside];
            [self populateDataFromEDAMNote:self.selectedNote.noteObject];
            
            self.shareButton.backgroundColor = [Helper getColorFromHex:0x00b3b3];
            self.viewButton.backgroundColor = [Helper getColorFromHex:0x00b3b3];
            
            self.urlOrNotebookLabel.text = @"Url";
        }
        else
        {
            [self.shareButton setTitle:@"Save to Evernote" forState:UIControlStateNormal];
            [self.shareButton setBackgroundColor:[Helper getColorFromHex:0x31a222]];
            [self.shareButton addTarget:self action:@selector(saveNote) forControlEvents:UIControlEventTouchUpInside];
            
            self.titleTextView.text = self.selectedNote.title;
            self.urlLabel.hidden = YES;
            self.urlOrNotebookLabel.text = @"Notebook";
            self.tagsTextView.text = [self populateTags:self.selectedNote.tags];
            
            UIButton *notebookSelectorButton = [[UIButton alloc] initWithFrame:CGRectMake(127, 96, 164, 30)];
            [notebookSelectorButton setTitle:@"Pick a Notebook" forState:UIControlStateNormal];
            [notebookSelectorButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [notebookSelectorButton addTarget:self action:@selector(pickNotebook) forControlEvents:UIControlEventTouchUpInside];
            notebookSelectorButton.titleLabel.font = [Helper getDefaultRegularFont];
            notebookSelectorButton.backgroundColor = [Helper getColorFromHex:0xd7dce4];
            notebookSelectorButton.userInteractionEnabled = YES;            
            notebookSelectorButton.layer.borderWidth = 0.5;
            notebookSelectorButton.layer.borderColor = [[Helper getColorFromHex:0xcfcfcf] CGColor];
            notebookSelectorButton.layer.cornerRadius = 2;
            notebookSelectorButton.tag = 72;

            [self.view addSubview:notebookSelectorButton];
            
            [(UIActivityIndicatorView *)[self.view viewWithTag:12] stopAnimating];
        }
    }
    
    self.titleTextView.delegate = self;
    self.tagsTextView.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addLoadingAnimation];
    
    self.urlLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openSafari)];
    [self.urlLabel addGestureRecognizer:tapGesture];
    
    self.backgroundView.layer.borderWidth = 0.5;
    self.backgroundView.layer.borderColor = [[Helper getColorFromHex:0xcfcfcf] CGColor];
    
    self.titleTextView.layer.borderWidth = 0.5;
    self.titleTextView.layer.borderColor = [[Helper getColorFromHex:0xcfcfcf] CGColor];
    self.titleTextView.font = [Helper getDefaultRegularFont];
    self.titleTextView.returnKeyType = UIReturnKeyDone;
    
    self.tagsTextView.layer.borderWidth = 0.5;
    self.tagsTextView.layer.borderColor = [[Helper getColorFromHex:0xcfcfcf] CGColor];
    self.tagsTextView.font = [Helper getDefaultRegularFont];
    self.tagsTextView.returnKeyType = UIReturnKeyDone;
    
    self.urlLabel.font = [Helper getDefaultRegularFont];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.selectedNote.text = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText.trim()"];
}

- (BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"view note"])
    {
        NoteDetailVC *noteDetailVC = segue.destinationViewController;
        noteDetailVC.selectedNote = self.selectedNote;
    }
    else if ([[segue identifier] isEqualToString:@"pick notebook"])
    {
        NotebookPickerTVC *notebookPickerTVC = segue.destinationViewController;
        notebookPickerTVC.delegate = self;
    }
}

@end
