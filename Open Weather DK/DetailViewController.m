/********************************************************************************************
 * @class_name           DetailViewController
 * @abstract             A custom viewcontroller to show the detail of a chosen city
 * @description          Shows details of a certain city, basically daily weather but also including local time of that city, country it belongs to and things like that. It can deal with the save button. It might be segued from userDefaultViewController or SearchViewController.
 ********************************************************************************************/

#import "DetailViewController.h"
#import "UUChart.h"
#import "APTimeZones.h"

@interface DetailViewController ()<UUChartDataSource, JCFlipPageViewDataSource>
@property NSMutableArray* high_temp_array;
@property NSMutableArray* low_temp_array;
@property NSMutableArray* date_chart;

@property (nonatomic, strong) JCFlipPageView *flipPage;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

/********************************************************************************************
 * @method           setDetailItem
 * @abstract         Pass the city id to this detailviewcontroller from other viewcontroller
 * @description      Called when the user segue in this viewcontroller so it gets the city id from outside and assign it to self.detailItem.
 ********************************************************************************************/

- (void)setDetailItem:(NSString*)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;

        [self configureView];
    }
}

/********************************************************************************************
 * @method           downloadByCityID
 * @abstract         download the data
 * @description      Download the details including the 7 days' weather and others by city id and store it in self.data.
 ********************************************************************************************/

- (void)downloadByCityID {
    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?id=%@&mode=json", self.detailItem];
    NSLog(@"[DetailViewController] get details of city id %@ from url: %@", self.detailItem, url);
    
    self.InternetIndicator.hidden = NO;
    [[SharedNetworking sharedSharedNetworking] retrieveRSSFeedForURL:url
                                                             success:^(NSMutableDictionary *dictionary, NSError *error) {
                                                                 // Use dispatch_async to update the table on the main thread
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     _data = dictionary;
                                                                     NSLog(@"[DetailViewController] data of city with id %@: %@", self.detailItem, dictionary);
                                                                     
                                                                     [self configureDailyScrollView:_data];
                                                                     [self configureBaseScrollView:_data];
                                                                     [self.tableView reloadData];
                                                                 });
                                                             }
                                                             failure:^{
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     NSLog(@"[DetailViewController] Problem with Daily Data");
                                                                 });
                                                             }];
    self.InternetIndicator.hidden = YES;
}

/********************************************************************************************
 * @method           configureView
 * @abstract         configure the whole view of DetailViewController.
 * @description      configure the whole view of DetailViewController, including download the data, configure the scroll view contained and adjust save button accordingly.
 ********************************************************************************************/

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

/********************************************************************************************
 * @method           configureScrollView
 * @abstract         configure the scroll view of DetailViewController.
 * @description      preprocess for the configuration of base scroll view and daily scroll view.
 ********************************************************************************************/

-(void)configureScrollView {
    
    [self.view sendSubviewToBack:_BaseScrollView];
    
    // init elements
    
    self.scrollviewDaily = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.height/3*2, self.width, self.height/3)];
    self.scrollviewDaily.contentSize = CGSizeMake(self.width*2, self.height/3);
    [self.scrollviewDaily setShowsHorizontalScrollIndicator:NO];
    self.scrollviewDaily.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    
    [self.BaseScrollView addSubview:self.scrollviewDaily];
    
    // configure base scrollview
    self.BaseScrollView.delegate = self;
    self.scrollviewDaily.delegate = self;
    self.BaseScrollView.contentSize = CGSizeMake(self.width, self.height*3);
 
}

#pragma mark configure daily scrollview

/********************************************************************************************
 * @method           configureDailyScrollView
 * @abstract         configure the daily scroll view of DetailViewController.
 * @description      configure the daily scroll view with the data downloaded to display each day's weather in each of its subviews. (7 days totally)
 ********************************************************************************************/

-(void)configureDailyScrollView :(NSMutableDictionary*) data{
    
    NSArray *sevenDayWeather = [[NSArray alloc]initWithArray: [data objectForKey:@"list"]];
    self.high_temp_array = [[NSMutableArray alloc]init];
    self.low_temp_array = [[NSMutableArray alloc]init];
    self.date_chart = [[NSMutableArray alloc]init];
    
    CGFloat width = (self.width*2 - 14)/7;
    CGFloat height = (self.height/3 - 8)/5;
    
    for (int i=0; i<7; i++) {
        
        CGRect dateFrame = CGRectMake(width*i, 2, width, height);
        CGRect iconFrame = dateFrame;
        iconFrame.origin.y = dateFrame.origin.y + height;
        iconFrame.size.height = height;
        iconFrame.size.width = height;
        CGRect hiFrame = dateFrame;
        hiFrame.origin.y = iconFrame.origin.y+ height;
        hiFrame.size.height = height;
        CGRect loFrame = hiFrame;
        loFrame.origin.y = hiFrame.origin.y + height;
        CGRect conditionFrame = loFrame;
        conditionFrame.origin.y = loFrame.origin.y + height;
        
        NSString *iconName = [NSString stringWithFormat:@"%@", [[[sevenDayWeather objectAtIndex:i][@"weather"] objectAtIndex:0]objectForKey:@"icon" ]];
        NSString *imageName = [NSString stringWithFormat:@"%@.png", iconName];
        UIImageView *icon = [[UIImageView alloc] initWithFrame:iconFrame];
        icon.image = [UIImage imageNamed:imageName];
        
        UILabel *date_label = [[UILabel alloc]initWithFrame:dateFrame];
        date_label.textColor = [UIColor whiteColor];
        NSString *date_stamp = [NSString stringWithFormat:@"%@", [[sevenDayWeather objectAtIndex:i]objectForKey:@"dt"]];
        if (i==0) {
            date_label.text = [NSString stringWithFormat:@"   Today"];
            UIImageView *backgroudImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height+self.toolbarHeight+self.statusBarHeight)];
            backgroudImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"BG%@.jpg",iconName]];
            [self.view addSubview:backgroudImage];
            [self.view sendSubviewToBack:backgroudImage];
        }
        else date_label.text = [date_stamp TimeStamptoDate];
        [self.date_chart addObject:[date_stamp TimeStamptoDate]];
        
        UILabel *temperature_high = [[UILabel alloc] initWithFrame:hiFrame];
        temperature_high.textColor = [UIColor whiteColor];
        NSString *tempH = [[NSString stringWithFormat:@"%@", [[[sevenDayWeather objectAtIndex:i]objectForKey:@"temp"]objectForKey:@"max"]] KtoC];
        [self.high_temp_array addObject:tempH];
        temperature_high.text = [NSString stringWithFormat:@"  %@°C", tempH];
        UILabel *temperature_low = [[UILabel alloc] initWithFrame:loFrame];
        temperature_low.textColor = [UIColor whiteColor];
        NSString *tempL = [[NSString stringWithFormat:@"%@", [[[sevenDayWeather objectAtIndex:i]objectForKey:@"temp"]objectForKey:@"min"]] KtoC];
        [self.low_temp_array addObject:tempL];
        temperature_low.text = [NSString stringWithFormat:@"  %@°C", tempL];
        UILabel *weather_condition = [[UILabel alloc] initWithFrame:conditionFrame];
        weather_condition.text = [NSString stringWithFormat:@"  %@",[[[sevenDayWeather objectAtIndex:i][@"weather"] objectAtIndex:0]objectForKey:@"main" ]];
        weather_condition.textColor = [UIColor whiteColor];
        
        [self.scrollviewDaily addSubview:date_label];
        [self.scrollviewDaily addSubview:icon];
        [self.scrollviewDaily addSubview:temperature_high];
        [self.scrollviewDaily addSubview:temperature_low];
        [self.scrollviewDaily addSubview:weather_condition];
    }
}

#pragma mark configure base scroll

/********************************************************************************************
 * @method           configureBaseScrollView
 * @abstract         configure the base scroll view of DetailViewController.
 * @description      configure the base scroll view with the data downloaded to display the basic information of this city and the current weather of it.
 * @comment          use part of code from  http://www.raywenderlich.com/55384/ios-7-best-practices-part-1
 ********************************************************************************************/

-(void)configureBaseScrollView: (NSMutableDictionary*) data{
    NSDictionary *city = [data objectForKey:@"city"];
    
    CGRect headerFrame = CGRectMake(0, 0, self.width, self.height/3*2);
    
    CGFloat inset = 20;
    
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    
    CGRect hiloFrame = CGRectMake(inset,
                                  headerFrame.size.height - hiloHeight,
                                  headerFrame.size.width - (2 * inset),
                                  hiloHeight);
    
    CGRect temperatureFrame = CGRectMake(inset,
                                         headerFrame.size.height - (temperatureHeight + hiloHeight),
                                         headerFrame.size.width - (2 * inset),
                                         temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset,
                                  temperatureFrame.origin.y - iconHeight,
                                  iconHeight,
                                  iconHeight);
    
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
    
    CGRect countryFrame = CGRectMake(inset,
                                     0,
                                     self.width-inset,
                                     iconHeight);
    
    CGRect timeFrame = CGRectMake(inset,
                                  iconHeight
                                  , self.width-inset,
                                  iconHeight);
    
    CGRect humidityFrame = CGRectMake(0,
                                      iconFrame.origin.y
                                      , self.width-inset
                                      , iconHeight*2);
    
    CGRect windSpeedFrame = CGRectMake(0,
                                       humidityFrame.origin.y+iconHeight*2
                                       , self.width-inset,
                                       iconHeight*2);
    
    CGRect pressureFrame = CGRectMake(0, windSpeedFrame.origin.y+iconHeight*2
                                     , self.width-inset
                                     , iconHeight*2);
    
    
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    
    // configure base scroll view lower labels
    UILabel *wind_speed = [[UILabel alloc]initWithFrame:windSpeedFrame];
    wind_speed.backgroundColor = [UIColor clearColor];
    wind_speed.textAlignment = NSTextAlignmentRight;
    wind_speed.textColor = [UIColor whiteColor];
    wind_speed.numberOfLines = 2;
    wind_speed.text = @"Wind\n:";
    wind_speed.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    
    UILabel *humidity = [[UILabel alloc]initWithFrame:humidityFrame];
    humidity.textAlignment = NSTextAlignmentRight;
    humidity.backgroundColor = [UIColor clearColor];
    humidity.textColor = [UIColor whiteColor];
    humidity.numberOfLines = 2;
    humidity.text = @"Humidity\n:";
    humidity.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    
    UILabel *pressure = [[UILabel alloc]initWithFrame:pressureFrame];
    pressure.textAlignment = NSTextAlignmentRight;
    pressure.backgroundColor = [UIColor clearColor];
    pressure.textColor = [UIColor whiteColor];
    pressure.numberOfLines = 2;
    pressure.text = @"Presure\n:";
    pressure.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];

    wind_speed.text = [NSString stringWithFormat:@"wind speed\n %@", data[@"list"][0][@"speed"]];
    humidity.text = [NSString stringWithFormat:@"humidity\n %@", data[@"list"][0][@"humidity"]];
    pressure.text = [NSString stringWithFormat:@"pressure\n %@", data[@"list"][0][@"pressure"]];
    //
    [header addSubview:humidity];
    [header addSubview:pressure];
    [header addSubview:wind_speed];

    
    // bottom left
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0°";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:temperatureLabel];
    
    // bottom left
    UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0° / 0°";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    [header addSubview:hiloLabel];
    
    UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    conditionsLabel.textColor = [UIColor whiteColor];
    [header addSubview:conditionsLabel];
    
    // bottom left
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:iconView];
    
    // bottom right
    UILabel *country = [[UILabel alloc]initWithFrame:countryFrame];
    country.textAlignment = NSTextAlignmentCenter;
    country.backgroundColor = [UIColor clearColor];
    country.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    country.textColor = [UIColor whiteColor];
    country.text = @"country";
    [header addSubview:country];
    
    // top right
    _timeDisplayer = [[UILabel alloc]initWithFrame:timeFrame];
    _timeDisplayer.textAlignment = NSTextAlignmentCenter;
    _timeDisplayer.backgroundColor = [UIColor clearColor];
    _timeDisplayer.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    _timeDisplayer.textColor = [UIColor whiteColor];
    [header addSubview:_timeDisplayer];
    
    // configure hilolabel
    NSString *hightemp = [[NSString stringWithFormat:@"%@", [[[[data objectForKey:@"list"]objectAtIndex:0]objectForKey:@"temp"]objectForKey:@"max"]] KtoC];
    NSString *lowtemp = [[NSString stringWithFormat:@"%@", [[[[data objectForKey:@"list"]objectAtIndex:0]objectForKey:@"temp"]objectForKey:@"min"]] KtoC];
    hiloLabel.text = [NSString stringWithFormat:@" %@° / %@°", hightemp, lowtemp];
    
    // configure icon view
    NSString *iconName = [NSString stringWithFormat:@"%@", [[[[data objectForKey:@"list"] objectAtIndex:0][@"weather"] objectAtIndex:0]objectForKey:@"icon" ]];
    NSString *imageName = [NSString stringWithFormat:@"%@.png", iconName];
    iconView.image = [UIImage imageNamed:imageName];
    
    //configure condition label
    NSString * Description = [[[[[data objectForKey:@"list"]objectAtIndex:0]objectForKey:@"weather"]objectAtIndex:0]objectForKey:@"description"];
    conditionsLabel.text = Description;
    
    // configure temperature
    long temperature = [hightemp integerValue] + [lowtemp integerValue];
    temperatureLabel.text = [NSString stringWithFormat:@"%ld", temperature/2];
    
    // configure country
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    country.text = [locale displayNameForKey: NSLocaleCountryCode value: [city objectForKey:@"country"]];
    
    // configure time
    NSDictionary *coords = city[@"coord"];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[coords objectForKey:@"lat"] doubleValue] longitude:[[coords objectForKey:@"lon"] doubleValue]];
    _timeZone = [[APTimeZones sharedInstance] timeZoneWithLocation:location];
    _Timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    
    self.title_name.text = [city objectForKey:@"name"];
    
    [self.BaseScrollView addSubview:header];
    
    [self addTableView];
    
    //flipPage initializing
    _flipPage = [[JCFlipPageView alloc] initWithFrame:CGRectMake(0, self.height*2.05, self.width, self.height*0.95)];
    
    //download data and store them into userdefaults
    
    NSString *urlForoHour = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?id=%@&mode=json", self.detailItem];
    NSLog(@"[DetailViewController] get hours details of city id %@ from url: %@", self.detailItem, urlForoHour);
    [[SharedNetworking sharedSharedNetworking] retrieveRSSFeedForURL:urlForoHour
                                                             success:^(NSMutableDictionary *dictionary, NSError *error) {
                                                                 // Use dispatch_async to update the table on the main thread
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     NSLog(@"[DetailViewController]hour data (every 3 hours) of city with id %@: %@", self.detailItem, dictionary[@"list"]);
                                                                     
                                                                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                                     [defaults setObject: dictionary[@"list"] forKey:@"dataForDaily"];
                                                                     [defaults synchronize];
                                                                 });
                                                             }
                                                             failure:^{
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     NSLog(@"[DetailViewController] Problem with Daily Data");
                                                                 });
                                                             }];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *cityIdArray = (NSArray*)[defaults objectForKey:@"dataForDaily"];
    
    if(cityIdArray!=nil)
    {
        self.dataForDaily = [[NSMutableArray alloc]initWithArray:cityIdArray];
        _flipPage.dataSource = self;
        [self.BaseScrollView addSubview:_flipPage];
        [_flipPage reloadData];
    }
}

#pragma mark plot

/********************************************************************************************
 * Followings are implementations of functions in UUChartDataSource delegate, which is used to
 * draw the Broken Line Graph of 7 days' weather of the city.
 ********************************************************************************************/

- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    return [NSArray arrayWithArray:self.date_chart];
}

- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    NSArray *aryH = [NSArray arrayWithArray:self.high_temp_array];
    NSArray *aryL = [NSArray arrayWithArray:self.low_temp_array];
    
    return @[aryH,aryL];
}

- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UURed,UUBlue];
}

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

//判断显示横线条
- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}

#pragma mark - Addtableview

-(void)addTableView{

    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIImage *background = [UIImage imageNamed:@"bg"];
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.height, self.width, self.height*2)];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.BaseScrollView addSubview:self.tableView];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section==0) {
        return 8;
    }
    else return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    if (indexPath.section==0) {
        return (self.height-self.height/3)/8;
    }
    else return self.height*0.051;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return self.height/3;
    }
    else return 0;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section==0) {
        CGRect chartFrame = CGRectMake(0, 0, self.width, self.height/3);
        UIView * chart = [[UIView alloc]initWithFrame:chartFrame];
        UUChart *chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(0, 0, self.width, self.height/3)
                                                           withSource:self
                                                            withStyle:UUChartLineStyle];
        chartView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
        [chartView showInView:chart];
        return chart;
    }
    else return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.row==0) {
        if (indexPath.section==0) {
            cell.textLabel.text = @"Next Seven Days Forecast";
            cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
        }
        else {
            cell.textLabel.text = @"Hours Forecast";
            cell.detailTextLabel.text = @"Pull here to come back";
            cell.backgroundColor = [UIColor clearColor];
        }
        return cell;
    }
    
    NSArray *sevenDayWeather = [[NSArray alloc]initWithArray: [_data objectForKey:@"list"]];
    
    NSString *date_stamp = [NSString stringWithFormat:@"%@", [[sevenDayWeather objectAtIndex:indexPath.row-1]objectForKey:@"dt"]];
    cell.textLabel.text = [date_stamp TimeStamptoDate];
    
    NSString *iconName = [NSString stringWithFormat:@"%@", [[[sevenDayWeather objectAtIndex:indexPath.row-1][@"weather"] objectAtIndex:0]objectForKey:@"icon" ]];
    NSString *imageName = [NSString stringWithFormat:@"%@.png", iconName];

    cell.imageView.image = [UIImage imageNamed:imageName];
    
    NSString *tempH = [[NSString stringWithFormat:@"%@", [[[sevenDayWeather objectAtIndex:indexPath.row-1]objectForKey:@"temp"]objectForKey:@"max"]] KtoC];
    NSString *tempL = [[NSString stringWithFormat:@"%@", [[[sevenDayWeather objectAtIndex:indexPath.row-1]objectForKey:@"temp"]objectForKey:@"min"]] KtoC];
    cell.detailTextLabel.text = [NSString stringWithFormat:@" %@ / %@°C", tempH, tempL];
    return cell;
}


#pragma mark - Default

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataForDaily = [[NSMutableArray alloc] init];
    
    NSLog(@"[DetailViewController] current city id: %@", self.detailItem);
    // Do any additional setup after loading the view, typically from a nib.
    self.width = self.view.frame.size.width;
    self.toolbarHeight = self.toolbar.frame.size.height;
    self.statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.height =self.view.frame.size.height - self.toolbarHeight - self.statusBarHeight;
    
    [_toolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    UIFont *font = [UIFont fontWithName:@"ArialRoundedMTBold" size:20.0f];
    _title_name.font = font;
    [_title_name setTextColor:[UIColor whiteColor]];
    
    [self.view bringSubviewToFront:self.InternetIndicator];
    [self configureView];
    
    _Timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];

    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
}

/********************************************************************************************
 * @method           updateTime
 * @abstract         update local time
 * @description      called by the Timer to update local time of the city.
 ********************************************************************************************/

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

#pragma mark -button

/********************************************************************************************
 * @method           saveOrUnsave
 * @abstract         action of save button
 * @description      if the user presses save, add the city into user defaults, or if the user presses unsave, remove the city from user defaults. Then call the delegate function update to update UserDefaultViewController.
 ********************************************************************************************/

- (IBAction)saveOrUnsave:(id)sender {
    if (self.detailItem) {
        NSLog(@"[DetailViewController] press save/unsave button.");
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

#pragma mark - JCFlipPageViewDataSource

- (NSUInteger)numberOfPagesInFlipPageView:(JCFlipPageView *)flipPageView
{
    if (self.dataForDaily != nil) {
        return 24;
    }
    else {
        return -1;
    }
}

- (JCFlipPage *)flipPageView:(JCFlipPageView *)flipPageView pageAtIndex:(NSUInteger)index
{
    
    if([self.dataForDaily count]== 0)return nil;
    
    //*********************************************************************//
    
    static NSString *kPageID = @"numberPageID";
    JCFlipPage *page = [flipPageView dequeueReusablePageWithReuseIdentifier:kPageID];
    if (!page)
    {
        page = [[JCFlipPage alloc] initWithFrame:flipPageView.bounds reuseIdentifier:kPageID];
    }else{}
    
    // assign all the labels
    long windspeed = [_dataForDaily[index][@"wind"][@"speed"] integerValue];
    page.windSpeedLabel.text = [NSString stringWithFormat:@"wind speed\n %ld", windspeed];
    long humidity = [_dataForDaily[index][@"main"][@"humidity"] integerValue];
    page.humidityLabel.text = [NSString stringWithFormat:@"humidity\n %ld", humidity];
    long pressure = [_dataForDaily[index][@"main"][@"pressure"] integerValue];
    page.pressureLabel.text = [NSString stringWithFormat:@"pressure\n %ld", pressure];
  
    NSString *hightemp = [NSString stringWithFormat:@"%@", _dataForDaily[index][@"main"][@"temp_max"]];
    NSString *lowtemp = [NSString stringWithFormat:@"%@", _dataForDaily[index][@"main"][@"temp_min"]];
    hightemp = [hightemp KtoC];
    lowtemp = [lowtemp KtoC];
                          
    page.hiloLabel.text = [NSString stringWithFormat:@" %@° / %@°", hightemp, lowtemp];
    
    NSString *iconName = [NSString stringWithFormat:@"%@", _dataForDaily[index][@"weather"][0][@"icon"]];
    NSString *imageName = [NSString stringWithFormat:@"%@.png", iconName];
    page.iconView.image = [UIImage imageNamed:imageName];
    
    page.backgroudImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"BG%@.jpg",iconName]];
    
    //[page sendSubviewToBack:page.backgroudImage];
    
    NSString * Description = _dataForDaily[index][@"weather"][0][@"description"];
    page.conditionsLabel.text = Description;
    
    NSString *temperature = [NSString stringWithFormat:@"%@", _dataForDaily[index][@"main"][@"temp"]];
    temperature = [temperature KtoC];
    page.temperatureLabel.text = temperature;
    
    NSString * time = _dataForDaily[index][@"dt_txt"];
    page.timeLabel.text = time;
    
    return page;
}

@end
