#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Register non-interactive notifications.
    //[self registerForNotifications];
    
    // Register interactive notifications.
    [self registerForNotifications];
    
    // Test and handle launching from a notification
    NSLog(@"Launch Options:%@",launchOptions);
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    // If not nil, the application was based on an incoming notifiation
    if (notification) {
        NSLog(@"launch from notification.");
        // Access the payload content
        NSLog(@"Notification payload: %@", [notification.userInfo objectForKey:@"payload"]);
        
        // Show an alert view so we can verify this launch sequence
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"LocalNotifications from didFinishLaunchingWithOptions"
                                                        message:@"Notifications from application"
                                                       delegate:self cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        [alert show];
    }

    
    [self setPreferenceDefaults];
    
    [self customizeAppearance];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        self.window.frame =  CGRectMake(0,0,self.window.frame.size.width,self.window.frame.size.height);
        
        UIApplication *myApp = [UIApplication sharedApplication];
        
        [myApp setStatusBarStyle: UIStatusBarStyleLightContent];
        
    }
    
    return YES;
}

#pragma  mark - Appearance Proxy
/**************************************************************************************
 * @method               customizeAppearance
 * @abstract             Call the appearance proxy methods on interface objects
 * @description
 **************************************************************************************/
- (void)customizeAppearance
{
    UIColor* skyBlue = [UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:1];
    // set status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    ///[[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:1]];
    [[UINavigationBar appearance] setBarTintColor:skyBlue];
    
    UIFont *font = [UIFont fontWithName:@"ArialRoundedMTBold" size:20.0f];
    UIColor *color = [UIColor whiteColor];
    
    NSMutableDictionary *navBarTextAttributes = [NSMutableDictionary dictionaryWithCapacity:1];
    [navBarTextAttributes setObject:font forKey:NSFontAttributeName];
    [navBarTextAttributes setObject:color forKey:NSForegroundColorAttributeName ];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:navBarTextAttributes forState:0];
    
    [[UINavigationBar appearance] setTitleTextAttributes: navBarTextAttributes];
    
    [[UINavigationBar appearance] setTintColor:color];
    
    [[UIToolbar appearance] setTintColor:color];
    
    [[UIToolbar appearance] setBarTintColor:skyBlue];
    
    [[UIDatePicker appearance] setBackgroundColor:skyBlue];
    
    [[UIPickerView appearance] setBackgroundColor:skyBlue];

}

/*******************************************************************************
 * @method setPreferencesDefaults
 ******************************************************************************/
- (void)setPreferenceDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithDictionary:[self defaultsFromPlistNamed:@"Root"]];//[NSDictionary dictionaryWithObject:[NSDate date]
    //forKey:@"Initial Run"];
    [defaults registerDefaults:appDefaults];
    //NSLog(@"NSUserDefaults: %@", [[NSUserDefaults standardUserDefaults]
    //dictionaryRepresentation]);
}

- (NSDictionary *)defaultsFromPlistNamed:(NSString *)plistName {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    NSAssert(settingsBundle, @"Could not find Settings.bundle while loading defaults.");
    
    NSString *plistFullName = [NSString stringWithFormat:@"%@.plist", plistName];
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle
                                                                         stringByAppendingPathComponent:plistFullName]];
    NSAssert1(settings, @"Could not load plist '%@' while loading defaults.", plistFullName);
    
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    NSAssert1(preferences, @"Could not find preferences entry in plist '%@' while loading defaults.",
              plistFullName);
    
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        id value = [prefSpecification objectForKey:@"DefaultValue"];
        if(key && value) {
            [defaults setObject:value forKey:key];
        }
        
        NSString *type = [prefSpecification objectForKey:@"Type"];
        if ([type isEqualToString:@"PSChildPaneSpecifier"]) {
            NSString *file = [prefSpecification objectForKey:@"File"];
            NSAssert1(file, @"Unable to get child plist name from plist '%@'", plistFullName);
            [defaults addEntriesFromDictionary:[self defaultsFromPlistNamed:file]];
        }
    }
    
    return defaults;
}

///-----------------------------------------------------------------------------
#pragma mark - Notification Registration and Handling
///-----------------------------------------------------------------------------
- (void)registerForNotifications
{
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
                                            UIUserNotificationTypeAlert |
                                            UIUserNotificationTypeBadge |
                                            UIUserNotificationTypeSound
                                                                             categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

//- (void)registerForNotificationsWithActions
//{
//    // Action 1
//    UIMutableUserNotificationAction *action1;
//    action1 = [[UIMutableUserNotificationAction alloc] init];
//    [action1 setActivationMode:UIUserNotificationActivationModeBackground];
//    [action1 setTitle:@"Action 1"];
//    [action1 setIdentifier:@"ACTION_ONE"];
//    [action1 setDestructive:NO];
//    [action1 setAuthenticationRequired:NO];
//    
//    // Action 2
//    UIMutableUserNotificationAction *action2;
//    action2 = [[UIMutableUserNotificationAction alloc] init];
//    [action2 setActivationMode:UIUserNotificationActivationModeBackground];
//    [action2 setTitle:@"Action 2"];
//    [action2 setIdentifier:@"ACTION_TWO"];
//    [action2 setDestructive:NO];
//    [action2 setAuthenticationRequired:NO];
//    
//    // Create a category with actions
//    UIMutableUserNotificationCategory *actionCategory;
//    actionCategory = [[UIMutableUserNotificationCategory alloc] init];
//    [actionCategory setIdentifier:@"ACTIONABLE"];
//    [actionCategory setActions:@[action1, action2]
//                    forContext:UIUserNotificationActionContextDefault];
//    NSSet *categories = [NSSet setWithObject:actionCategory];
//    
//    // Register the notification
//    UIUserNotificationType types = (UIUserNotificationTypeAlert|
//                                    UIUserNotificationTypeSound|
//                                    UIUserNotificationTypeBadge);
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
//    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//}

- (void)application:(UIApplication *) application didReceiveLocalNotification:(UILocalNotification *)notification {
    if ([[notification.userInfo objectForKey:@"id"] isEqualToString:@"weather_notification"]) {
        //judge current status of the application，if it is alive，then remind，otherwise don't
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Local Notification Received" message:notification.alertBody delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:notification.alertAction, nil];
            [alert show];
        }
//        else if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Local Notification Received (Background)" message:notification.alertBody delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:notification.alertAction, nil];
//            [alert show];
//        }
//        else if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Local Notification Received (Inactive)" message:notification.alertBody delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:notification.alertAction, nil];
//            [alert show];
//        }
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:@"ACTION_ONE"]) {
        NSLog(@"You chose action 1.");
    } else if ([identifier isEqualToString:@"ACTION_TWO"]) {
        NSLog(@"You chose action 2.");
    }
    if (completionHandler) {
        completionHandler();
    }
}

// original

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
