/********************************************************************************************
 *                                   Special Explanation
 *    Recently an accident happens with the weather API we've been using because of unknown
 *    reasons, so we have to use fake data instead. We extend our apology for the inconvenience
 *    and hope you could understand. All Data showed is unreliable.
 ********************************************************************************************/

/********************************************************************************************
 * @class_name           DetailViewController
 * @abstract             A custom viewcontroller to show the detail of a chosen city
 * @description          Shows details of a certain city, basically daily weather but also including local time of that city, country it belongs to and things like that. It can deal with the save button. It might be segued from userDefaultViewController or SearchViewController.
 ********************************************************************************************/

#import <UIKit/UIKit.h>
#import "SharedNetworking.h"
#import "NSString+KtoC.h"
#import "NSString+TimeStamptoDate.h"

/**
 * Custom Protocol used to update UserDefaultViewController
 */

@protocol UpdateUserDefaultViewDelegate<NSObject>

- (void)update;

@end

@interface DetailViewController : UIViewController<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property CGFloat width;
@property CGFloat height;

@property (strong, nonatomic) NSString *detailItem;

@property (strong, nonatomic) NSMutableDictionary *data;
@property UILabel *cityName;
@property UILabel *country;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSTimer *Timer;
@property (strong, nonatomic) NSTimeZone *timeZone;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) IBOutlet UILabel *timeDisplayer;

@property UIScrollView *scrollviewDaily;
@property (strong, nonatomic) IBOutlet UIScrollView *BaseScrollView;

// save or unsave current city into UserDefaults
- (IBAction)saveOrUnsave:(id)sender;
//@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) IBOutlet UILabel *title_name;
@property (strong, nonatomic) IBOutlet UIView *ActivityIndicator;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

/* delegate property */
@property (weak, nonatomic) id<UpdateUserDefaultViewDelegate> delegate;
@end

