/********************************************************************************************
 * @class_name           WeatherAnnotation
 * @abstract             A custom annotation to show city name, weather type and min/max temerature
 * @description          A custom annotation to show city name, weather type and min/max temerature
 ********************************************************************************************/

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface WeatherAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D _coordinate;
    NSString *_cityName;
    NSString *_temperature;
}

- (id)initWithCityName:(NSString*)cityName temperature:(NSString*)temperature coordinate:(CLLocationCoordinate2D)coordinate cityId:(NSString*)cityId;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, copy) NSString *temperature;

@property (nonatomic, strong) NSString *cityId;

@end
