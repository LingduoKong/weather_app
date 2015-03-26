/********************************************************************************************
 * @class_name           SearchViewcontroller
 * @abstract             A custom tableviewcontroller with a search bar.
 * @description          In this viewcontroller you can input the city you want in the search bar
 and the table view will return the result(s). Currently we only support 22 cities sence the API sucks.
 ********************************************************************************************/

#import "SearchViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

/********************************************************************************************
 * @method           downloadCities
 * @abstract         download all the cities supported
 * @description      download all the cities supported
 ********************************************************************************************/

- (void)downloadCities : (NSString*)searchText {
    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/find?q=%@&type=like&mode=json", searchText];
    
    NSLog(@"[SearchViewController] download all the cities for url: %@", url);
    
    // deal with space
    url = [url stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    [[SharedNetworking sharedSharedNetworking] retrieveRSSFeedForURL:url
                                                             success:^(NSMutableDictionary *dictionary, NSError *error) {
                                                                 if ([_AllCities count] != 0) {
                                                                     [_AllCities removeAllObjects];
                                                                 }
                                         
                                                                 for (NSMutableDictionary* cityDict in dictionary[@"list"]) {
                                                                     [_AllCities addObject:cityDict];
                                                                 }
                                                                 
                                                                 NSLog(@"[SearchViewController] _AllCities: %@", _AllCities);
                                                                 // Use dispatch_async to update the table on the main thread
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     [_CityList reloadData];

                                                                 });
                                                             }
                                                             failure:^{
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     NSLog(@"[SearchViewController] Problem with Data");
                                                                 });
                                                             }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    if (searchText.length<=3) {
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
        
        DetailViewController *dvc = (DetailViewController*)segue.destinationViewController;
        [dvc setDetailItem:cityid];
        
        NSLog(@"[SearchViewController] Segue to DetailViewController passing id %@", cityid);
    } 
}


- (IBAction)CancelButton:(id)sender {
    [self.delegate update];
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue{
    
}
@end
