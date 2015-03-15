/********************************************************************************************
 *                                   Special Explanation
 *    Recently an accident happens with the weather API we've been using because of unknown
 *    reasons, so we have to use fake data instead. We extend our apology for the inconvenience
 *    and hope you could understand. All Data showed is unreliable.
 ********************************************************************************************/

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
    __block NSMutableArray *cityArray;
}

- (IBAction)datePicker:(UIDatePicker*)sender;
@property (strong, nonatomic) IBOutlet UIDatePicker *dataPicker_label;
- (IBAction)setNotification:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIPickerView *cityPicker;

@end
