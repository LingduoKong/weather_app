/********************************************************************************************
 *                                   Special Explanation
 *    Recently an accident happens with the weather API we've been using because of unknown
 *    reasons, so we have to use fake data instead. We extend our apology for the inconvenience
 *    and hope you could understand. All Data showed is unreliable.
 ********************************************************************************************/

/********************************************************************************************
 * @class_name           mapViewController
 * @abstract             A custom viewcontroller to show the mapview
 * @description          The main part of this view controller is map view which have annotations
 of all the users' cities, including city name, weather type and min/max temperature. User can
 segue into DetailViewController through an annotation on the map. In order to facilitate the
 search on the map, user can popover the book mark on the bottom left which display a list of
 all the users' cities. Once the user chooses one city in the list, the map camera will focus on the
 annotation of the city on the map view.
 ********************************************************************************************/

@import CoreLocation;
#import "mapViewController.h"
#import "SharedNetworking.h"
#import "NSString+KtoC.h"

@interface mapViewController ()

@end

@implementation mapViewController

# define METERS_PER_MILE 1609.344

/********************************************************************************************
* @method           cityIdsFromUDVC
* @abstract         a helper function to pass the city ids.
* @description      pass the array of city ids from UserDefaultViewController to self.AllCityIds.
********************************************************************************************/

- (void)pass:(NSMutableArray*)cityIdsFromUDVC {
    if (!self.AllCityIds) {
        self.AllCityIds = [[NSMutableArray alloc] initWithArray:cityIdsFromUDVC];
        NSLog(@"self.AllCityIds: %@", self.AllCityIds);
        // Update the view
        [self configureView];
    }
}

/********************************************************************************************
 * @method           configureView
 * @abstract         configure the view
 * @description      download the needed data of each city by its id and create a custom annotation for it.
 ********************************************************************************************/

- (void)configureView {
    if (!self.AllCityIds) {
        return;
    }
    for (NSString* cityId in self.AllCityIds) {
        NSString *url = [NSString stringWithFormat:@"https://raw.githubusercontent.com/LingduoKong/mydata/master/weatherData/%@.json",cityId];
        NSLog(@"[mapViewController] get data of city %@ from url: %@", cityId, url);
        
        [[SharedNetworking sharedSharedNetworking] retrieveRSSFeedForURL:url
                                                                 success:^(NSMutableDictionary *dictionary, NSError *error) {
                                                                     NSLog(@"[mapViewController] data of city %@: %@", cityId, dictionary);
                                                                     
                                                                     NSDictionary* coords = [[dictionary objectForKey:@"city"]objectForKey:@"coord"];
                                                                     CLLocationCoordinate2D centerCoord;
                                                                     centerCoord.latitude = [coords[@"lat"] doubleValue];
                                                                     centerCoord.longitude = [coords[@"lon"] doubleValue];
                                                                     
                                                                     //get the min and max temperature of this city
                                                                     NSString* temp_min = [NSString stringWithFormat:@"%@", dictionary[@"main"][@"temp_min"]];
                                                                     NSString* temp_max = [NSString stringWithFormat:@"%@", dictionary[@"main"][@"temp_max"]];
                                                                     
                                                                     NSString* temp_m = [[NSString alloc] initWithFormat:@"%@°C/%@°C", [temp_min KtoC], [temp_max KtoC]];
                                                                     
                                                                     WeatherAnnotation *annotation = [[WeatherAnnotation alloc] initWithCityName:dictionary[@"city"][@"name"] temperature:temp_m coordinate:centerCoord cityId:cityId];
                                                                     
                                                                     // store city id into the new annotation
                                                                     //annotation.cityId = [[NSString alloc] initWithString:cityId];
                                                                     [self.mapView addAnnotation:annotation];
                                                                     
                                                                     // Use dispatch_async to update the table on the main thread
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         //[_CityList reloadData];
                                                                         //splash disappear
                                                                         //[self.delegate dismissSplashView:self sendObject:true];
                                                                     });
                                                                 }
                                                                 failure:^{
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         NSLog(@"[mapViewController] Problem with Data");
                                                                     });
                                                                 }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.mapView setMapType:MKMapTypeHybrid];
    [self.view addSubview:self.mapView];
    
    [self.mapView setDelegate:self];
    
    // initialize map camera
    self.mapCam = [[MKMapCamera alloc] init];
    
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set the initial position of the map
    //CLLocationCoordinate2D zoomLocation;
    //zoomLocation.latitude = 28.53806;
    //zoomLocation.longitude = -81.37944;
    
    MKCoordinateRegion viewRegion =
    MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.location.coordinate, 1000*METERS_PER_MILE, 1000*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    //[self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///-----------------------------------------------------------------------------
#pragma mark -- mapView delegate
///-----------------------------------------------------------------------------

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *identifier = @"WeatherAnnotation";
    
    if ([annotation isKindOfClass:[WeatherAnnotation class]]) {
        
        WeatherAnnotation *location = (WeatherAnnotation *) annotation;
        MKAnnotationView *annotationView = (MKAnnotationView *) [theMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:location reuseIdentifier:identifier];
        } else {
            annotationView.annotation = location;
        }
        
        // Set the pin properties
        //annotationView.animatesDrop = YES;
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        //.pinColor = MKPinAnnotationColorPurple;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        // Show Weather Type Icon
        if (!location.cityId) {
            // Since we are reusing cells we need to nil out the inmage
            annotationView.leftCalloutAccessoryView = nil;
            return annotationView;
        }
        NSString *url = [NSString stringWithFormat:@"https://raw.githubusercontent.com/LingduoKong/mydata/master/weatherData/%@.json", location.cityId];
        
        NSLog(@"[mapViewController] get data of city %@ from url: %@", location.cityId, url);
        
        [[SharedNetworking sharedSharedNetworking] retrieveRSSFeedForURL:url
                                                                 success:^(NSMutableDictionary *dictionary, NSError *error) {
                                                                     NSLog(@"[mapViewController] data of city %@: %@", location.cityId, dictionary);
                                                                     
                                                                     NSString *imageName = [NSString stringWithFormat:@"%@.png",[[dictionary[@"weather"] objectAtIndex:0] objectForKey:@"icon"]];
                                                                     
                                                                     annotationView.image = [UIImage imageNamed:imageName];
                                                                     
                                                                     annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:imageName]];
                                                                     // Use dispatch_async to update the table on the main thread
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                     
                                                                     });
                                                                 }
                                                                 failure:^{
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         NSLog(@"[mapViewController] Problem with Data");
                                                                     });
                                                                 }];
        return annotationView;
    }
    
    return nil;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    WeatherAnnotation* location = (WeatherAnnotation*)view.annotation;
    
    DetailViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    [dvc setDetailItem:location.cityId];
    [dvc setDelegate:self.delegate];
    // Create the navigation controller and present it.
    
    [self presentViewController:dvc animated:YES completion: nil];
}

// sample of current city
- (MKOverlayView*)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]]) {
        
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.1];
        circleView.strokeColor = [[UIColor cyanColor] colorWithAlphaComponent:0.7];
        circleView.lineWidth = 3.0;
        return circleView;
    }else
    {
        return  nil;
    }
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue{
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showBookMark"]) {
        
        BookMarkTableViewController *bvc = (BookMarkTableViewController*)segue.destinationViewController;
        bvc.delegate = self;
        
        UIPopoverPresentationController *popPC = bvc.popoverPresentationController;
        popPC.delegate = self;
        
        NSLog(@"[mapViewController] Segue to BookMarkTableViewController");
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

# pragma Bookmark View Delegate Function

/********************************************************************************************
 * @method           handleCityIdFromBookMark
 * @abstract         called by the delegate of the BookMarkViewController
 * @description      set the camera according to the city id passed from the bookmark. Finally
 the annotation of this city presents in the center of the screen so user can check and access
 its weather details.
 ********************************************************************************************/

-(void)handleCityIdFromBookMark:(NSString *)cityId {
    if (!cityId) {
        return;
    }
    NSLog(@"[mapViewController] city id from Bookmark: %@", cityId);
   
    NSString *url = [NSString stringWithFormat:@"https://raw.githubusercontent.com/LingduoKong/mydata/master/weatherData/%@.json", cityId];
    
    NSLog(@"[mapViewController] get data of city %@ from url: %@", cityId, url);
    
    NSData *jsonData = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString: url]];
    
    NSDictionary *jsonObject=[NSJSONSerialization
                              JSONObjectWithData:jsonData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
    
    NSLog(@"[mapViewController] data of city %@: %@", cityId, jsonObject);
    
    NSDictionary *coords = [[jsonObject objectForKey:@"city"]objectForKey:@"coord"];

    
    
    [UIView animateWithDuration:1
                     animations:^{
                         
                         self.mapCam.altitude = 50000000;
                         CLLocationCoordinate2D centerCoord;
                         centerCoord.latitude = [[coords objectForKey:@"lat"] doubleValue];
                         centerCoord.latitude = (centerCoord.latitude + self.mapCam.centerCoordinate.latitude)/2;
                         
                         centerCoord.longitude = [[coords objectForKey:@"lon"] doubleValue];
                         centerCoord.longitude = (centerCoord.longitude + self.mapCam.centerCoordinate.longitude) / 2;
                         
                         self.mapCam.centerCoordinate = centerCoord;
                         [self.mapView setCamera:self.mapCam animated:YES];
                     } completion:^(BOOL finish){

                         CLLocationCoordinate2D centerCoord;
                         centerCoord.latitude = [[coords objectForKey:@"lat"] doubleValue];
                         centerCoord.longitude = [[coords objectForKey:@"lon"] doubleValue];
                         self.mapCam.centerCoordinate = centerCoord;
                         self.mapCam.altitude = 2500000;
                         
                         [self.mapView setCamera:self.mapCam animated:YES];
                     }];
}

@end
