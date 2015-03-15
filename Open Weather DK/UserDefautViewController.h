//
//  UserDefautViewController.h
//  Open Weather DK
//
//  Created by Lingduo Kong on 3/1/15.
//  Copyright (c) 2015 Lingduo Kong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "SharedNetworking.h"
#import "CityTableViewCell.h"
#import "SearchViewController.h"
#import "settingsViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "NSString+KtoC.h"

#import "mapViewController.h"

@interface UserDefautViewController : UITableViewController<UpdateUserDefaultViewDelegate, CLLocationManagerDelegate>

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSMutableArray *AllCityIds;

@property (strong, nonatomic) NSMutableArray *AllCityInfo;

@property (nonatomic, retain)CLLocationManager* locationManager;

//store all cities
@property (nonatomic, strong) NSMutableArray *allCityNames;
//record id of user's current city
@property (strong, nonatomic) NSString* currentCityId;

@end
