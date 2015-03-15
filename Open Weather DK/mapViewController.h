//
//  mapViewController.h
//  Open Weather DK
//
//  Created by dongjiaming on 15/3/6.
//  Copyright (c) 2015年 Lingduo Kong. All rights reserved.
//

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
