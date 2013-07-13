

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) IBOutlet UIImageView *profileImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *addPictureLabel;
@property (nonatomic, strong) IBOutlet UIButton *sharedNotesButton;
@property (nonatomic, strong) IBOutlet UIButton *signInBtn;

- (IBAction)signInOrSignOut:(id)sender;
- (IBAction)showSharedNotes:(id)sender;
@end
