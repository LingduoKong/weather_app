/********************************************************************************************
 * @class_name           BookMarkTableViewController
 * @abstract             A custom popover tableviewcontroller.
 * @description          Shows the list of users' cities when the user are using the map in order to make it faster to search cities on the map.
 ********************************************************************************************/

#import <UIKit/UIKit.h>
#import "BookMarkTableViewCell.h"

/**
 * Custom protocol
 */

@protocol BookmarkToMapViewDelegate <NSObject>
- (void)handleCityIdFromBookMark:(NSString*)cityId;
@end

@interface BookMarkTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *AllCityIds;

/** Delegate property */
@property (weak, nonatomic) id<BookmarkToMapViewDelegate> delegate;

@end
