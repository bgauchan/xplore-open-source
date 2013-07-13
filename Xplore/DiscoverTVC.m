//
//  DiscoverTVC.m
//  Xplore
//
//  Created by Bardan Gauchan on 7/1/13.
//  Copyright (c) 2013 Bardan Gauchan. All rights reserved.
//

#import "DiscoverTVC.h"
#import "NoteDetailVC.h"

@interface DiscoverTVC ()

@end

@implementation DiscoverTVC


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
        self.objectsPerPage = 100;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchResults = [NSMutableArray arrayWithCapacity:[self.objects count]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *CellIdentifier = @"tag cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        if([self.searchResults count] > 0)
            object = [self.searchResults objectAtIndex:indexPath.row];
    }
    else
    {
        object = [self.objects objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = [object valueForKey:@"title"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.tableView)
        return self.objects.count;
    else
        return self.searchResults.count;
}

#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.searchResults removeAllObjects];
    
    PFQuery *query1 = [PFQuery queryWithClassName:self.parseClassName];
    [query1 whereKey:@"lowercaseTitle" containsString:searchText];
    
    PFQuery *query2 = [PFQuery queryWithClassName:self.parseClassName];
    [query2 whereKey:@"tags" containedIn:[NSArray arrayWithObjects:searchText, nil]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    [query includeKey:@"user"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.searchResults = [objects mutableCopy];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self filterContentForSearchText:[searchBar.text lowercaseString] scope:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        PFObject *noteObject = [self.searchResults objectAtIndex:[indexPath row]];
        self.selectedNote = [[Note alloc] initWithPFObject:noteObject];
    }
    else
        self.selectedNote = [[Note alloc] initWithPFObject:[self.objects objectAtIndex:[indexPath row]]];

    [self performSegueWithIdentifier:@"main home view note" sender:self];
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

@end
