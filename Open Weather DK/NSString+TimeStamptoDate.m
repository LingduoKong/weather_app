//
//  NSString+TimeStamptoDate.m
//  Open Weather DK
//
//  Created by kkklllddd on 3/7/15.
//  Copyright (c) 2015 Lingduo Kong. All rights reserved.
//

#import "NSString+TimeStamptoDate.h"

@implementation NSString (TimeStamptoDate)
-(NSString*)TimeStamptoDate{
    double unixTimeStamp =[self doubleValue];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"      EEE"];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

@end
