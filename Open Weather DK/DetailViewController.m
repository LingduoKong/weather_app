//
//  DetailViewController.m
//  Open Weather D.K.
//
//  Created by dongjiaming on 15/2/27.
//  Copyright (c) 2015年 The University of Chicago, Department of Computer Science. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(NSString*)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)downloadByCityID {
    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?id=%@&mode=json", self.detailItem];
    [[SharedNetworking sharedSharedNetworking] retrieveRSSFeedForURL:url
                                                             success:^(NSMutableDictionary *dictionary, NSError *error) {
                                                                 // Use dispatch_async to update the table on the main thread
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     _data = dictionary;
                                                                     NSLog(@"%@", _data);
                                                                     
                                                                     [self configureDailyScrollView:_data];
                                                                     [self configureBaseScrollView:_data];
                                                                 });
                                                             }
                                                             failure:^{
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     NSLog(@"Problem with Data");
                                                                 });
                                                             }];
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *dataArray = (NSArray*)[defaults objectForKey:@"userCities"];
        NSMutableArray *newArr = nil;
        if (!dataArray) {
            newArr = [[NSMutableArray alloc] init];
        }
        else {
            newArr = [[NSMutableArray alloc] initWithArray:dataArray];
        }
        if (![newArr containsObject:self.detailItem]) {
            [self.saveButton setTitle:@"Save"];
        }
        else {
            [self.saveButton setTitle:@"UnSave"];
        }

        [self downloadByCityID];
        [self configureScrollView];

    }
}

#pragma mark base scrollview

-(void)configureScrollView {
    
    // init elements
    self.cityName = [[UILabel alloc]initWithFrame:CGRectMake(50, 50, self.width/2, 50)];
    self.country = [[UILabel alloc]initWithFrame:CGRectMake(50, 100, self.width/2, 50)];
    
    self.scrollviewDaily = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.height/2, self.width, self.height/2)];
    self.scrollviewDaily.contentSize = CGSizeMake(self.width*2.5, self.height/2);
    [self.scrollviewDaily setShowsHorizontalScrollIndicator:NO];
    self.scrollviewDaily.backgroundColor = [UIColor clearColor];
    
    [self.BaseScrollView addSubview:self.cityName];
    [self.BaseScrollView addSubview:self.country];
    [self.BaseScrollView addSubview:self.scrollviewDaily];

    // configure base scrollview
    self.BaseScrollView.delegate = self;
    self.scrollviewDaily.delegate = self;
    self.BaseScrollView.contentSize = CGSizeMake(self.width/2, self.height*2);

}

#pragma mark configuredetail

-(void)configureDailyScrollView :(NSMutableDictionary*) data{
    
    NSArray *sevenDayWeather = [[NSArray alloc]initWithArray: [data objectForKey:@"list"]];
    
    CGFloat width = (self.width*2 - 15)/7;
    CGFloat height = (self.height/2 - 5)/5;
    
    for (int i=0; i<7; i++) {
        
        UILabel *date_label = [[UILabel alloc]initWithFrame:CGRectMake(5+width*i, 5, width, height/2)];
        NSString *date_stamp = [NSString stringWithFormat:@"%@", [[sevenDayWeather objectAtIndex:i]objectForKey:@"dt"]];
        if (i==0) {
            date_label.text = [NSString stringWithFormat:@"    Today"];
        }
        else date_label.text = [date_stamp TimeStamptoDate];
        
        NSString *URL = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png", [[[sevenDayWeather objectAtIndex:i][@"weather"] objectAtIndex:0]objectForKey:@"icon" ]];
        NSData *imagedata = [NSData dataWithContentsOfURL:[NSURL URLWithString: URL]];
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(width*i, 5+height/2, height*1.5, height*1.5)];
        icon.image = [UIImage imageWithData:imagedata];
        
        UILabel *temperature_high = [[UILabel alloc] initWithFrame:CGRectMake(15+width*i, 5+height*2, width, height/2)];
        NSString *tempH = [[NSString stringWithFormat:@"%@", [[[sevenDayWeather objectAtIndex:i]objectForKey:@"temp"]objectForKey:@"max"]] KtoC];
        temperature_high.text = [NSString stringWithFormat:@"  %@°C", tempH];
        UILabel *temperature_low = [[UILabel alloc] initWithFrame:CGRectMake(15+width*i, 5+height*2.5, width, height/2)];
        NSString *tempL = [[NSString stringWithFormat:@"%@", [[[sevenDayWeather objectAtIndex:i]objectForKey:@"temp"]objectForKey:@"min"]] KtoC];
        temperature_low.text = [NSString stringWithFormat:@"  %@°C", tempL];
        UILabel *weather_condition = [[UILabel alloc] initWithFrame:CGRectMake(15+width*i, 5+height*3, width, height/2)];
        weather_condition.text = [NSString stringWithFormat:@"  %@",[[[sevenDayWeather objectAtIndex:i][@"weather"] objectAtIndex:0]objectForKey:@"main" ]];

        
        [self.scrollviewDaily addSubview:date_label];
        [self.scrollviewDaily addSubview:icon];
        [self.scrollviewDaily addSubview:temperature_high];
        [self.scrollviewDaily addSubview:temperature_low];
        [self.scrollviewDaily addSubview: weather_condition];
    }
}

#pragma mark configure base scroll

-(void)configureBaseScrollView: (NSMutableDictionary*) data{
    NSDictionary *city = [data objectForKey:@"city"];
    
    // configure base scroll upper labels
    UILabel *morn_tempC = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, self.width/2, self.height/6)];
    NSString *morn_temC = [[NSString stringWithFormat:@"%@", [[[[data objectForKey:@"list"]objectAtIndex:0]objectForKey:@"temp"]objectForKey:@"morn"]] KtoC];
    morn_tempC.text = [NSString stringWithFormat:@"Morning: %@°C", morn_temC];
    UILabel *eve_tempC = [[UILabel alloc]initWithFrame:CGRectMake(10, 20+self.height/12, self.width/2, self.height/6)];
    NSString *eve_temC = [[NSString stringWithFormat:@"%@", [[[[data objectForKey:@"list"]objectAtIndex:0]objectForKey:@"temp"]objectForKey:@"eve"]] KtoC];
    eve_tempC.text = [NSString stringWithFormat:@"Evening: %@°C", eve_temC];
    UILabel *night_tempC = [[UILabel alloc]initWithFrame:CGRectMake(10,20+self.height/12*2, self.width/2, self.height/6)];
    NSString *night_temC = [[NSString stringWithFormat:@"%@", [[[[data objectForKey:@"list"]objectAtIndex:0]objectForKey:@"temp"]objectForKey:@"night"]] KtoC];
    night_tempC.text = [NSString stringWithFormat:@"Night:     %@°C", night_temC];
    
    UILabel *city_name = [[UILabel alloc]initWithFrame:CGRectMake(10, self.height/3, self.width/2, self.height/7)];
    city_name.text = [city objectForKey:@"name"];
    UILabel *country = [[UILabel alloc]initWithFrame:CGRectMake(10, self.height/2.7, self.width/2, self.height/6)];
    country.text = [city objectForKey:@"country"];
    
    [self.BaseScrollView addSubview:city_name];
    [self.BaseScrollView addSubview:country];
    [self.BaseScrollView addSubview:morn_tempC];
    [self.BaseScrollView addSubview:eve_tempC];
    [self.BaseScrollView addSubview:night_tempC];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"city id: %@", self.detailItem);
    // Do any additional setup after loading the view, typically from a nib.
    self.width = self.view.frame.size.width;
    self.height =self.view.frame.size.height;
    
    [self configureView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveOrUnsave:(id)sender {
    if (self.detailItem) {
        NSLog(@"save or unsave");
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *cityIdArray = (NSArray*)[defaults objectForKey:@"userCities"];
        NSMutableArray *newArr = nil;
        
        if (!cityIdArray) {
            newArr = [[NSMutableArray alloc] init];
        }
        else {
            newArr = [[NSMutableArray alloc] initWithArray:cityIdArray];
        }
        
        // save this city
        if (![newArr containsObject:self.detailItem]) {
            [newArr addObject:self.detailItem];
            [self.saveButton setTitle:@"UnSave"];
        }
        else {
            [newArr removeObject:self.detailItem];
            [self.saveButton setTitle:@"Save"];
        }
        
        [defaults setObject:newArr forKey:@"userCities"];
        
        [defaults synchronize];
    }
    // update UserDefaultViewController
    [self.delegate update];
}


@end
