//
//  NoteDetailVC.m
//  Memorandum
//
//  Created by Bardan Gauchan on 1/1/13.
//  Copyright (c) 2013 Bardan Gauchan. All rights reserved.
//

#import "NoteDetailVC.h"
#import "Helper.h"
#import "EvernoteNoteStore+Extras.h"
#import "ENMLUtility.h"
#import "SaveOrShareVC.h"
#import "NoteAttributesTVC.h"
#import "NSData+EvernoteSDK.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>

@interface NoteDetailVC ()

@end

@implementation NoteDetailVC

#pragma mark -
#pragma Delegates

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openNoteUrl:(UITapGestureRecognizer *)sender
{
    UILabel *urlLabel = (UILabel *)sender.view;
    NSString *url = urlLabel.text;
    
    if([url length] > 0)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)addLoadingAnimation
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.tag = 12;
    [self.view addSubview:spinner];
    [spinner startAnimating];
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
        [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshList" object:nil];
    }];
}

- (void)removeShadowFromWebView:(UIWebView *)webView
{ 
    for (UIView* subView in [webView subviews])
    {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            for (UIView* shadowView in [subView subviews])
            {
                if ([shadowView isKindOfClass:[UIImageView class]]) {
                    [shadowView setHidden:YES];
                }
            }
        }
    }
}

- (void)deleteNote
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning!!" message:@"Are you sure you want to delete this note?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [alertView show];
}

- (void)saveToEvernote
{
    if(![PFUser currentUser])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You need to be logged into Evernote in order to save a note." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [alertView show];
    }
    else
    {
        UIStoryboard *shareStoryboard = [UIStoryboard storyboardWithName:@"SaveNote" bundle:nil];
        UINavigationController *navController = [shareStoryboard instantiateInitialViewController];
        navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        SaveOrShareVC *saveOrShareVC = (SaveOrShareVC *)navController.topViewController;
        saveOrShareVC.selectedNote = self.selectedNote;
        saveOrShareVC.segueType = @"save note";
        
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (void)showNoteAttributes
{
    UIStoryboard *shareStoryboard = [UIStoryboard storyboardWithName:@"NoteAttributes" bundle:nil];
    UINavigationController *navController = [shareStoryboard instantiateInitialViewController];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    NoteAttributesTVC *noteAttributesTVC = (NoteAttributesTVC *)navController.topViewController;
    noteAttributesTVC.selectedNote = self.selectedNote;
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)loadHTML
{    
    ENMLUtility *utility = [[ENMLUtility alloc] init];
    [utility convertENMLToHTML:self.selectedNote.noteObject.content withResources:self.selectedNote.noteObject.resources completionBlock:^(NSString *html, NSError *error) {
        
        if(error == nil)
        {
            html = [html stringByReplacingOccurrencesOfString:@"<body>" withString:@"<body style='font-family:HelveticaNeue-Light; font-size:13pt; padding:5px;'>"];
            html = [html stringByReplacingOccurrencesOfString:@"<img" withString:@"<img style='max-width: 100%; width: auto; height: auto;'"];
            
            [self.noteContentView loadHTMLString:html baseURL:nil];
            self.noteContentView.delegate = self;
        }
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!self.noteContentView)
    {
        self.noteContentView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 575)];
        [self.view addSubview:self.noteContentView];
    }
    
    self.noteContentView.delegate = self;
    self.noteContentView.scalesPageToFit = NO;
    [self addLoadingAnimation];
    [self removeShadowFromWebView:self.noteContentView];
    
    NSMutableArray* buttons = [[NSMutableArray alloc] init];
    
    if([self.segueType isEqualToString:@"main home view note"])
    {        
        UIBarButtonItem *saveToEvernoteBtn = [Helper getBarButtonItemUsingImageName:@"saveToEvernoteBtn.png" withSelector:@selector(saveToEvernote) forTarget:self];
        [buttons addObject:saveToEvernoteBtn];
        
        PFFile *noteFile = self.selectedNote.noteFile;
        [noteFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            self.selectedNote.noteObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [self loadHTML];
        }];
    }
    else
        [self loadHTML];
    
    UIBarButtonItem *infoBtn = [Helper getBarButtonItemUsingImageName:@"infoBtn.png" withSelector:@selector(showNoteAttributes) forTarget:self];
    [buttons addObject:infoBtn];
    
    if([self.selectedNote.username isEqualToString:[[PFUser currentUser] username]])
    {
        UIBarButtonItem *deleteBtn = [Helper getBarButtonItemUsingImageName:@"deleteBtn.png" withSelector:@selector(deleteNote) forTarget:self];
        [buttons addObject:deleteBtn];
    }
    
    self.navigationItem.rightBarButtonItems = buttons;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [(UIActivityIndicatorView *)[self.view viewWithTag:12] stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // button index 0 means the user clicked "Ok"
    if(buttonIndex == 0)
    {
        if([self.selectedNote.username isEqualToString:[[PFUser currentUser] username]])
        {
            PFQuery *query = [PFQuery queryWithClassName:@"Note"];
            [query whereKey:@"objectId" equalTo:self.selectedNote.objectId];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if(!error)
                {
                    if([objects count] > 0)
                    {
                        PFObject *note = [objects objectAtIndex:0];
                        [note deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if(succeeded)
                            {
                                [self giveFeedbackWithMessage:@"Deleted!"];
                            }
                        }];
                    }
                }
            }];
        }
    }
}

@end
