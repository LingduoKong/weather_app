//
//  BookMarkTableViewController.m
//  Open Weather DK
//
//  Created by Lingduo Kong on 3/10/15.
//  Copyright (c) 2015 Lingduo Kong. All rights reserved.
//

#import "BookMarkTableViewController.h"

@interface BookMarkTableViewController ()

@end

@implementation BookMarkTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    NSData *jsonData = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString: url]];
    
    NSDictionary *jsonObject=[NSJSONSerialization
                              JSONObjectWithData:jsonData
                              options:NSJSONReadingMutableLeaves
                              error:nil];

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
