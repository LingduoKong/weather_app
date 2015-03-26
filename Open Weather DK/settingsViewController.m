/********************************************************************************************
 * @class_name           settingsViewController
 * @abstract             A custom viewcontroller for setting notifications.
 * @description          In this viewcontroller you can choose a city of which the weather you wanna be notified and when you wanna be notified. A date picker and a picker view are included.
 ********************************************************************************************/

#import "settingsViewController.h"
#import "NSString+KtoC.h"
#import "SharedNetworking.h"

@interface settingsViewController ()

@end

@implementation settingsViewController
NSDate *dateTime;

///---------------------------------------------------------------------------------------------
#pragma mark -- pass the array of city ids from UserDefaultViewController to self.AllCityIds
///---------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *cityIdArray = (NSArray*)[defaults objectForKey:@"userCities"];

    if (!cityIdArray) {
        cityArray = [[NSMutableArray alloc] init];
    }
    else {
        cityArray = [[NSMutableArray alloc] initWithArray:cityIdArray];
    }
    
    self.cities = [[NSMutableArray alloc] init];
    
    [self.cityPicker setDelegate:self];
    self.dataPicker_label.layer.cornerRadius = 10;
    self.dataPicker_label.layer.masksToBounds=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma city picker delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [cityArray count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?id=%@&mode=json", cityArray[row]];
    
    NSString *cityName = nil;
    
//    [[SharedNetworking sharedSharedNetworking] retrieveRSSFeedForURL: url
//                                                             success:^(NSMutableDictionary *dictionary, NSError *error) {
//                                                                 dispatch_async(dispatch_get_main_queue(), ^{
//                                                                     
//                                                                     [self.cities addObject:dictionary];
//
//                                                                 });
//                                                             }
//                                                             failure:^{
//                                                                 dispatch_async(dispatch_get_main_queue(), ^{
//                                                                     NSLog(@"Problem with Data");
//                                                                     
//                                                                 });
//                                                             }];
//    NSLog(@"%@", self.cities);
//
//    return [[self.cities objectAtIndex:row] objectForKey:@"name"];

    
    NSData *jsonData = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString: url]];
    
    NSDictionary *jsonObject=[NSJSONSerialization
                              JSONObjectWithData:jsonData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
    cityName =  [jsonObject objectForKey:@"name"];
    return cityName;
}

// date picker
- (IBAction)datePicker:(UIDatePicker*)sender {
    dateTime = sender.date;
}

/********************************************************************************************
 * @method           setNotification
 * @abstract         action of setNotification button
 * @description      schedule a UILocalNotification notifying the weather of the city at the time set.
 ********************************************************************************************/

- (IBAction)setNotification:(UIButton *)sender {
     NSLog(@"[settingsViewController] setNotification button pressed.");
    
     UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
     // check if the notification is granted
     if (grantedSettings.types == UIUserNotificationTypeNone) {
         UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Warning!"
                                                            message:@"Notification is not granted.\nPlease grant it in Settings."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
         [theAlert show];
         return;
     }

    // check if there exist cities to select
    if ([cityArray count] == 0) {
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Warning!"
                                                           message:@"No city to select."
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
        [theAlert show];
        return;
    }
    
    
    // turn weather notification on
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    if (localNotification == nil) {
        return;
    }
    // set the fire date of the local notification
    localNotification.fireDate = dateTime;
    // set repeat
    
    // set time zone of the local notification
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    // set the content of the local notification
    NSInteger row = [self.cityPicker selectedRowInComponent:0];
    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?id=%@&mode=json", [cityArray objectAtIndex:row]];
    
    NSLog(@"[settingsViewController] get the name of city %@ from url: %@", [cityArray objectAtIndex:row], url);
    
    NSData *jsonData = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString: url]];
    
    NSDictionary *jsonObject=[NSJSONSerialization
                              JSONObjectWithData:jsonData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
    
    NSString* tempC = [NSString stringWithFormat:@"%@", jsonObject[@"main"][@"temp"]];
    localNotification.alertBody = [NSString stringWithFormat:@"DK Weather Report:\nPrefered City: %@\nTemperature: %@°C", [jsonObject objectForKey:@"name"], [tempC KtoC]];
    
    // set the title of the button
    localNotification.alertAction = @"View";
    // set sound of the reminder
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    // set category
    localNotification.category = @"ACTIONABLE";
    // set badge number
    localNotification.applicationIconBadgeNumber = 0;
    // set references
    NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:@"weather_notification",@"id",nil];
    
    localNotification.userInfo = infoDic;
    // trigger the notification at the scheduled date
    //[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    NSLog(@"[settingsViewController] Local Notification set in UserDefaulViewController: %@", localNotification);
    
    NSString *notificationMessage = [NSString stringWithFormat:@"You will receive a notification telling you the weather in %@ at %@", jsonObject[@"city"][@"name"], dateTime];
    UIAlertView *successAlert = [[UIAlertView alloc]initWithTitle:@"Set Notification Successfully!" message:notificationMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [successAlert show];
}
@end
