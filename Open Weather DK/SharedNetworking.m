/********************************************************************************************
 * @class_name           SharedNetworking
 * @abstract             A singleton providing networking access.
 * @description          A singleton providing networking access.
 ********************************************************************************************/

#import "SharedNetworking.h"
#import "Reachability.h"

@implementation SharedNetworking

// ----------------------------
#pragma mark - Initialization
// ----------------------------
+ (id)sharedSharedNetworking
{
    static dispatch_once_t pred;
    static SharedNetworking *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id) init
{
    if (self = [super init]) {
        
    }
    return self;
}

///------------------------------------
#pragma mark - Requests
///------------------------------------
- (void) retrieveRSSFeedForURL:(NSString*)url
                       success:(void (^)(NSMutableDictionary *dictionary, NSError *error))successCompletion
                       failure:(void (^)(void))failureCompletion
{
    if (![self isNetworkAvailable]) {
        return;
    }
    [self addNetworkActivity];
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url]
                                 completionHandler:^(NSData *data,
                                                     NSURLResponse *response,
                                                     NSError *error) {                                                            
                                     
                                     NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                                     if (httpResp.statusCode == 200) {
                                         dispatch_async(dispatch_get_main_queue(), ^{

                                         NSError *jsonError;
                                         
                                         NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                                         //NSLog(@"DownloadeData:%@ \n--- %@",dictionary);
                                         successCompletion(dictionary,nil);
                                         });
                                     } else {
                                         NSLog(@"Fail Not 200:");
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (failureCompletion) failureCompletion();
                                         });
                                     }
                                     [self removeNetworkActivity];
                                 }] resume];
}

///------------------------------------------
#pragma mark - indicate network activity
///------------------------------------------

- (void) addNetworkActivity
{
    self.networkActivityCount ++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) removeNetworkActivity
{
    if (self.networkActivityCount) {
        self.networkActivityCount --;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = (self.networkActivityCount > 0);
}

- (BOOL) isNetworkAvailable {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
//        UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Network Unavailable" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        
//        [failAlert show];
        return NO;
    } else {
        return YES;
    }
}

@end
