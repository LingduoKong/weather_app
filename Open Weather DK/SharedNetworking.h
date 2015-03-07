//
//  SharedNetworking.h
//  Open Weather D.K.
//
//  Created by dongjiaming on 15/2/27.
//  Copyright (c) 2015年 The University of Chicago, Department of Computer Science. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SharedNetworking : NSObject

@property NSInteger networkActivityCount;
+ (id)sharedSharedNetworking;
- (id) init;
- (void) retrieveRSSFeedForURL:(NSString*)url
                       success:(void (^)(NSMutableDictionary *dictionary, NSError *error))successCompletion
                       failure:(void (^)(void))failureCompletion;
- (BOOL) isNetworkAvailable;

@end
