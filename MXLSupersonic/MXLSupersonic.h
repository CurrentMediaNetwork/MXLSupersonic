//
//  MXLSupersonic.h
//  InstaKeyboard
//
//  Created by kiran on 22/04/2015.
//  Copyright (c) 2015 MobileX Labs. All rights reserved.
//
//  MXLSupersonic is a neat wrapper around the SupersonicAds' iOS SDK.
//  It stores things like the state of whether the ads have been initialised etc.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const kMXLSupersonicErrorDomain;

FOUNDATION_EXPORT NSInteger const kMXLSupersonicErrorCodeNoAdsAvailable;
FOUNDATION_EXPORT NSInteger const kMXLSupersonicErrorCodeUserCancelled;

typedef NS_ENUM(NSUInteger, MXLSupersonicAdType) {
    MXLSupersonicAdTypeOfferwall,
    MXLSupersonicAdTypeRewardVideo
};

@interface MXLSupersonic : NSObject

/**
 *  A class method to return the singleton for the MXLSupersonic manager
 *
 *  @return The shared, singleton for the MXLSupersonic class.
 */

+ (instancetype)sharedInstance;

/**
 *  An instance method to set up the MXLSupersonic instance with a specific user ID.
 *
 *  @param userID The user ID who should be rewarded when ad is completed.
 */
- (void)supersonicSetUpWithUserID:(NSString *)userID;

/**
 *  The main method used to show an ad to a user.
 *  @important: `supersonicSetUpWithUserID:` must be called at some point before this method.
 *
 *  @param adType            The type of ad to be shown. This is documented in the `MXLSupersonicAdType` NS_ENUM
 *  @param completionHandler The handler called when the user has completed the offer. This could be when the user has watched the video, or downloaded an app etc. It contains the number of coins to award the user.
 *  @param failureHandler    The handler called when the ad fails to show or the user exits the ad.
 */
- (void)supersonicShowAdWithType:(MXLSupersonicAdType)adType completionHandler:(void(^)(MXLSupersonicAdType completedAdType, NSInteger coinsAwarded))completionHandler failureHandler:(void(^)(MXLSupersonicAdType failedAdType, NSError *error))failureHandler;

@end
