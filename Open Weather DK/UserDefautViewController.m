/********************************************************************************************
 * @class_name           UserDefautViewController
 * @abstract             A custom tableviewcontroller
 * @description          Shows abstract of all the cities' weather in user defaults added by the user's save operation.
 ********************************************************************************************/

#import "UserDefautViewController.h"
#import "Reachability.h"

@interface UserDefautViewController ()
@property UIViewController* vc;

@end

@implementation UserDefautViewController

/********************************************************************************************
 * @method           isNetworkAvailable
 * @abstract         check whether the network is available now
 * @description      If there isn't network connection, just keep user from using the app.
 ********************************************************************************************/

- (BOOL) isNetworkAvailable {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:@"Network Unavailable" message:@"App doesn't work!\nPlease check network and launch again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [failAlert show];
        self.addButton.enabled = NO;
        self.settingButton.enabled = NO;
        self.mapButton.enabled = NO;
        return NO;
    } else {
        self.addButton.enabled = YES;
        self.settingButton.enabled = YES;
        self.mapButton.enabled = YES;
        return YES;
    }
}

/********************************************************************************************
 * @method           addSplashView
 * @abstract         configure the splash view
 * @description      add a splash when loading data.
 ********************************************************************************************/

-(void)addSplashView {
    
    // add splash view
    self.vc = [[UIViewController alloc] init];
    self.vc.view.backgroundColor = [UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:1];
    
    CGFloat width = self.vc.view.frame.size.width;
    CGFloat height = self.vc.view.frame.size.height;
    
    UILabel *projectName = [[UILabel alloc]initWithFrame:CGRectMake(10, height/5, width-20, height/5)];
    projectName.backgroundColor = [UIColor clearColor];
    projectName.textColor = [UIColor whiteColor];
    projectName.font=[projectName.font fontWithSize:25];
    projectName.text = @"Weawther DK";
    
    UILabel *author = [[UILabel alloc]initWithFrame:CGRectMake(10, height/2, width-20, height/6)];
    author.backgroundColor = [UIColor clearColor];
    author.textColor = [UIColor whiteColor];
    author.numberOfLines = 2;
    author.text = @"Author:\nLingduo Kong & Jiaming Dong";
    
    projectName.clipsToBounds = YES;
    author.clipsToBounds = YES;
    projectName.layer.cornerRadius = 10;
    author.layer.cornerRadius = 10;
    projectName.textAlignment = NSTextAlignmentCenter;
    author.textAlignment = NSTextAlignmentCenter;
    
    CGRect buttonFrame = author.frame;
    buttonFrame.origin.y = author.frame.origin.y + author.frame.size.height*2;
    UIButton *dismissButton = [[UIButton alloc]initWithFrame:buttonFrame];
    dismissButton.backgroundColor = [UIColor clearColor];
    [dismissButton setTitle:@"GO" forState: UIControlStateNormal];
    [dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [dismissButton addTarget:self action: @selector(DismissSplashView) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *splashImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    splashImage.image = [UIImage imageNamed:@"BG10n"];
    [self.vc.view addSubview:splashImage];
    [self.vc.view addSubview:projectName];
    [self.vc.view addSubview:author];
    [self.vc.view addSubview:dismissButton];
    
    [self presentViewController:self.vc animated:NO completion:^{
        
        NSLog(@"Splash screen is showing");
    }];
}

-(void)DismissSplashView{
    [self.vc dismissViewControllerAnimated:YES completion:^{}];
    self.vc = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addSplashView];
    
    if (![self isNetworkAvailable]) {
        [self.vc dismissViewControllerAnimated:YES completion:^{return;}];
        return;
    }
    
    // locationManager initialization
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:1000];
    [self.locationManager requestWhenInUseAuthorization];
    
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
    NSLog(@"[UserDefaultViewController] AllCityIds(got from user defaults): %@", self.AllCityIds);
    

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
        NSLog(@"[UserDefaultViewController] dismiss splash view");
    }
    
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

- (void) viewDidAppear:(BOOL)animated {
    // initial launch
    NSString* firstLaunchDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"first_launch_date"];
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


#pragma mark userpreference

/********************************************************************************************
 * @method           userPreferenceDidChange
 * @abstract         Night Mode Server Function
 * @description      Adjust the tableview's background according to the user preference in settings. Called when settings are changed.
 ********************************************************************************************/

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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
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
    
    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?id=%@&mode=json", self.AllCityIds[indexPath.row]];
    NSLog(@"[UserDefaultViewController] get city with id %@ from url: %@", self.AllCityIds[indexPath.row], url);
    
    // retrieve the needed data by id
    [[SharedNetworking sharedSharedNetworking] retrieveRSSFeedForURL:url
                                                             success:^(NSMutableDictionary *dictionary, NSError *error) {
                                                                 
                                                                NSLog(@"[UserDefaultViewController] data of city with id %@: %@", self.AllCityIds[indexPath.row], dictionary);
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
                                                                 
                                                                 NSString *imageName = [NSString stringWithFormat:@"%@.png",[[dictionary[@"weather"] objectAtIndex:0] objectForKey:@"icon"]];
                                                                 
                                                                 cell.weatherType.image = [UIImage imageNamed:imageName];
                                                                 // Use dispatch_async to update the table on the main thread

                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     
                                                                     if (self.vc!=nil && indexPath.row == [self.AllCityIds count]-1) {
                                                                         [self.vc dismissViewControllerAnimated:YES completion:^{}];
                                                                         self.vc=nil;
                                                                         NSLog(@"[UserDefaultViewController] dismiss splash view");
                                                                     }
                                                                 });
                                                             }
                                                             failure:^{
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     NSLog(@"[UserDefaultViewController] Problem with Data");
                                                                     if (self.vc!=nil) {
                                                                         NSLog(@"[UserDefaultViewController] Splash view will keep");
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
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }

}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        //NSDate *object = [self.AllCityNames objectAtIndex:indexPath.row];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NSString *cityid = [self.AllCityIds objectAtIndex:indexPath.row];
        NSLog(@"[UserDefaultViewController] City ID selected(press cell): %@", cityid);
        
        DetailViewController *dvc = (DetailViewController*)segue.destinationViewController;
        [dvc setDetailItem:cityid];        
        dvc.delegate = self;
    }
    
    else if ([[segue identifier] isEqualToString:@"showSearchView"]) {
        SearchViewController *svc = (SearchViewController*)segue.destinationViewController;
        svc.delegate = self;
        
        NSLog(@"[UserDefaultViewController] Segue to SearchViewController");
    }
    
    // to the map view controller
    else if ([[segue identifier] isEqualToString:@"showMapView"]) {
        mapViewController *mvc = (mapViewController*)segue.destinationViewController;
        
        if ([self.AllCityIds count]) {
            [mvc pass:self.AllCityIds];
        }
        [mvc setDelegate:self];
        
        NSLog(@"[UserDefaultViewController] Segue to mapViewController");
    }
}

#pragma mark unwind
- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    
}

///-----------------------------------------------------------------------------
#pragma mark - Custom Delegate Methods
///-----------------------------------------------------------------------------

/********************************************************************************************
 * @method           update
 * @abstract         Delegate Function called by other viewcontroller
 * @description      When the user save or unsave a city in the detail view controller, this fucntion will be called using delegate to update the tableview in this class accordingly.
 ********************************************************************************************/

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
    NSLog(@"[UserDefaultViewController] update called");
    
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

/********************************************************************************************
 * @method           didUpdateLocations
 * @abstract         called when current location is changed
 * @description      It is used to update the current city of the user.
 ********************************************************************************************/

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"[UserDefaultViewController] didUpdateLocations called");
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
                
                NSLog(@"[UserDefaultViewController] cityName: %@, countryCode: %@", [test[@"City"] description], [test[@"CountryCode"] description]);
                
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
                        NSLog(@"[UserDefaultViewController] Problem with Updating Locations.");
                     });
                 }];
            }
            else if (error == nil && [placemarks count] == 0)
            {
                NSLog(@"[UserDefaultViewController] No results were returned.");
            }
            else if (error != nil)
            {
                NSLog(@"[UserDefaultViewController] An error occurred = %@", error);
            }
        }
    }];
    
    [_locationManager stopUpdatingLocation];
}

/********************************************************************************************
 * @method           didFailWithError
 * @abstract         called if failure happens
 * @description      This function will tell which kind of error happens when the application tries to update the current location of the user.
 ********************************************************************************************/

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([error code]==kCLErrorDenied) {
        NSLog(@"[UserDefaultViewController] Access being denied");
    }
    if ([error code]==kCLErrorLocationUnknown) {
        NSLog(@"[UserDefaultViewController] Unavailable to access");
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
        
    } else if (status == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location services not authorized"
                                                        message:@"This app needs you to authorize locations services to work."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        NSLog(@"[UserDefaultViewController] Wrong location status");
    }
}

@end
