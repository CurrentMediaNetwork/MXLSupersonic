//
//  MXLSupersonic.m
//  InstaKeyboard
//
//  Created by kiran on 22/04/2015.
//  Copyright (c) 2015 MobileX Labs. All rights reserved.
//

#import "MXLSupersonic.h"

@import UIKit;

// Framework imports
#import <Supersonic/Supersonic.h>

NSString * const kMXLSupersonicErrorDomain = @"com.mobilexlabs.MXLErrorDomain";
NSInteger const kMXLSupersonicErrorCodeNoAdsAvailable = -1;
NSInteger const kMXLSupersonicErrorCodeUserCancelled  = -2;

@interface MXLSupersonic () <SupersonicOWDelegate, SupersonicRVDelegate>

@property (strong, nonatomic, readwrite) NSMutableArray *initializedAdTypes;

@property (nonatomic, copy) void (^completionBlock)(MXLSupersonicAdType, NSInteger);
@property (nonatomic, copy) void (^failureBlock)(MXLSupersonicAdType, NSError *);
@property (nonatomic, copy) void (^initializationSuccessBlock)(MXLSupersonicAdType);

@property (strong, nonatomic, readwrite) NSString *userID;

@property (strong, nonatomic, readwrite) NSTimer *offerwallTimer;

- (void)showAdWithType:(MXLSupersonicAdType)adType;

- (BOOL)isAdTypeInitialized:(MXLSupersonicAdType)adType;
- (void)initializeAdType:(MXLSupersonicAdType)adType withSuccessHandler:(void(^)(MXLSupersonicAdType))success;

- (void)getOfferwallCredits;

@end

@implementation MXLSupersonic

- (instancetype)init {
    self = [super init];

    if (self) {
        [[Supersonic sharedInstance] setRVDelegate:self];
        [[Supersonic sharedInstance] setOWDelegate:self];
        
        self.initializedAdTypes = [NSMutableArray array];
    }
    
    return self;
}

+ (instancetype)sharedInstance {
    static MXLSupersonic *sharedInstance = nil;
    
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:nil] init];
    }
    
    return sharedInstance;
    
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

- (void)supersonicSetUpWithUserID:(NSString *)userID {
    self.userID = userID;
    
    [[Supersonic sharedInstance] initOWWithUserId:userID];
    [[Supersonic sharedInstance] initRVWithUserId:userID];
}

- (void)getOfferwallCredits {
    [[Supersonic sharedInstance] getOWCredits];
}

- (void)supersonicShowAdWithType:(MXLSupersonicAdType)adType completionHandler:(void (^)(MXLSupersonicAdType, NSInteger))completionHandler failureHandler:(void (^)(MXLSupersonicAdType, NSError *))failureHandler {
    [self initializeAdType:adType withSuccessHandler:^(MXLSupersonicAdType intialisedAdType) {
        self.completionBlock = completionHandler;
        self.failureBlock    = failureHandler;
        
        [self showAdWithType:adType];
    }];
}

- (void)showAdWithType:(MXLSupersonicAdType)adType {
    switch (adType) {
        case MXLSupersonicAdTypeOfferwall:
            [[Supersonic sharedInstance] showOW];
            [self.offerwallTimer invalidate];
            self.offerwallTimer = nil;
            self.offerwallTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(getOfferwallCredits) userInfo:nil repeats:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
            break;
        case MXLSupersonicAdTypeRewardVideo:
            [[Supersonic sharedInstance] showRV];
            break;
        default:
            break;
    }
}

- (void)appDidEnterForeground:(NSNotification *)notification {
    UIAlertView *foregroundAlertView = [[UIAlertView alloc] initWithTitle:@"Thanks for installing!"
                                                                  message:@"If you've installed and opened the app, please wait here for a moment! We'll let you know when your install has been confirmed."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"Dismiss"
                                                        otherButtonTitles:nil, nil];
    [foregroundAlertView show];
}

#pragma mark - Initialization methods

- (BOOL)isAdTypeInitialized:(MXLSupersonicAdType)adType {
    for (NSNumber *item in self.initializedAdTypes) {
        if ([item integerValue] == adType) {
            return YES;
        }
    }
    
    return NO;
}

- (void)initializeAdType:(MXLSupersonicAdType)adType withSuccessHandler:(void (^)(MXLSupersonicAdType))success {
    
    // If the ad type is alreadu initialized, jump back.
    if ([self isAdTypeInitialized:adType]) {
        if (success) {
            success(adType);
        }
        
        return;
    }
    
    self.initializationSuccessBlock = success;
    
    switch (adType) {
        case MXLSupersonicAdTypeOfferwall:
            [[Supersonic sharedInstance] initOWWithUserId:self.userID];
            break;
        case MXLSupersonicAdTypeRewardVideo:
            [[Supersonic sharedInstance] initRVWithUserId:self.userID];
            break;
        default:
            break;
    }
}

#pragma mark - SupersonicOWDelegate

- (void)supersonicOWInitSuccess {
    [self.initializedAdTypes addObject:[NSNumber numberWithInteger:MXLSupersonicAdTypeOfferwall]];
    
    if (self.initializationSuccessBlock) {
        self.initializationSuccessBlock(MXLSupersonicAdTypeOfferwall);
    }
}

- (void)supersonicOWInitFailedWithError:(NSError *)error {
    if (self.failureBlock) {
        self.failureBlock(MXLSupersonicAdTypeOfferwall, error);
    }
}

- (void)supersonicOWShowSuccess {}

- (void)supersonicOWShowFailedWithError:(NSError *)error {
    if (self.failureBlock) {
        self.failureBlock(MXLSupersonicAdTypeOfferwall, error);
    }
}

- (BOOL)supersonicOWDidReceiveCredit:(NSDictionary *)creditInfo {
    if ([[creditInfo objectForKey:@"credits"] integerValue] > 0) {
        [self.offerwallTimer invalidate];
        self.offerwallTimer = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self];

        if (self.completionBlock) {
            self.completionBlock(MXLSupersonicAdTypeOfferwall, [[creditInfo objectForKey:@"credits"] integerValue]);
        }
    }
    
    return TRUE;
}

- (void)supersonicOWFailGettingCreditWithError:(NSError *)error {
    [self.offerwallTimer invalidate];
    self.offerwallTimer = nil;
    
    if (self.failureBlock) {
        self.failureBlock(MXLSupersonicAdTypeOfferwall, error);
    }
}

- (void)supersonicOWAdClosed {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - SupersonicRVDelegate

- (void)supersonicRVInitSuccess {
    [self.initializedAdTypes addObject:[NSNumber numberWithInteger:MXLSupersonicAdTypeRewardVideo]];
    
    if (self.initializationSuccessBlock) {
        self.initializationSuccessBlock(MXLSupersonicAdTypeRewardVideo);
    }
}

- (void)supersonicRVInitFailedWithError:(NSError *)error {
    if (self.failureBlock) {
        self.failureBlock(MXLSupersonicAdTypeRewardVideo, error);
    }
}

- (void)supersonicRVAdAvailabilityChanged:(BOOL)hasAvailableAds {
    if (!hasAvailableAds) {
        if (self.failureBlock) {
            self.failureBlock(MXLSupersonicAdTypeRewardVideo, [NSError errorWithDomain:kMXLSupersonicErrorDomain
                                                                                   code:kMXLSupersonicErrorCodeNoAdsAvailable
                                                                               userInfo:@{NSLocalizedDescriptionKey: @"Unfortunately there are no ads available at this time."}]);
        }
    }
}

- (void)supersonicRVAdOpened {}

- (void)supersonicRVAdFailedWithError:(NSError *)error {
    if (self.failureBlock) {
        self.failureBlock(MXLSupersonicAdTypeRewardVideo, error);
    }
}

- (void)supersonicRVAdStarted {}

- (void)supersonicRVAdRewarded:(NSInteger)amount {
    if (self.completionBlock) {
        self.completionBlock(MXLSupersonicAdTypeRewardVideo, amount);
    }
}

- (void)supersonicRVAdEnded {
    
}

- (void)supersonicRVAdClosed {
    if (self.failureBlock) {
        self.failureBlock(MXLSupersonicAdTypeRewardVideo, [NSError errorWithDomain:kMXLSupersonicErrorDomain
                                                                              code:kMXLSupersonicErrorCodeUserCancelled
                                                                          userInfo:@{NSLocalizedDescriptionKey: @"Please make sure you watch the whole video."}]);
    }
}

@end
