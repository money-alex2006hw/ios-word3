//
//  RageIAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "MGIAPHelper.h"
#import "CoreDataUtils.h"
#import "configuration.h"

@implementation MGIAPHelper

+ (MGIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static MGIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSArray *bundlePackIDs = [[CoreDataUtils sharedInstance] getAllPackageBundleIDs];
        NSMutableSet * productIdentifiers = [NSMutableSet setWithObjects:
                                      STORE_BUNDLE_IN_APP_1,
                                      STORE_BUNDLE_IN_APP_2,
                                      STORE_BUNDLE_IN_APP_3,
                                      STORE_BUNDLE_IN_APP_4,
                                      nil];
        [productIdentifiers addObjectsFromArray:bundlePackIDs];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

+ (NSString *)priceForSKProduct:(SKProduct*)product
{
    if (!product)
    {
        return nil;
    }
    NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *price = [numberFormatter stringFromNumber:product.price];
    return price;
}


@end
