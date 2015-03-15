//
//  settingsViewController.h
//  Open Weather DK
//
//  Created by dongjiaming on 15/3/8.
//  Copyright (c) 2015年 Lingduo Kong. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Custom Protocol used to send the notification of the daily weather in current city
 */

@interface settingsViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>
{
    __block NSMutableArray *cityArray;
}

- (IBAction)datePicker:(UIDatePicker*)sender;
@property (strong, nonatomic) IBOutlet UIDatePicker *dataPicker_label;
- (IBAction)setNotification:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIPickerView *cityPicker;

@end
