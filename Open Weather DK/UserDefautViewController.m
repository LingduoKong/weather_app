//
//  UserDefautViewController.m
//  Open Weather DK
//
//  Created by Lingduo Kong on 3/1/15.
//  Copyright (c) 2015 Lingduo Kong. All rights reserved.
//

#import "UserDefautViewController.h"

@interface UserDefautViewController ()
@property UIViewController* vc;

@end

@implementation UserDefautViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // add splash view
    self.vc = [[UIViewController alloc] init];
    self.vc.view.backgroundColor = [UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:1];
    
    //    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    //        UIImageView *v = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Chicago.jpg"]];
    //        NSLog(@"The Launch Image: %@",v);
    //        [self.vc.view addSubview:v];
    //    }
    
    CGFloat width = self.vc.view.frame.size.width;
    CGFloat height = self.vc.view.frame.size.height;
    
    UILabel *projectName = [[UILabel alloc]initWithFrame:CGRectMake(10, height/5, width-20, height/5)];
    projectName.backgroundColor = [UIColor yellowColor];
    projectName.font=[projectName.font fontWithSize:25];
    projectName.text = @"Weawther DK";
    
    UILabel *author = [[UILabel alloc]initWithFrame:CGRectMake(10, height/2, width-20, height/6)];
    author.backgroundColor = [UIColor yellowColor];
    author.numberOfLines = 2;
    author.text = @"Author:\nLingduo Kong & Jiaming Dong";
    
    projectName.clipsToBounds = YES;
    author.clipsToBounds = YES;
    projectName.layer.cornerRadius = 10;
    author.layer.cornerRadius = 10;
    
    projectName.textAlignment = NSTextAlignmentCenter;
    author.textAlignment = NSTextAlignmentCenter;
    
    [self.vc.view addSubview:projectName];
    [self.vc.view addSubview:author];

    [self presentViewController:self.vc animated:NO completion:^{
        
        NSLog(@"Splash screen is showing");
    }];
        
    // locationManager initialization
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:1000];
    
    [self.locationManager requestWhenInUseAuthorization];
    
    //[self.locationManager startUpdatingLocation];
    
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
    

    // refresh date
    UIRefreshControl *refreshMe = [[UIRefreshControl alloc] init];
    refreshMe.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull Me"];
    [refreshMe addTarget:self action:@selector(update)
        forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshMe;
    self.refreshControl.tintColor = [UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:1];
    
    if([self.AllCityIds count]==0){
        [self.vc dismissViewControllerAnimated:YES completion:^{}];
        self.vc=nil;
        NSLog(@"dismiss splash view");
    }
//    [self.vc dismissViewControllerAnimated:YES completion:^{}];
    
    [self addAllCities];
    
    // deal with settings
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userPreferenceDidChange) name:NSUserDefaultsDidChangeNotification object:nil];
    
    // initial launch
    NSString* firstLaunchDate = [defaults objectForKey:@"first_launch_date"];
    NSDate* date = [NSDate date];
    
    if ([firstLaunchDate isEqualToString:@"Application Terminated"]) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
        
        [[NSUserDefaults standardUserDefaults] setObject:[dateFormatter stringFromDate:date] forKey:@"first_launch_date"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (void) viewDidDisappear:(BOOL)animated {
    // reset initial launch
    NSString* firstLaunchDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"first_launch_date"];
    
    if (![firstLaunchDate isEqualToString:@"Application Terminated"]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:@"Application Terminated" forKey:@"first_launch_date"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

// deal with changes of user preference in settings
- (void)userPreferenceDidChange {
    // night reading mode
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* mode = [defaults objectForKey:@"reading_mode_preference"];
    if ([mode integerValue]) {
        // night mode
        self.tableView.backgroundColor = [UIColor blackColor];
    }
    else {
        // day mode
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // night reading mode
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* mode = [defaults objectForKey:@"reading_mode_preference"];
    if ([mode integerValue]) {
        // night mode
        [cell setBackgroundColor:[UIColor blackColor]];
    }
    else {
        // day mode
        [cell setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:248.0/255.0 blue:255.0/255.0 alpha:1]];
    }
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
    
    // night reading mode
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* mode = [defaults objectForKey:@"reading_mode_preference"];
    if ([mode integerValue]) {
        // night mode
        cell.cityName.textColor = [UIColor whiteColor];
    }
    else {
        // day mode
        cell.cityName.textColor = [UIColor blackColor];
    }
    
//    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?id=%@&mode=json", self.AllCityIds[indexPath.row]];
    
    NSString *url = [NSString stringWithFormat:@"https://raw.githubusercontent.com/LingduoKong/mydata/master/weatherData/%@.json", self.AllCityIds[indexPath.row]];
    
    // retrieve the needed data by id
    [[SharedNetworking sharedSharedNetworking] retrieveRSSFeedForURL:url
                                                             success:^(NSMutableDictionary *dictionary, NSError *error) {
                                                                 
                                                                 NSLog(@"%@", dictionary);
                                                                 // set map sign
                                                                 if ([self.AllCityIds[indexPath.row] isEqual:self.currentCityId]) {
                                                                     cell.mapSign.hidden = NO;
                                                                 }
                                                                 else {
                                                                     if (cell.mapSign.hidden == NO) {
                                                                         cell.mapSign.hidden = YES;
                                                                     }
                                                                 }
                                                                 
                                                                 cell.cityName.text = dictionary[@"city"][@"name"];
                                                                 
                                                                 NSString* tempC = [[NSString stringWithFormat:@"%@", dictionary[@"main"][@"temp"]] KtoC];

                                                                 cell.temperature.text = [NSString stringWithFormat:@"%@°C", tempC];
                                                                 
                                                                 NSString *imageName = [NSString stringWithFormat:@"%@.png", [dictionary[@"weather"]objectAtIndex:0][@"icon"] ];
                                                                 
                                                                 cell.weatherType.image = [UIImage imageNamed:imageName];
                                                                 // Use dispatch_async to update the table on the main thread

                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     
                                                                     if (self.vc!=nil && indexPath.row == [self.AllCityIds count]-1) {
                                                                         [self.vc dismissViewControllerAnimated:5.0 completion:^{}];
                                                                         self.vc=nil;
                                                                         NSLog(@"dismiss splash view");
                                                                     }
                                                                 });
                                                             }
                                                             failure:^{
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     NSLog(@"Problem with Data");
                                                                     if (self.vc!=nil) {
                                                                         NSLog(@"Splash view will keep");
                                                                     }
                                                                 });
                                                             }];
    
    return cell;
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
    
    // to the map view controller
    else if ([[segue identifier] isEqualToString:@"showMapView"]) {
        mapViewController *mvc = (mapViewController*)segue.destinationViewController;
        
        if ([self.AllCityIds count]) {
            [mvc pass:self.AllCityIds];
        }
        [mvc setDelegate:self];
    }
}

#pragma mark unwind
- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    
}

///-----------------------------------------------------------------------------
#pragma mark - Custom Delegate Methods
///-----------------------------------------------------------------------------

- (void) update {
    
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
        [self.locationManager startUpdatingLocation];
    });
    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
    }
}

///-----------------------------------------------------------------------------
#pragma mark - Location Manager Delegate Methods
///-----------------------------------------------------------------------------
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"didUpdateLocations called");
    [self.locationManager startUpdatingLocation];
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
                //NSString* currentCountryCode = [test[@"CountryCode"] description];
                
                for (NSDictionary *cityname in _allCityNames ) {
                    if ([[cityname objectForKey:@"name"] isEqualToString:currentCityName]) {
                        self.currentCityId = [cityname objectForKey:@"id"];
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
                            [newArr insertObject:self.currentCityId atIndex:0];
                        }
                        
                        [defaults setObject:newArr forKey:@"userCities"];
                        self.AllCityIds = [[NSMutableArray alloc] initWithArray:newArr];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                        
                        break;
                    }
                }
                
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
    
    [_locationManager stopUpdatingLocation];
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

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways) {
        
        // Configure location manager
        [self.locationManager setDistanceFilter:kCLHeadingFilterNone];//]500]; // meters
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager setHeadingFilter:kCLDistanceFilterNone];
        self.locationManager.activityType = CLActivityTypeFitness;
        
        // Start the location updating
        [self.locationManager startUpdatingLocation];
        
        // Start beacon monitoring
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc]
                                                                                initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]
                                                                    identifier:@"Estimotes"];
        [manager startRangingBeaconsInRegion:region];
        
        // Start region monitoring for Rio
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(-22.903,-43.2095);
        CLCircularRegion *bregion = [[CLCircularRegion alloc] initWithCenter:coordinate
                                                                      radius:100
                                                                  identifier:@"Rio"];
        region.notifyOnEntry = YES;
        region.notifyOnExit = YES;
        [self.locationManager startMonitoringForRegion:bregion];
        
        
        // Show map
        //self.mapView.showsUserLocation = YES;
        //self.mapView.showsPointsOfInterest = YES;
        
    } else if (status == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location services not authorized"
                                                        message:@"This app needs you to authorize locations services to work."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        NSLog(@"Wrong location status");
    }
}

-(void)addAllCities{
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
