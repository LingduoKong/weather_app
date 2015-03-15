/********************************************************************************************
 *                                   Special Explanation
 *    Recently an accident happens with the weather API we've been using because of unknown
 *    reasons, so we have to use fake data instead. We extend our apology for the inconvenience
 *    and hope you could understand. All Data showed is unreliable.
 ********************************************************************************************/

/********************************************************************************************
 * @class_name           UserDefautViewController
 * @abstract             A custom tableviewcontroller
 * @description          Shows abstract of all the cities' weather in user defaults added by        the user's save operation.
 ********************************************************************************************/

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
@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mapButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingButton;

@end
