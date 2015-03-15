#import "NSString+KtoC.h"

@implementation NSString (KtoC)

/********************************************************************************************
 * @method           KtoC
 * @abstract         converter function
 * @description      convert the temperature from Kelvin to degree centigrade.
 ********************************************************************************************/

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
