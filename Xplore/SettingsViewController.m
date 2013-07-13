

#import "SettingsViewController.h"
#import "EvernoteSession.h"
#import "Helper.h"
#import "EvernoteUserStore+Extras.h"
#import <Parse/Parse.h>
#import "UIImage+ResizeAdditions.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // button index 1 means the user clicked "Ok"
    if(buttonIndex == 0)
    {
        [PFUser logOut];
        [[EvernoteSession sharedSession] logout];
        [self.signInBtn setTitle:@"Sign Into Evernote" forState:UIControlStateNormal];
        self.signInBtn.backgroundColor = [Helper getColorFromHex:0x00b3b3];
        
        self.nameLabel.text = @"";
        self.addPictureLabel.text = @"";
        
        self.profileImageView.image = [UIImage imageNamed:@"profile.png"];
        [self.sharedNotesButton setTitle:@"" forState:UIControlStateNormal];
    }
}

- (IBAction)showSharedNotes:(id)sender
{
    if([PFUser currentUser])
        [self performSegueWithIdentifier:@"show shared notes" sender:self];
}

- (IBAction)signInOrSignOut:(id)sender
{
    if(![PFUser currentUser])
    {
        // Create local reference to shared session singleton
        EvernoteSession *session = [EvernoteSession sharedSession];
        
        [session authenticateWithViewController:self completionHandler:^(NSError *error){
            
            // Authentication response is handled in this block
            if (error || !session.isAuthenticated)
            {
                // Either we couldn't authenticate or something else went wrong - inform the user
                if (error) {
                    NSLog(@"Error authenticating with Evernote service: %@", error);
                }
                if (!session.isAuthenticated) {
                    NSLog(@"User could not be authenticated.");
                }
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Could not authenticate"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                EvernoteUserStore *userStore = [[EvernoteUserStore alloc] initWithSession:session];
                [userStore getUserWithSuccess:^(EDAMUser *user) {
                    
                    PFUser *newUser = [PFUser user];
                    
                    [newUser setValue:user.username forKey:@"username"];

                    if(user.name)
                        [newUser setValue:user.name forKey:@"name"];
                    else
                        [newUser setObject:@"" forKey:@"name"];
                        
                    [newUser setValue:@"" forKey:@"password"];
                    
                    if(!user.email)
                        [newUser setValue:[[Helper getRandomPassword] stringByAppendingString:@"@email.com"] forKey:@"email"];
                    else
                        [newUser setValue:user.email forKey:@"email"];
                    
                    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if(error)
                            [PFUser logInWithUsername:user.username password:@""];
                        
                        [self.signInBtn setTitle:@"Sign Out of Evernote" forState:UIControlStateNormal];
                        self.signInBtn.backgroundColor = [Helper getColorFromHex:0x31a222];
                        [self fillOutProfile];
                        
                    }];
                } failure:^(NSError *error) {
                    
                }];
            }
            
        }];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning!!" message:@"Are you sure you want to sign out of Evernote?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        [alertView show];        
    }
}

- (void)fillOutProfile
{
    if([PFUser currentUser])
    {
        UIImage *profileImage = [[PFUser currentUser] valueForKey:@"image"];
        if(profileImage)
        {
            self.profileImageView.image = profileImage;
        }
        else
        {
            self.profileImageView.image = [UIImage imageNamed:@"profile.png"];
            //self.addPictureLabel.text = @"Add picture";
            self.addPictureLabel.textAlignment = NSTextAlignmentCenter;
            self.addPictureLabel.numberOfLines = 2;
            self.addPictureLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        }
        
        self.nameLabel.text = [[PFUser currentUser] valueForKey:@"name"];
        self.nameLabel.textColor = [Helper getColorFromHex:0x1d1d1d];
        self.nameLabel.font = [UIFont fontWithName:@"HelveticaLight-Neue" size:16];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Note"];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            [self.sharedNotesButton setTitleColor:[Helper getColorFromHex:0x1d1d1d] forState:UIControlStateNormal];
            
            NSString *sharedCount = [[NSString stringWithFormat:@"%i", number] stringByAppendingString:@" notes shared                         >"];
            [self.sharedNotesButton setTitle:sharedCount forState:UIControlStateNormal];
        }];
    }
    else
    {
        self.profileImageView.image = [UIImage imageNamed:@"profile.png"];
    }
    
    self.backgroundView.layer.borderWidth = 0.5;
    self.backgroundView.layer.borderColor = [[Helper getColorFromHex:0xc1c2c2] CGColor];
    self.profileImageView.layer.borderWidth = 0.5;
    self.profileImageView.layer.borderColor = [[Helper getColorFromHex:0xc1c2c2] CGColor];
    self.profileImageView.layer.cornerRadius = 40;
    self.profileImageView.layer.masksToBounds = YES;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(25, 120, 270, 0.5)];
    lineView.backgroundColor = [Helper getColorFromHex:0xc1c2c2];
    [self.view addSubview:lineView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.view.backgroundColor = [Helper getColorFromHex:0xd7dce4];
    
    if([PFUser currentUser])
    {    
        [self.signInBtn setTitle:@"Sign Out of Evernote" forState:UIControlStateNormal];
        self.signInBtn.backgroundColor = [Helper getColorFromHex:0x31a222];
    }
    else
    {
        [self.signInBtn setTitle:@"Sign Into Evernote" forState:UIControlStateNormal];
        self.signInBtn.backgroundColor = [Helper getColorFromHex:0x00b3b3];
    }
    
    [self fillOutProfile];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
