//
//  DiscoverTVC.h
//  Xplore
//
//  Created by Bardan Gauchan on 7/1/13.
//  Copyright (c) 2013 Bardan Gauchan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Note.h"

@interface DiscoverTVC : PFQueryTableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) Note *selectedNote;

@end
