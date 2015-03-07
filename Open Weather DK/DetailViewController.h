//
//  DetailViewController.h
//  Open Weather D.K.
//
//  Created by dongjiaming on 15/2/27.
//  Copyright (c) 2015年 The University of Chicago, Department of Computer Science. All rights reserved.
//

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

@interface DetailViewController : UIViewController<UIScrollViewDelegate>
@property CGFloat width;
@property CGFloat height;

@property (strong, nonatomic) NSString *detailItem;

@property (strong, nonatomic) NSMutableDictionary *data;
@property UILabel *cityName;
@property UILabel *country;


@property UIScrollView *scrollviewDaily;
@property (strong, nonatomic) IBOutlet UIScrollView *BaseScrollView;

// save or unsave current city into UserDefaults
- (IBAction)saveOrUnsave:(id)sender;
//@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

/* delegate property */
@property (weak, nonatomic) id<UpdateUserDefaultViewDelegate> delegate;
@end

