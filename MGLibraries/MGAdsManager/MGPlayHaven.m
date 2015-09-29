//
//  MGPlayHaven.m
//  MGAdsManagerSample
//
//  Created by Marius Rott on 9/17/13.
//  Copyright (c) 2013 Marius Rott. All rights reserved.
//

#import "MGPlayHaven.h"

@implementation MGPlayHaven

- (id)init
{
    self = [super init];
    if (self)
    {
        _isAvailable = false;
    }
    return self;
}

- (MgAdsTypeProvider)getType
{
    return MgAdsProviderPlayHaven;
}

- (void)fetchAds
{
    
}

- (BOOL)isAvailable
{
    return NO;
    return _isAvailable;
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    //[self.interstitial showInterstitial];
}



@end
