//
//  WeatherAnnotation.h
//  Open Weather DK
//
//  Created by dongjiaming on 15/3/6.
//  Copyright (c) 2015年 Lingduo Kong. All rights reserved.
//

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
