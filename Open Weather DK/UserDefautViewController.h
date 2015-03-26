/********************************************************************************************
 * @class_name           UserDefautViewController
 * @abstract             A custom tableviewcontroller
 * @description          Shows abstract of all the cities' weather in user defaults added by the user's save operation.
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
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mapButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingButton;

@property (nonatomic, retain)CLLocationManager* locationManager;

//record id of user's current city
@property (strong, nonatomic) NSString* currentCityId;

@end
