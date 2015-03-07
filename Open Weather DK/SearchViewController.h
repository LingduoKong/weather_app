//
//  SearchViewController.h
//  Open Weather D.K.
//
//  Created by Lingduo Kong on 2/27/15.
//  Copyright (c) 2015 The University of Chicago, Department of Computer Science. All rights reserved.
//

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
