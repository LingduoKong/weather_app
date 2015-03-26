/********************************************************************************************
 * @class_name           SearchViewcontroller
 * @abstract             A custom tableviewcontroller with a search bar.
 * @description          In this viewcontroller you can input the city you want in the search bar
 and the table view will return the result(s). Currently we only support 22 cities sence the API sucks.
 ********************************************************************************************/

#import <UIKit/UIKit.h>
#import "SharedNetworking.h"
#import "SearchResultCell.h"
#import "DetailViewController.h"
#import "UserDefautViewController.h"

@interface SearchViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

@property (nonatomic, strong) NSMutableArray *AllCities;
@property BOOL isFiltered;

@property (strong, nonatomic) IBOutlet UISearchBar *CitySearchBar;
@property (strong, nonatomic) IBOutlet UITableView *CityList;
- (IBAction)CancelButton:(id)sender;

/* delegate property */
@property (weak, nonatomic) id<UpdateUserDefaultViewDelegate> delegate;
@end
