//
//  NSString+KtoC.m
//  Open Weather DK
//
//  Created by Lingduo Kong on 3/6/15.
//  Copyright (c) 2015 Lingduo Kong. All rights reserved.
//

#import "NSString+KtoC.h"

@implementation NSString (KtoC)
- (NSString*) KtoC {
    float fK = [self floatValue];
    fK -= 273.15;
    
    NSString *C;
    if (fK >= 0) {
        C = [NSString stringWithFormat:@"%d", (int)(fK + 0.5)];
    }
    else {
        C = [NSString stringWithFormat:@"%d", (int)(fK - 0.5)];
    }
    return C;
}

@end
