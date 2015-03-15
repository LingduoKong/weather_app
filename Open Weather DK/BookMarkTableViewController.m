/********************************************************************************************
 *                                   Special Explanation
 *    Recently an accident happens with the weather API we've been using because of unknown
 *    reasons, so we have to use fake data instead. We extend our apology for the inconvenience
 *    and hope you could understand. All Data showed is unreliable.
 ********************************************************************************************/

/********************************************************************************************
 * @class_name           BookMarkTableViewController
 * @abstract             A custom popover tableviewcontroller.
 * @description          Shows the list of users' cities when the user are using the map in order to make it faster to search cities on the map.
 ********************************************************************************************/

#import "BookMarkTableViewController.h"

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
    NSString *url = [NSString stringWithFormat:@"https://raw.githubusercontent.com/LingduoKong/mydata/master/weatherData/%@.json", [self.AllCityIds objectAtIndex:indexPath.row]];
    
    NSLog(@"[BookMarkTableViewController] get city with id %@ from url: %@", self.AllCityIds[indexPath.row], url);
    
    NSData *jsonData = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString: url]];
    
    NSDictionary *jsonObject=[NSJSONSerialization
                              JSONObjectWithData:jsonData
                              options:NSJSONReadingMutableLeaves
                              error:nil];
    NSLog(@"[BookMarkTableViewController] data of city with id %@: %@", self.AllCityIds[indexPath.row], jsonObject);
    cell.cityNameLabel.text = jsonObject[@"city"][@"name"];
    return cell;
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
    //[self.AllCityIds objectAtIndex:indexPath.row]
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
