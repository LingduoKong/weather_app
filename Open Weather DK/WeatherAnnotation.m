/********************************************************************************************
 * @class_name           WeatherAnnotation
 * @abstract             A custom annotation to show city name, weather type and min/max temerature
 * @description          A custom annotation to show city name, weather type and min/max temerature
 ********************************************************************************************/

#import "WeatherAnnotation.h"

@implementation WeatherAnnotation
@synthesize coordinate = _coordinate;
@synthesize cityName = _cityName;
@synthesize temperature = _temperature;

/********************************************************************************************
 * @method           initWithCityName
 * @abstract         initial the annotation with city name, weather type, 2D coordinates and city id.
 * @description      initial the annotation with city name, weather type, 2D coordinates and city id.
 ********************************************************************************************/

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
