//
//  UserDefautViewController.m
//  Open Weather DK
//
//  Created by Lingduo Kong on 3/1/15.
//  Copyright (c) 2015 Lingduo Kong. All rights reserved.
//

#import "UserDefautViewController.h"

@interface UserDefautViewController ()

@end

@implementation UserDefautViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    // locationManager initialization
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:1000];
    
    [self.locationManager requestAlwaysAuthorization];
    
    [self.locationManager startUpdatingLocation];
    
    
    // load user defaults data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *cityIdArray = (NSArray*)[defaults objectForKey:@"userCities"];
    NSMutableArray *newArr = nil;
    
    if (cityIdArray == nil) {
        newArr = [[NSMutableArray alloc] init];
    }
    else {
        newArr = [[NSMutableArray alloc] initWithArray:cityIdArray];
    }
    
    cityIdArray = (NSArray*)[defaults objectForKey:@"userCities"];
    
    self.AllCityIds = [[NSMutableArray alloc] initWithArray:cityIdArray];
    NSLog(@"AllCityIds: %@", self.AllCityIds);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.AllCityIds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell" forIndexPath:indexPath];
    
    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?id=%@&mode=json", self.AllCityIds[indexPath.row]];
    
    // retrieve the needed data by id
    [[SharedNetworking sharedSharedNetworking] retrieveRSSFeedForURL:url
                                                             success:^(NSMutableDictionary *dictionary, NSError *error) {
                                                                 // set map sign
                                                                 if ([self.AllCityIds[indexPath.row] isEqual:self.currentCityId]) {
                                                                     cell.mapSign.hidden = NO;
                                                                 }
                                                                 else {
                                                                     if (cell.mapSign.hidden == NO) {
                                                                         cell.mapSign.hidden = YES;
                                                                     }
                                                                 }
                                                                 
                                                                 cell.cityName.text = dictionary[@"name"];
                                                                 
                                                                 NSString* tempC = [[NSString stringWithFormat:@"%@", dictionary[@"main"][@"temp"]] KtoC];

                                                                 cell.temperature.text = [NSString stringWithFormat:@"%@°C", tempC];
                                                                 
                                                                 NSString *URL = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png",[[dictionary[@"weather"] objectAtIndex:0] objectForKey:@"icon"]];
                                                                 
                                                                 NSData *imagedata = [NSData dataWithContentsOfURL:
                                                                                      [NSURL URLWithString: URL]];
                                                                 
                                                                 cell.weatherType.image = [UIImage imageWithData:imagedata];
                                                                 // Use dispatch_async to update the table on the main thread
                                                                 
                                                                 // if current city, add a signal
                                                                 //[cell addsubview:]
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     //[_CityList reloadData];
                                                                     //[self.tableView reloadData];
                                                                     //splash disappear
                                                                     //[self.delegate dismissSplashView:self sendObject:true];
                                                                 });
                                                             }
                                                             failure:^{
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     //NSLog(@"Problem with Data");
                                                                 });
                                                             }];
    
    return cell;
}

- (NSString*) KtoC : (NSString*) K {
    float fK = [K floatValue];
    fK -= 273.15;
    
    NSString *C;
    if (fK >= 0) {
        C = [NSString stringWithFormat:@"%d", (int)(fK + 0.5)];
    }
    else {
        C = [NSString stringWithFormat:@"%d", (int)(fK - 0.5)];
    }
    return C;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // remove from NSUserDefault
        [self.AllCityIds removeObjectAtIndex:indexPath.row];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        [defaults setObject:self.AllCityIds forKey:@"userCities"];
        [defaults synchronize];
        
        NSLog(@"AllCityIds: %@", self.AllCityIds);
        
        // remove from table
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }

}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        //NSDate *object = [self.AllCityNames objectAtIndex:indexPath.row];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NSString *cityid = [self.AllCityIds objectAtIndex:indexPath.row];
        NSLog(@"City ID selected: %@", cityid);
               
        DetailViewController *dvc = (DetailViewController*)segue.destinationViewController;
        [dvc setDetailItem:cityid];
        
        dvc.delegate = self;
    }
    
    else if ([[segue identifier] isEqualToString:@"showSearchView"]) {
        SearchViewController *svc = (SearchViewController*)segue.destinationViewController;
        svc.delegate = self;
    }
}

#pragma mark unwind
- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    
}

///-----------------------------------------------------------------------------
#pragma mark - Custom Delegate Methods
///-----------------------------------------------------------------------------

- (void) update {
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *cityIdArray = (NSArray*)[defaults objectForKey:@"userCities"];
    NSMutableArray *newArr = nil;
    
    if (cityIdArray == nil) {
        newArr = [[NSMutableArray alloc] init];
    }
    else {
        newArr = [[NSMutableArray alloc] initWithArray:cityIdArray];
    }
    
    cityIdArray = (NSArray*)[defaults objectForKey:@"userCities"];
    
    self.AllCityIds = [[NSMutableArray alloc] initWithArray:cityIdArray];
    NSLog(@"update called");
    
    // update the tableview
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

///-----------------------------------------------------------------------------
#pragma mark - Location Manager Delegate Methods
///-----------------------------------------------------------------------------
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"didUpdateLocations called");
    // get current location
    CLLocation *cloc = [locations lastObject];
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:cloc completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error)
        {
            if (placemarks.count > 0) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                NSDictionary *test = [placemark addressDictionary];
                
                NSLog(@"cityName: %@, countryCode: %@", [test[@"City"] description], [test[@"CountryCode"] description]);
                
                NSString* currentCityName = [test[@"City"] description];
                NSString* currentCountryCode = [test[@"CountryCode"] description];
                
                NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@,%@&mode=json", currentCityName, currentCountryCode];
                
                // deal with space
                url = [url stringByReplacingOccurrencesOfString:@" " withString:@"+"];
                
                [[SharedNetworking sharedSharedNetworking] retrieveRSSFeedForURL:url
                 success:^(NSMutableDictionary *dictionary, NSError *error) {
                     // get new current city id
                     self.currentCityId = dictionary[@"id"];
                     NSLog(@"currentCityId: %@", self.currentCityId);
                     
                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                     NSArray *cityIdArray = (NSArray*)[defaults objectForKey:@"userCities"];
                     NSMutableArray *newArr = nil;
                     
                     if (!cityIdArray) {
                         newArr = [[NSMutableArray alloc] init];
                     }
                     else {
                         newArr = [[NSMutableArray alloc] initWithArray:cityIdArray];
                     }
                     
                     // add current city id to userCities as a default.
                     if (![newArr containsObject:self.currentCityId]) {
                         //[newArr addObject:self.currentCityId];
                         [newArr insertObject:self.currentCityId atIndex:0];
                     }
                     
                     [defaults setObject:newArr forKey:@"userCities"];
                     self.AllCityIds = [[NSMutableArray alloc] initWithArray:newArr];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.tableView reloadData];
                     });
                 }
                 failure:^{
                     self.currentCityId = @"null";
        
                     dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"Problem with Updating Locations.");
                     });
                 }];
            }
            else if (error == nil && [placemarks count] == 0)
            {
                NSLog(@"No results were returned.");
            }
            else if (error != nil)
            {
                NSLog(@"An error occurred = %@", error);
            }
        }
    }];
    
    //[_locationManager stopUpdatingLocation];
}

/**
 * call it if failure happens
 */
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([error code]==kCLErrorDenied) {
        NSLog(@"Access being denied");
    }
    if ([error code]==kCLErrorLocationUnknown) {
        NSLog(@"Unavailable to access");
    }
}

@end
