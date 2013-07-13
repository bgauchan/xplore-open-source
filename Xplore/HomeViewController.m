
#import "HomeViewController.h"
#import "Helper.h"
#import "NoteDetailVC.h"
#import "Note.h"
#import "NotebookPickerTVC.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)addTimeSoFarWithNote:(Note *)note andCell:(UITableViewCell *)cell andYCoordinate:(CGFloat)yCoordinate
{
    // time so far
    NSDate *createdDate = note.createdDate;
    NSDate *currentDate = [[NSDate alloc] init];
    double timeDifference = [currentDate timeIntervalSinceDate:createdDate];
    NSString *timeSoFar;
    
    if(timeDifference < 60)
    {
        timeSoFar = [NSString stringWithFormat:@"%i", (int)round((timeDifference * 1000) / 1000)];
        timeSoFar = [timeSoFar stringByAppendingString:@"s"];
    }
    else if(timeDifference < 3600)
    {
        timeDifference = timeDifference / 60;
        timeSoFar = [NSString stringWithFormat:@"%i", (int)round((timeDifference * 1000) / 1000)];
        timeSoFar = [timeSoFar stringByAppendingString:@"m"];
    }
    else if(timeDifference < 86400)
    {
        timeDifference = timeDifference / 3600;
        timeSoFar = [NSString stringWithFormat:@"%i", (int)round((timeDifference * 1000) / 1000)];
        timeSoFar = [timeSoFar stringByAppendingString:@"h"];
    }
    else
    {
        timeDifference = timeDifference / 86400;
        timeSoFar = [NSString stringWithFormat:@"%i", (int)round((timeDifference * 1000) / 1000)];
        timeSoFar = [timeSoFar stringByAppendingString:@"d"];
    }
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, yCoordinate, 200, 20)];
    dateLabel.text = timeSoFar;
    dateLabel.textAlignment = NSTextAlignmentRight;
    dateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    dateLabel.textColor = [Helper getColorFromHex:0x4f5557];
    [cell.contentView addSubview:dateLabel];
}

- (IBAction)pickNoteToShare:(id)sender
{
    if(![PFUser currentUser])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You need to be logged into Evernote in order to share a note." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [alertView show];
    }
    else
    {
        UIStoryboard *shareStoryboard = [UIStoryboard storyboardWithName:@"ShareNote" bundle:nil];
        UINavigationController *navController = [shareStoryboard instantiateInitialViewController];
        navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    
    if (self)
    {
        // Customize the table
        
        // The className to query on
        self.parseClassName = @"Note";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"title";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 50;
    }
    return self;
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query includeKey:@"user"];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table and then subsequently do a query
    // against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByDescending:@"createdAt"];
    
    return query;
}

- (void)refresh
{
    [self loadObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"refreshList" object:nil];
    self.tableView.backgroundColor = [Helper getColorFromHex:0xd7dce4];
}

- (void)addTagsToCell:(UITableViewCell *)cell withNote:(Note *)note andYCoordinate:(CGFloat)y
{
    CGFloat x = 30;
    NSArray *tags = note.tags;
    
    // only display 3 tags in the home view, every tag will be shown in the detail view
    if([tags count] > 0)
    {
        int max = 3;
        
        if([tags count] < 3)
            max = [tags count];
        
        for(int i = 0; i < max; i++)
        {
            NSString *tag = tags[i];
            
            CGFloat width = [tag length] * 6;
            
            if([tag length] < 8)
                width = [tag length] * 6.5;
            
            UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 35, width, 14)];
            tagLabel.text = tag;
            tagLabel.textColor = [UIColor whiteColor];
            tagLabel.textAlignment = NSTextAlignmentCenter;
            tagLabel.backgroundColor = [Helper getColorFromHex:0x28b678];
            tagLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
            tagLabel.layer.cornerRadius = 2;
            [cell.contentView addSubview:tagLabel];
            
            x = x + width + 5;
        }
    }
}

- (void)setUpMainBackgroundView:(UITableViewCell *)cell withNote:(Note *)note
{
    // main background view
    UIView *mainBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(10, 15, 300, 325)];
    mainBackgroundView.backgroundColor = [Helper getColorFromHex:0xffffff];
    mainBackgroundView.layer.borderWidth = 0.5;
    mainBackgroundView.layer.borderColor = [[Helper getColorFromHex:0xc1c2c2] CGColor];
    mainBackgroundView.layer.cornerRadius = 2;
    [cell.contentView addSubview:mainBackgroundView];
    
    CGFloat yCoordinate = 30;
    
    // Note's Image View
    if(![note.thumbnail isKindOfClass:[NSNull class]])
    {
        PFImageView *noteImageView = [[PFImageView alloc] initWithFrame:CGRectMake(25, yCoordinate, 270, 180)];
        noteImageView.image = [UIImage imageNamed:@"1.jpg"]; // placeholder image
        noteImageView.file = note.thumbnail;
        noteImageView.layer.masksToBounds = YES;
        [noteImageView loadInBackground];
        [cell.contentView addSubview:noteImageView];
        
        yCoordinate += 190;
    }
    
    // Note Title Label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, yCoordinate, 265, 50)];
    titleLabel.text = note.title;
    titleLabel.textColor = [Helper getColorFromHex:0x1d1d1d];
    titleLabel.numberOfLines = 2;
    titleLabel.font = [UIFont fontWithName:@"Kreon-Regular" size:18];
    [titleLabel sizeToFit];
    [cell.contentView addSubview:titleLabel];
    
    // Calculating the y cooridinate of the next view - which changes based on the note's title
    if([note.title length] < 39)
        yCoordinate += 40;
    else
        yCoordinate += 45;
    
    // url
    if(note.sourceUrl)
    {
        UILabel *urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, yCoordinate, 250, 20)];
        urlLabel.text = note.sourceUrl;
        urlLabel.textColor = [Helper getColorFromHex:0x00b3b3];
        urlLabel.font = [UIFont fontWithName:@"Kreon-Regular" size:16];
        [cell.contentView addSubview:urlLabel];
        yCoordinate += 25;
    }
    
    if([note.thumbnail isKindOfClass:[NSNull class]])
    {
        // Note Text Label
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, yCoordinate, 270, 60)];
        textLabel.text = note.text;
        textLabel.textColor = [Helper getColorFromHex:0x545454];
        textLabel.numberOfLines = 10;
        textLabel.font = [Helper getDefaultRegularFont];
        [textLabel sizeToFit];
        [cell.contentView addSubview:textLabel];
        yCoordinate += 190;
    }
        
    // Add a line
    CALayer *line = [CALayer layer];
    line.frame = CGRectMake(25, yCoordinate + 5, 270, 0.5);
    line.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    [cell.contentView.layer addSublayer:line];
    
    // profile image
    UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, yCoordinate + 15, 25, 25)];
    profileImageView.image = [UIImage imageNamed:@"profile.png"];
    
    profileImageView.layer.borderWidth = 0.5;
    profileImageView.layer.borderColor = [[UIColor grayColor] CGColor];
    profileImageView.layer.cornerRadius = 12.5;
    [cell.contentView addSubview:profileImageView];
    
    // username
    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, yCoordinate + 18, 200, 20)];
    usernameLabel.text = note.username;
    usernameLabel.font = [UIFont fontWithName:@"Kreon-Regular" size:14];
    usernameLabel.textColor = [Helper getColorFromHex:0x00b3b3];
    [cell.contentView addSubview:usernameLabel];
   
    // Saves Label
    UILabel *clippedLabel = [[UILabel alloc] initWithFrame:CGRectMake(205, yCoordinate + 18, 80, 20)];
    clippedLabel.textAlignment = NSTextAlignmentRight;
    clippedLabel.font = [UIFont fontWithName:@"Kreon-Regular" size:14];
    clippedLabel.textColor = [Helper getColorFromHex:0x4f5557];
    NSString *numberOfSaves = [NSString stringWithFormat:@"%i", note.numberOfSaves];
    clippedLabel.text = [numberOfSaves stringByAppendingString:@" clips"];
    [cell.contentView addSubview:clippedLabel];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedNote = [[Note alloc] initWithPFObject:[self.objects objectAtIndex:[indexPath row]]];
    [self performSegueWithIdentifier:@"main home view note" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *CellIdentifier = @"note cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    self.selectedNote = [[Note alloc] initWithPFObject:object];
    cell.contentView.backgroundColor = [Helper getColorFromHex:0xd7dce4];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self setUpMainBackgroundView:cell withNote:self.selectedNote];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 340;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"main home view note"])
    {
        NoteDetailVC *noteDetailVC = segue.destinationViewController;
        noteDetailVC.selectedNote = self.selectedNote;
        noteDetailVC.segueType = @"main home view note";
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshList" object:nil];
}

@end

