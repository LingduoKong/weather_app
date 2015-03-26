/********************************************************************************************
 * @class_name           SharedNetworking
 * @abstract             A singleton providing networking access.
 * @description          A singleton providing networking access.
 ********************************************************************************************/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SharedNetworking : NSObject

@property NSInteger networkActivityCount;
+ (id)sharedSharedNetworking;
- (id) init;
- (void) retrieveRSSFeedForURL:(NSString*)url
                       success:(void (^)(NSMutableDictionary *dictionary, NSError *error))successCompletion
                       failure:(void (^)(void))failureCompletion;
//- (NSMutableDictionary*) returnRSSFeedForURL:(NSString*)url
//                       success:(void (^)(NSMutableDictionary *dictionary, NSError *error))successCompletion
//                       failure:(void (^)(void))failureCompletion;
- (BOOL) isNetworkAvailable;

@end
