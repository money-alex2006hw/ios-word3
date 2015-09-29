//
//  MGLinkAdsManager.m
//  Snake4iPhone
//
//  Created by marius on 6/6/13.
//  Copyright (c) 2013 DibiStore. All rights reserved.
//

#import "MGLinkAdsManager.h"

@implementation MGLinkAdsManager

+ (MGLinkAdsManager *)sharedInstance
{
    static MGLinkAdsManager *instance;
    if (instance == nil)
    {
        instance = [[MGLinkAdsManager alloc] init];
        instance.isAvailable = FALSE;
    }
    return instance;
}

- (void)dealloc
{
    [self.link release];
    [super dealloc];
}

- (void)loadAdLink
{
    self.link = [[RevMobAds session] adLink];
    [self.link loadWithSuccessHandler:^(RevMobAdLink *link) {
        [self revmobAdDidReceive];
    } andLoadFailHandler:^(RevMobAdLink *link, NSError *error) {
        [self revmobAdDidFailWithError:error];
    }];
}

- (void)openAdLink
{
    if (self.link) [self.link openLink];
}

- (BOOL)isLinkAdAvailable
{
    return self.isAvailable;
}

#pragma mark - RevMobAdsDelegate methods

- (void)revmobAdDidReceive {
    self.isAvailable = TRUE;
    NSLog(@"[RevMob Sample App] LINK Ad loaded.");
}

- (void)revmobAdDidFailWithError:(NSError *)error {
    self.isAvailable = FALSE;
    NSLog(@"[RevMob Sample App] LINK Ad failed: %@", error);
}

- (void)revmobAdDisplayed {
    NSLog(@"[RevMob Sample App] Ad displayed.");
}

- (void)revmobUserClosedTheAd {
    NSLog(@"[RevMob Sample App] User clicked in the close button.");
}

- (void)revmobUserClickedInTheAd {
    NSLog(@"[RevMob Sample App] User clicked in the Ad.");
}

- (void)installDidReceive {
    NSLog(@"[RevMob Sample App] Install did receive.");
}

- (void)installDidFail {
    NSLog(@"[RevMob Sample App] Install did fail.");
}

#pragma mark - Others

@end
