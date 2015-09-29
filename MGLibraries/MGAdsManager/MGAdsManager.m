//
//  MGAdsManager.m
//  MGAds
//
//  Created by Marius Rott on 11/23/12.
//  Copyright (c) 2012 Marius Rott. All rights reserved.
//

#import "MGAdsManager.h"
#import "MGRevMob.h"
#import "MGChartboost.h"
#import "MGPlayHaven.h"

#define MG_ADS_LOCK_UNLOCK_KEY      @"MG_ADS_LOCK_UNLOCK_KEY"

@implementation MGAdsManager

+ (MGAdsManager *)sharedInstance
{
    static MGAdsManager *instance;
    if (instance == nil)
    {
        instance = [[MGAdsManager alloc] init];
    
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _numOfDisplays = 0;
        _showAdsLocked = false;
    }
    return self;
}

- (void)dealloc
{
    if (self.mgAdPlayHaven)
        [self.mgAdPlayHaven release];
    if (self.mgAdRevMob)
        [self.mgAdRevMob release];
    if (self.mgAdChartboost)
        [self.mgAdChartboost release];
    if (self.mgAdAppLovin)
        [self.mgAdAppLovin release];
    [self.rootView release];
    [super dealloc];
}

- (void)startAdsManager
{
    //  for more games feature. It starts allways.
    self.mgAdChartboost = [[[MGChartboost alloc] init] autorelease];
    if (![self isAdsEnabled])
    {
        //  disable ads purchased
        return;
    }
    self.mgAdRevMob = [[[MGRevMob alloc] init] autorelease];
    self.mgAdPlayHaven = [[[MGPlayHaven alloc] init] autorelease];
    
    [self fetchAds];
}

- (void)fetchAds
{
    [[self getProviderForType:MG_ADS_PROVIDER_ORDER_1] fetchAds];
    [[self getProviderForType:MG_ADS_PROVIDER_ORDER_2] fetchAds];
    [[self getProviderForType:MG_ADS_PROVIDER_ORDER_3] fetchAds];
}

- (BOOL)isAvailable
{
    if (![self isAdsEnabled])
    {
        return NO;
    }
    if (_showAdsLocked)
    {
        return NO;
    }
    if (    [[self getProviderForType:MG_ADS_PROVIDER_ORDER_1] isAvailable] ||
            [[self getProviderForType:MG_ADS_PROVIDER_ORDER_2] isAvailable] ||
            [[self getProviderForType:MG_ADS_PROVIDER_ORDER_3] isAvailable] )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)displayAdInViewController:(UIViewController *)viewController
{
    if (![self isAvailable])
    {
        
        return false;
    }
    
    if ([self.mgAdChartboost respondsToSelector:@selector(setRootView:)])
    {
        [self.mgAdChartboost setRootView:self.rootView];
    }
    
    //  type 1
    if ([[self getProviderForType:MG_ADS_PROVIDER_ORDER_1] isAvailable])
    {
        [[self getProviderForType:MG_ADS_PROVIDER_ORDER_1] showAdFromViewController:viewController];
        [self unlockShowAdsAfterInterval];
        _numOfDisplays++;
        return true;
    }
    //  type 2
    if ([[self getProviderForType:MG_ADS_PROVIDER_ORDER_2] isAvailable])
    {
        [[self getProviderForType:MG_ADS_PROVIDER_ORDER_2] showAdFromViewController:viewController];
        [self unlockShowAdsAfterInterval];
        _numOfDisplays++;
        return true;
    }
    //  type 3
    if ([[self getProviderForType:MG_ADS_PROVIDER_ORDER_3] isAvailable])
    {
        [[self getProviderForType:MG_ADS_PROVIDER_ORDER_3] showAdFromViewController:viewController];
        [self unlockShowAdsAfterInterval];
        _numOfDisplays++;
        return true;
    }
    return false;
}

- (id<MGAdsProvider>)getProviderForType:(MgAdsTypeProvider)providerType
{
    switch (providerType)
    {
        case MgAdsProviderPlayHaven:
            return self.mgAdPlayHaven;
        case MgAdsProviderRevMob:
            return self.mgAdRevMob;
        case MgAdsProviderChartboost:
            return self.mgAdChartboost;
        default:
            nil;
    }
}


- (BOOL)isAdsEnabled
{
    //  PRO VERSION HAS ADS DISABLED
#ifndef FREE_VERSION
    return false;
#endif
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:MG_ADS_LOCK_UNLOCK_KEY] != NULL)
    {
        return [[NSUserDefaults standardUserDefaults] boolForKey:MG_ADS_LOCK_UNLOCK_KEY];
    }
    return TRUE;
}

- (void)disableAds
{
    NSLog(@"Ads disabled .... ");
    
    [[NSUserDefaults standardUserDefaults] setBool:false
                                            forKey:MG_ADS_LOCK_UNLOCK_KEY];
}

- (void)unlockShowAdsAfterInterval
{
    _showAdsLocked = true;
    
    int64_t delayInSeconds = MG_APP_AD_SECONDS_BETWEEN;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _showAdsLocked = false;
    });
}

@end
