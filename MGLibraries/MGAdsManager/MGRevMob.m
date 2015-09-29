//
//  MGRevMob.m
//  MGAds
//
//  Created by Marius Rott on 1/7/13.
//  Copyright (c) 2013 Marius Rott. All rights reserved.
//

#import "MGRevMob.h"
#import "MGConfiguration.h"

@implementation MGRevMob

- (id)init
{
    self = [super init];
    if (self)
    {
        _isAvailable = false;
        [RevMobAds session].delegate = self;
    }
    return self;
}

- (MgAdsTypeProvider)getType
{
    return MgAdsProviderRevMob;
}

- (void)fetchAds
{
    self.interstitial = [[RevMobAds session] fullscreen];
    self.interstitial.delegate = self;
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.interstitial loadAd];
    //});
}

- (BOOL)isAvailable
{
    return _isAvailable;
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    [self.interstitial showAd];
}


/**
 Fired by Fullscreen, banner and popup. Called when the communication with the server is finished with error.
 
 @param error: contains error information.
 */
- (void)revmobAdDidFailWithError:(NSError *)error
{
    int64_t delayInSeconds = MG_REFETCH_AFTER;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchAds];
    });
}

# pragma mark Ad Callbacks (Fullscreen, Banner and Popup)

/**
 Fired by Fullscreen, banner and popup. Called when the communication with the server is finished with success.
 */
- (void)revmobAdDidReceive
{
    _isAvailable = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:MGAdsManagerNotificationAdsFinishedLoading
                                                        object:nil];
}

/**
 Fired by Fullscreen, banner and popup. Called when the Ad is displayed in the screen.
 */
- (void)revmobAdDisplayed
{
    _isAvailable = false;
}

/**
 Fired by Fullscreen, banner, button and popup.
 */
- (void)revmobUserClickedInTheAd
{
    
}

/**
 Fired by Fullscreen and popup.
 */
- (void)revmobUserClosedTheAd
{
    int64_t delayInSeconds = MG_REFETCH_AFTER;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchAds];
    });
}

@end
