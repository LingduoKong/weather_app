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

- (void)downloadCities{
    NSString *url = [NSString stringWithFormat:@"https://raw.githubusercontent.com/LingduoKong/mydata/master/weatherData/1280737.json"];
    // deal with space
    [[SharedNetworking sharedSharedNetworking] retrieveRSSFeedForURL:url
                                                             success:^(NSMutableDictionary *dictionary, NSError *error) {
                                                                 if ([_AllCities count] != 0) {
                                                                     [_AllCities removeAllObjects];
                                                                 }
                                                                 
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    _allCityNames = [[NSMutableArray alloc] initWithObjects:@"London",@"New York", @"Berlin", @"Beijing", @"Sydney", nil];
    [self addObejct];
    
    
//    _AllCities= [[NSMutableArray alloc] init];
//    [self downloadCities];
//    NSLog(@"%@", _AllCities);
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
    if (_isFiltered) {
        return [_filteredCityNames count];
    }
    else return [_allCityNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultCell"];
    if (_isFiltered) {
        cell.City.text = [[_filteredCityNames objectAtIndex:indexPath.row]objectForKey:@"name"];

    }
    else {
        cell.City.text = [[_allCityNames objectAtIndex:indexPath.row]objectForKey:@"name"];

    }
    return cell;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length==0) {
        _isFiltered = NO;
    }
    else {
        _isFiltered = YES;
        _filteredCityNames = [[NSMutableArray alloc]init];
        
        for (NSDictionary *cityname in _allCityNames ) {
            NSRange cityNameRange = [[cityname objectForKey:@"name"] rangeOfString: searchText options:NSCaseInsensitiveSearch];
            
            if (cityNameRange.location!=NSNotFound) {
                [_filteredCityNames addObject:cityname];
            }
        }
    }
    
    // reload tableview
    [_CityList reloadData];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showSearchDetail"]) {
        NSString *cityid;
        NSIndexPath *indexPath = [self.CityList indexPathForSelectedRow];
        if (_isFiltered) {
            cityid = [[self.filteredCityNames objectAtIndex:indexPath.row]objectForKey:@"id"];
        }
        else {
            cityid = [[self.allCityNames objectAtIndex:indexPath.row]objectForKey:@"id"];
        }
//        NSDate *object = [self.AllCityNames objectAtIndex:indexPath.row];
        NSLog(@"City ID selected: %@", cityid);
        
        DetailViewController *dvc = (DetailViewController*)segue.destinationViewController;
        [dvc setDetailItem:cityid];
    }
}


- (IBAction)CancelButton:(id)sender {
    [self.delegate update];
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue{
    
}

-(void)addObejct{
    NSMutableDictionary *tempDict;
    _allCityNames = [[NSMutableArray alloc] init];
    
    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"1283240" forKey:@"id"];
    [tempDict setObject:@"Kathmandu" forKey:@"name"];
    [_allCityNames addObject:tempDict];
    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"3632308" forKey:@"id"];
    [tempDict setObject:@"Merida" forKey:@"name"];
    [_allCityNames addObject:tempDict];
    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"1280737" forKey:@"id"];
    [tempDict setObject:@"Lhasa" forKey:@"name"];
    [_allCityNames addObject:tempDict];
    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"745042" forKey:@"id"];
    [tempDict setObject:@"İstanbul" forKey:@"name"];
    [_allCityNames addObject:tempDict];
    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"3496831" forKey:@"id"];
    [tempDict setObject:@"Mao" forKey:@"name"];
    [_allCityNames addObject:tempDict];
    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"523523" forKey:@"id"];
    [tempDict setObject:@"Nalchik" forKey:@"name"];
    [_allCityNames addObject:tempDict];
    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"2267057" forKey:@"id"];
    [tempDict setObject:@"Lisbon" forKey:@"name"];
    [_allCityNames addObject:tempDict];
    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"3082707" forKey:@"id"];
    [tempDict setObject:@"Walbrzych" forKey:@"name"];
    [_allCityNames addObject:tempDict];
    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"3091150" forKey:@"id"];
    [tempDict setObject:@"Naklo nad Notecia" forKey:@"name"];
    [_allCityNames addObject:tempDict];
    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"1784658" forKey:@"id"];
    [tempDict setObject:@"Zhengzhou" forKey:@"name"];
    [_allCityNames addObject:tempDict];
    
    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"2643743" forKey:@"id"];
    [tempDict setObject:@"London" forKey:@"name"];
    [_allCityNames addObject:tempDict];
    
    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"993800" forKey:@"id"];
    [tempDict setObject:@"Johannesburg" forKey:@"name"];
    [_allCityNames addObject:tempDict];
    
    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"524901" forKey:@"id"];
    [tempDict setObject:@"Moscow" forKey:@"name"];
    [_allCityNames addObject:tempDict];
    
    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"1850147" forKey:@"id"];
    [tempDict setObject:@"Tokyo" forKey:@"name"];
    [_allCityNames addObject:tempDict];
    
    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"2147714" forKey:@"id"];
    [tempDict setObject:@"Sydney" forKey:@"name"];
    [_allCityNames addObject:tempDict];
    
    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"1819729" forKey:@"id"];
    [tempDict setObject:@"Hong Kong" forKey:@"name"];
    [_allCityNames addObject:tempDict];

    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"5856195" forKey:@"id"];
    [tempDict setObject:@"Honolulu" forKey:@"name"];
    [_allCityNames addObject:tempDict];

    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"5391959" forKey:@"id"];
    [tempDict setObject:@"San Francisco" forKey:@"name"];
    [_allCityNames addObject:tempDict];

    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"3530597" forKey:@"id"];
    [tempDict setObject:@"Mexico City" forKey:@"name"];
    [_allCityNames addObject:tempDict];

    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"5128638" forKey:@"id"];
    [tempDict setObject:@"New York" forKey:@"name"];
    [_allCityNames addObject:tempDict];

    tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:@"3451190" forKey:@"id"];
    [tempDict setObject:@"Rio de Janeiro" forKey:@"name"];
    [_allCityNames addObject:tempDict];


}
@end
