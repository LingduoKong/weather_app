//
//  DetailViewController.m
//  Open Weather D.K.
//
//  Created by dongjiaming on 15/2/27.
//  Copyright (c) 2015年 The University of Chicago, Department of Computer Science. All rights reserved.
//

#import "DetailViewController.h"
#import "UUChart.h"
#import "APTimeZones.h"

@interface DetailViewController ()<UUChartDataSource>
@property NSMutableArray* high_temp_array;
@property NSMutableArray* low_temp_array;
@property NSMutableArray* date_chart;

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
//    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?id=%@&mode=json", self.detailItem];
    NSString *url = [NSString stringWithFormat:@"https://raw.githubusercontent.com/LingduoKong/mydata/master/%@.json", self.detailItem];
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
    
    self.scrollviewDaily = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.height/2.5, self.width, self.height/2)];
    self.scrollviewDaily.contentSize = CGSizeMake(self.width*2, self.height/2);
    [self.scrollviewDaily setShowsHorizontalScrollIndicator:NO];
    self.scrollviewDaily.backgroundColor = [UIColor clearColor];
    
    [self.BaseScrollView addSubview:self.cityName];
    [self.BaseScrollView addSubview:self.country];
    [self.BaseScrollView addSubview:self.scrollviewDaily];
    
    // configure base scrollview
    self.BaseScrollView.delegate = self;
    self.scrollviewDaily.delegate = self;
    self.BaseScrollView.contentSize = CGSizeMake(self.width, self.height*1.5);
    
}

#pragma mark configure daily scrollview

-(void)configureDailyScrollView :(NSMutableDictionary*) data{
    
    NSArray *sevenDayWeather = [[NSArray alloc]initWithArray: [data objectForKey:@"data"]];
    self.high_temp_array = [[NSMutableArray alloc]init];
    self.low_temp_array = [[NSMutableArray alloc]init];
    self.date_chart = [[NSMutableArray alloc]init];
    
    CGFloat width = (self.width*2 - 15)/7;
    CGFloat height = (self.height/2 - 5)/4;
    
    for (int i=0; i<7; i++) {
        
        UILabel *date_label = [[UILabel alloc]initWithFrame:CGRectMake(5+width*i, 5, width, height/2)];
        NSString *date_stamp = [NSString stringWithFormat:@"%@", [[sevenDayWeather objectAtIndex:i]objectForKey:@"dt"]];
        if (i==0) {
            date_label.text = [NSString stringWithFormat:@"    Today"];
        }
        else date_label.text = [date_stamp TimeStamptoDate];
        [self.date_chart addObject:[date_stamp TimeStamptoDate]];
        
        
        NSString *imageName = [NSString stringWithFormat:@"%@.png", [[[sevenDayWeather objectAtIndex:i][@"weather"] objectAtIndex:0]objectForKey:@"icon" ]];
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(width*i, 5+height/2, height*1.5, height*1.5)];
        icon.image = [UIImage imageNamed:imageName];
        
        UILabel *temperature_high = [[UILabel alloc] initWithFrame:CGRectMake(15+width*i, 5+height*2, width, height/2)];
        NSString *tempH = [[NSString stringWithFormat:@"%@", [[[sevenDayWeather objectAtIndex:i]objectForKey:@"temp"]objectForKey:@"max"]] KtoC];
        [self.high_temp_array addObject:tempH];
        temperature_high.text = [NSString stringWithFormat:@"  %@°C", tempH];
        UILabel *temperature_low = [[UILabel alloc] initWithFrame:CGRectMake(15+width*i, 5+height*2.5, width, height/2)];
        NSString *tempL = [[NSString stringWithFormat:@"%@", [[[sevenDayWeather objectAtIndex:i]objectForKey:@"temp"]objectForKey:@"min"]] KtoC];
        [self.low_temp_array addObject:tempL];
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
    NSString *morn_temC = [[NSString stringWithFormat:@"%@", [[[[data objectForKey:@"data"]objectAtIndex:0]objectForKey:@"temp"]objectForKey:@"morn"]] KtoC];
    morn_tempC.text = [NSString stringWithFormat:@"Morning: %@°C", morn_temC];
    
    UILabel *eve_tempC = [[UILabel alloc]initWithFrame:CGRectMake(10, 20+self.height/12, self.width/2, self.height/6)];
    NSString *eve_temC = [[NSString stringWithFormat:@"%@", [[[[data objectForKey:@"data"]objectAtIndex:0]objectForKey:@"temp"]objectForKey:@"eve"]] KtoC];
    eve_tempC.text = [NSString stringWithFormat:@"Evening: %@°C", eve_temC];
    
    UILabel *night_tempC = [[UILabel alloc]initWithFrame:CGRectMake(10, 20+self.height/12*2, self.width/2, self.height/6)];
    NSString *night_temC = [[NSString stringWithFormat:@"%@", [[[[data objectForKey:@"data"]objectAtIndex:0]objectForKey:@"temp"]objectForKey:@"night"]] KtoC];
    night_tempC.text = [NSString stringWithFormat:@"Night:     %@°C", night_temC];
    
    UILabel *description = [[UILabel alloc]initWithFrame:CGRectMake(10, 20+self.height/12*3, self.width/2, self.height/6)];
    description.text = [[[[[data objectForKey:@"data"]objectAtIndex:0]objectForKey:@"weather"]objectAtIndex:0]objectForKey:@"description"];
    
    self.title_name.text = [city objectForKey:@"name"];
    UILabel *country = [[UILabel alloc]initWithFrame:CGRectMake(self.width/2, 20 + self.height/12, self.width/2, self.height/6)];
    
    // convert country code to country name
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    country.text = [locale displayNameForKey: NSLocaleCountryCode
                                                value: [city objectForKey:@"country"]];
    
    // get current time zone by coordinates
    NSDictionary *coords = city[@"coord"];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[coords objectForKey:@"lat"] doubleValue] longitude:[[coords objectForKey:@"lon"] doubleValue]];
    
    _timeZone = [[APTimeZones sharedInstance] timeZoneWithLocation:location];
    
    [self.BaseScrollView addSubview:country];
    [self.BaseScrollView addSubview:morn_tempC];
    [self.BaseScrollView addSubview:eve_tempC];
    [self.BaseScrollView addSubview:night_tempC];
    [self.BaseScrollView addSubview:description];
    
    // configure base scroll view lower labels
    UILabel *wind_speed = [[UILabel alloc]initWithFrame:CGRectMake(10, 20+self.height*7/6, self.width/2, self.height/6)];
    wind_speed.text = [NSString stringWithFormat:@"wind speed: %@", data[@"data"][0][@"speed"]];
    
    UILabel *humidity = [[UILabel alloc]initWithFrame:CGRectMake(10, 70+self.height*7/6, self.width/2, self.height/6)];
    humidity.text = [NSString stringWithFormat:@"humidity: %@", data[@"data"][0][@"humidity"]];
    
    UILabel *pressure = [[UILabel alloc]initWithFrame:CGRectMake(10, 120+self.height*7/6, self.width/2, self.height/6)];
    pressure.text = [NSString stringWithFormat:@"pressure: %@", data[@"data"][0][@"pressure"]];
    
    [self.BaseScrollView addSubview:humidity];
    [self.BaseScrollView addSubview:pressure];
    [self.BaseScrollView addSubview:wind_speed];
    [self plot];
    
}

#pragma mark plot

-(void)plot{
    
    UUChart *chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(0, self.height*0.9, self.width, self.height/3)
                                                       withSource:self
                                                        withStyle:UUChartLineStyle];
    [chartView showInView:self.BaseScrollView];
}

#pragma mark - @required
//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    return [NSArray arrayWithArray:self.date_chart];
}
//数值多重数组
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    NSArray *aryH = [NSArray arrayWithArray:self.high_temp_array];
    NSArray *aryL = [NSArray arrayWithArray:self.low_temp_array];
    
    return @[aryH,aryL];
}

#pragma mark - @optional
//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UURed,UUBlue];
}
//显示数值范围
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    NSInteger min = 100;
    NSInteger max = -100;
    
    for (int i=0; i<7; i++) {
        if([[self.low_temp_array objectAtIndex:i] doubleValue]<min){
            min = [[self.low_temp_array objectAtIndex:i]doubleValue];
        }
        if ([[self.high_temp_array objectAtIndex:i]doubleValue]>max) {
            max = [[self.high_temp_array objectAtIndex:i]doubleValue];
        }
    }
    
    return CGRangeMake(max+1, min-1);
}

#pragma mark 折线图专享功能

//判断显示横线条
- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"city id: %@", self.detailItem);
    // Do any additional setup after loading the view, typically from a nib.
    self.width = self.view.frame.size.width;
    self.height =self.view.frame.size.height;
    
    [self configureView];
    
    _Timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    _timeDisplayer = [[UILabel alloc] initWithFrame:CGRectMake(self.width/2, 20+self.height/12*3, self.width/2, self.height/6)];
    [self.BaseScrollView addSubview:_timeDisplayer];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
}

- (void)updateTime {
    NSDate *date = [NSDate date];
    NSInteger interval = [_timeZone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    _timeDisplayer.text = [_dateFormatter stringFromDate:localeDate];
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
        
        NSLog(@"%@", _data);
    }
    // update UserDefaultViewController
    [self.delegate update];
}


@end
