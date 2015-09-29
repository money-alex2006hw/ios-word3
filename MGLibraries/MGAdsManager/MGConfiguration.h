//
//  MGConfiguration.h
//  MGAds
//
//  Created by Marius Rott on 11/23/12.
//  Copyright (c) 2012 Marius Rott. All rights reserved.
//

#import <Foundation/Foundation.h>

#define     MG_ADS_REVMOB_APP_ID        @"REVMOB_APP_ID"
#define     MG_ADS_CHARTBOOST_APP_ID    @"CHARTBOOST_APP_ID"
#define     MG_ADS_CHARTBOOST_APP_SIG   @"CHARTBOOST_APP_SIG"


#define     MG_REFETCH_AFTER            30

#define     MG_APP_AD_MIN_DISPLAY       1
#define     MG_APP_AD_SECONDS_BETWEEN   90


typedef enum
{
    MgAdsProviderRevMob = 1,
    MgAdsProviderChartboost,
    MgAdsProviderPlayHaven,
} MgAdsTypeProvider;

#define     MG_ADS_PROVIDER_ORDER_1     MgAdsProviderChartboost
#define     MG_ADS_PROVIDER_ORDER_2     MgAdsProviderRevMob
#define     MG_ADS_PROVIDER_ORDER_3     MgAdsProviderPlayHaven
#define     MG_ADS_NUM_PROVIDERS        4

