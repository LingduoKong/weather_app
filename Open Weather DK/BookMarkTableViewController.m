/********************************************************************************************
 * @class_name           BookMarkTableViewController
 * @abstract             A custom popover tableviewcontroller.
 * @description          Shows the list of users' cities when the user are using the map in order to make it faster to search cities on the map.
 ********************************************************************************************/

#import "BookMarkTableViewController.h"
#import "SharedNetworking.h"

@interface BookMarkTableViewController ()

@end

@implementation BookMarkTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *cityIdArray = (NSArray*)[defaults objectForKey:@"userCities"];
    
    if (!cityIdArray) {
        self.AllCityIds = [[NSMutableArray alloc] init];
    }
    else {
        self.AllCityIds = [[NSMutableArray alloc] initWithArray:cityIdArray];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.AllCityIds count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BookMarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BooKMarkCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?id=%@&mode=json", [self.AllCityIds objectAtIndex:indexPath.row]];
    NSLog(@"[BookMarkTableViewController] get city with id %@ from url: %@", self.AllCityIds[indexPath.row], url);
    [[SharedNetworking sharedSharedNetworking] retrieveRSSFeedForURL:url
                                                             success:^(NSMutableDictionary *dictionary, NSError *error) {
                                                                 
                                                                 NSLog(@"[BookMarkTableViewController] data of city with id %@: %@", self.AllCityIds[indexPath.row], dictionary);
                                                                 cell.cityNameLabel.text = dictionary[@"name"];
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                 });
                                                             }
                                                             failure:^{
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     NSLog(@"Problem with Data");

                                                                 });
                                                             }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.AllCityIds count]) {
        return;
    }
    [self.delegate handleCityIdFromBookMark:[self.AllCityIds objectAtIndex:indexPath.row]];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
