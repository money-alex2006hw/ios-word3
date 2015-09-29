//
//  MGRevMob.h
//  MGAds
//
//  Created by Marius Rott on 1/7/13.
//  Copyright (c) 2013 Marius Rott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGAdsManager.h"
#import <RevMobAds/RevMobAds.h>
#import <RevMobAds/RevMobAdsDelegate.h>

@interface MGRevMob : NSObject <MGAdsProvider, RevMobAdsDelegate>
{
    bool _isAvailable;
}

@property (strong, nonatomic) RevMobFullscreen* interstitial;

@end
