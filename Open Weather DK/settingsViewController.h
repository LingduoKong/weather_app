/********************************************************************************************
 * @class_name           settingsViewController
 * @abstract             A custom viewcontroller for setting notifications.
 * @description          In this viewcontroller you can choose a city of which the weather you wanna be notified and when you wanna be notified. A date picker and a picker view are included.
 ********************************************************************************************/

#import <UIKit/UIKit.h>

/**
 * Custom Protocol used to send the notification of the daily weather in current city
 */

@interface settingsViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSMutableArray *cityArray;
}

- (IBAction)datePicker:(UIDatePicker*)sender;
@property (strong, nonatomic) IBOutlet UIDatePicker *dataPicker_label;
- (IBAction)setNotification:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIPickerView *cityPicker;

@property (nonatomic, strong) NSMutableArray *cities;

@end
