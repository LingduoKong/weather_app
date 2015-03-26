/********************************************************************************************
 * @class_name           DetailViewController
 * @abstract             A custom viewcontroller to show the detail of a chosen city
 * @description          Shows details of a certain city, basically daily weather but also including local time of that city, country it belongs to and things like that. It can deal with the save button. It might be segued from userDefaultViewController or SearchViewController.
 ********************************************************************************************/

#import <UIKit/UIKit.h>
#import "SharedNetworking.h"
#import "NSString+KtoC.h"
#import "NSString+TimeStamptoDate.h"

#import "JCFlipPage.h"
#import "JCFlipPageView.h"

/**
 * Custom Protocol used to update UserDefaultViewController
 */

@protocol UpdateUserDefaultViewDelegate<NSObject>

- (void)update;

@end

@interface DetailViewController : UIViewController<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property CGFloat width;
@property CGFloat height;
@property CGFloat toolbarHeight;
@property CGFloat statusBarHeight;

@property (strong, nonatomic) NSString *detailItem;

@property (strong, nonatomic) NSMutableDictionary *data;
@property (strong, nonatomic) NSMutableArray *dataForDaily;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSTimer *Timer;
@property (strong, nonatomic) IBOutlet UILabel *timeDisplayer;
@property (strong, nonatomic) NSTimeZone *timeZone;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property UIScrollView *scrollviewDaily;
@property (strong, nonatomic) IBOutlet UIScrollView *BaseScrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *InternetIndicator;

// save or unsave current city into UserDefaults
- (IBAction)saveOrUnsave:(id)sender;
//@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) IBOutlet UILabel *title_name;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

// new table view
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat screenHeight;

/* delegate property */
@property (weak, nonatomic) id<UpdateUserDefaultViewDelegate> delegate;
@end

