//
//  WeatherAnnotation.m
//  Open Weather DK
//
//  Created by dongjiaming on 15/3/6.
//  Copyright (c) 2015年 Lingduo Kong. All rights reserved.
//

#import "WeatherAnnotation.h"

@implementation WeatherAnnotation
@synthesize coordinate = _coordinate;
@synthesize cityName = _cityName;
@synthesize temperature = _temperature;

- (id)initWithCityName:(NSString*)cityName temperature:(NSString*)temperature coordinate:(CLLocationCoordinate2D)coordinate cityId:(NSString*)cityId{
    if (self = [super init]) {
        _cityName = [cityName copy];
        _temperature = [temperature copy];
        _coordinate = coordinate;
        _cityId = cityId;
    }
    return self;
}

- (NSString*)subtitle {
    return _temperature;
}
- (NSString*)title {
    return _cityName;
}
@end
