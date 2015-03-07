//
//  SearchViewController.m
//  Open Weather D.K.
//
//  Created by Lingduo Kong on 2/27/15.
//  Copyright (c) 2015 The University of Chicago, Department of Computer Science. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)downloadCities : (NSString*)searchText {
    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/find?q=%@&type=like&mode=json", searchText];
    // deal with space
    url = [url stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    [[SharedNetworking sharedSharedNetworking] retrieveRSSFeedForURL:url
                                                             success:^(NSMutableDictionary *dictionary, NSError *error) {
                                                                 if ([_AllCities count] != 0) {
                                                                     [_AllCities removeAllObjects];
                                                                 }
                                                                 
                                                                 //_AllCities = dictionary[@"list"];
                                                                 
                                                                 for (NSMutableDictionary* cityDict in dictionary[@"list"]) {
                                                                     [_AllCities addObject:cityDict];
                                                                 }
                                                                 
                                                                 //NSLog(@"_AllCities: %@", _AllCities);
                                                                 // Use dispatch_async to update the table on the main thread
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     [_CityList reloadData];
                                                                     //splash disappear
                                                                     //[self.delegate dismissSplashView:self sendObject:true];
                                                                 });
                                                             }
                                                             failure:^{
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     //NSLog(@"Problem with Data");
                                                                 });
                                                             }];
    // night reading mode
    /*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* mode = [defaults objectForKey:@"reading_mode_preference"];
    if ([mode integerValue]) {
        // night mode
        self.tableView.backgroundColor = [UIColor blackColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
        self.refreshControl.tintColor = [UIColor whiteColor];
    }
    else {
        // day mode
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
        self.refreshControl.tintColor = [UIColor redColor];
    }*/
    
    //if the call was done from UIRefreshControl, stop the spinner
    //if (self.refreshControl.refreshing) {
    //    [self.refreshControl endRefreshing];
    //}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initial cities
    //NSString *myFile = [[NSBundle mainBundle] pathForResource:@"citylist" ofType:@"json"];
    //_AllCities = [[NSMutableArray alloc] initWithContentsOfFile:myFile];
    //NSLog(@"%@", _AllCities);
    
    //_AllCityNames = [[NSMutableArray alloc] initWithObjects:@"London",@"New York", @"Berlin", @"Beijing", @"Sydney", nil];
    //[self downloadCities];
    
    _AllCities= [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _AllCities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultCell"];
    cell.City.text = [[_AllCities objectAtIndex:indexPath.row] objectForKey:@"name"];

    return cell;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length==0) {
        _isFiltered = NO;
    }
    else {
        _isFiltered = YES;
        [self downloadCities:searchText];
    }
    
    // reload tableview
    [_CityList reloadData];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showSearchDetail"]) {
        NSIndexPath *indexPath = [self.CityList indexPathForSelectedRow];
        //NSDate *object = [self.AllCityNames objectAtIndex:indexPath.row];
        NSString *cityid = [[self.AllCities objectAtIndex:indexPath.row] objectForKey:@"id"];
        NSLog(@"City ID selected: %@", cityid);
        
//        UINavigationController *nvc = (UINavigationController*)segue.destinationViewController;
//        DetailViewController *dvc = (DetailViewController*)nvc.topViewController;
//        [dvc setDetailItem:cityid];
//        dvc.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//        dvc.navigationItem.leftItemsSupplementBackButton = YES;
        
//        UINavigationController *nvc = (UINavigationController*)segue.destinationViewController;
        
        DetailViewController *dvc = (DetailViewController*)segue.destinationViewController;
        [dvc setDetailItem:cityid];
        
        
//        dvc.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//        dvc.navigationItem.leftItemsSupplementBackButton = YES;
    } 
}


- (IBAction)CancelButton:(id)sender {
    [self.delegate update];
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue{
    
}
@end
