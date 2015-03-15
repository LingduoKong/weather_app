//
//  BookMarkTableViewController.h
//  Open Weather DK
//
//  Created by Lingduo Kong on 3/10/15.
//  Copyright (c) 2015 Lingduo Kong. All rights reserved.
//

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
