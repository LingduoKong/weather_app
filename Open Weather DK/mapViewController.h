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

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
@import MapKit;
#import "WeatherAnnotation.h"
#import "DetailViewController.h"
#import "BookMarkTableViewController.h"


@interface mapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate,UIPopoverPresentationControllerDelegate, BookmarkToMapViewDelegate>

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

@property (strong, nonatomic) MKMapCamera *mapCam;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) CLLocationManager* locationManager;
@property (strong, nonatomic) NSMutableArray *AllCityIds;

/* delegate property */
@property (strong, nonatomic) id<UpdateUserDefaultViewDelegate> delegate;

- (void)pass:(NSMutableArray*)cityIdsFromUDVC;

@end
