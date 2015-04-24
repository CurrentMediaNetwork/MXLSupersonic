//
//  Copyright (c) 2015 Supersonic. All rights reserved.
//

#ifndef SUPERSONIC_H
#define SUPERSONIC_H

#import <Foundation/Foundation.h>

#import "SupersonicConfiguration.h"
#import "SupersonicGender.h"
#import "SupersonicRVDelegate.h"
#import "SupersonicOWDelegate.h"
#import "SupersonicISDelegate.h"
#import "SupersonicLogDelegate.h"

@interface Supersonic : NSObject


+ (Supersonic *)sharedInstance;

- (NSString*)getVersion;
- (void)setAge:(int)age;
- (void)setGender:(SupersonicGender)gender;

/*-----------------------------------------------*/
// Rewarded Video
/*-----------------------------------------------*/
- (void)initRVWithUserId:(NSString *)userId;
- (void)setRVDelegate:(id<SupersonicRVDelegate>) rvDelegate;
- (void)showRV;
- (BOOL)isAdAvailable;

/*-----------------------------------------------*/
// Interstitial
/*-----------------------------------------------*/
- (void)initISWithUserId:(NSString *)userId;
- (void)setISDelegate:(id<SupersonicISDelegate>) isDelegate;
- (void)showIS;
- (void)forceShowIS;
- (BOOL)isISAdAvailable;

/*-----------------------------------------------*/
// Offerwall
/*-----------------------------------------------*/
- (void)initOWWithUserId:(NSString *)userId;
- (void)setOWDelegate:(id<SupersonicOWDelegate>) owDelegate;
- (void)showOW;
- (void)getOWCredits;

/*-----------------------------------------------*/
// Logging
/*-----------------------------------------------*/
- (void)setLogDelegate:(id<SupersonicLogDelegate>) logDelegate;

@end

#endif