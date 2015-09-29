//
//  MGChartboost.h
//  MGAds
//
//  Created by Marius Rott on 1/9/13.
//  Copyright (c) 2013 Marius Rott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGAdsManager.h"

#import <Chartboost/Chartboost.h>
#import <Chartboost/CBNewsfeed.h>
#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>

@interface MGChartboost : NSObject <MGAdsProvider, ChartboostDelegate>
{
    bool _isAvailable;
}

@property (strong, nonatomic) Chartboost* interstitial;

@end
