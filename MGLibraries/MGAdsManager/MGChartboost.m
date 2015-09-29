//
//  MGChartboost.m
//  MGAds
//
//  Created by Marius Rott on 1/9/13.
//  Copyright (c) 2013 Marius Rott. All rights reserved.
//

#import "MGChartboost.h"

@implementation MGChartboost


- (id)init
{
    self = [super init];
    if (self)
    {
        _isAvailable = false;
        
        [Chartboost startWithAppId:MG_ADS_CHARTBOOST_APP_ID
                      appSignature:MG_ADS_CHARTBOOST_APP_SIG
                          delegate:self];
    }
    return self;
}

- (MgAdsTypeProvider)getType
{
    return MgAdsProviderChartboost;
}

- (void)fetchAds
{
    [Chartboost cacheInterstitial:CBLocationHomeScreen];
}

- (BOOL)isAvailable
{
    return _isAvailable;
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    [Chartboost showInterstitial:CBLocationHomeScreen];
}


- (BOOL)shouldRequestInterstitial:(NSString *)location
{
    return YES;
}

// Called when an interstitial has been received and cached.
- (void)didCacheInterstitial:(NSString *)location
{
    _isAvailable = true;
}

// Called when an interstitial has failed to come back from the server
- (void)didFailToLoadInterstitial:(NSString *)location
{
    //  refetch ads after 10 seconds
    int64_t delayInSeconds = MG_REFETCH_AFTER;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchAds];
    });
}

// Called when the user dismisses the interstitial
// If you are displaying the add yourself, dismiss it now.
- (void)didDismissInterstitial:(NSString *)location
{
    _isAvailable = false;
    
    //  refetch ads after 10 seconds
    int64_t delayInSeconds = MG_REFETCH_AFTER;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchAds];
    });
}

// Same as above, but only called when dismissed for a close
- (void)didCloseInterstitial:(NSString *)location
{
    _isAvailable = false;
    
    //  refetch ads after 10 seconds
    int64_t delayInSeconds = MG_REFETCH_AFTER;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchAds];
    });
}

// Same as above, but only called when dismissed for a click
- (void)didClickInterstitial:(NSString *)location
{
    _isAvailable = false;
    
    //  refetch ads after 10 seconds
    int64_t delayInSeconds = MG_REFETCH_AFTER;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchAds];
    });
}



@end
