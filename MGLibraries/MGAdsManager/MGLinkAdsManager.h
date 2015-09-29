//
//  MGLinkAdsManager.h
//  Snake4iPhone
//
//  Created by marius on 6/6/13.
//  Copyright (c) 2013 DibiStore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RevMobAds/RevMobAds.h>
#import <RevMobAds/RevMobAdsDelegate.h>

@interface MGLinkAdsManager : NSObject <RevMobAdsDelegate>

@property (nonatomic, retain) RevMobAdLink *link;
@property (nonatomic, assign) BOOL isAvailable;

+ (MGLinkAdsManager*)sharedInstance;

- (void)loadAdLink;
- (void)openAdLink;
- (BOOL)isLinkAdAvailable;

@end
