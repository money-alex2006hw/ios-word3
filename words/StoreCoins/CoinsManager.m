//
//  CoinsManager.m
//  words
//
//  Created by Marius Rott on 9/11/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "CoinsManager.h"
#import "configuration.h"

#define KEY_COINS       @"KEY_COINS_DEFAULTS"
#define KEY_VIDEOS      @"KEY_VIDEOS_DEFAULTS"

@interface CoinsManager ()

- (void)setCoins:(int)coins;

@end

@implementation CoinsManager

+ (CoinsManager *)sharedInstance
{
    static CoinsManager *instance = nil;
    if (instance == nil)
    {
        instance = [[CoinsManager alloc] init];
    }
    return instance;
}

- (id)init
{
    self = [super init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:KEY_COINS] == nil)
    {
        [userDefaults setInteger:COINS_START_DEFAULT forKey:KEY_COINS];
    }
    if ([userDefaults objectForKey:KEY_VIDEOS] == nil)
    {
        [userDefaults setInteger:COINS_VIDEO_MIN_VIEWS forKey:KEY_VIDEOS];
    }
    [userDefaults synchronize];
    return self;
}

- (void)dealloc
{
    
    [super dealloc];
}

- (int)getCoins
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:KEY_COINS];
}

- (void)addCoins:(int)coins
{
    [self setCoins:[self getCoins] + coins];
}

- (BOOL)substractCoins:(int)coins
{
    if ([self getCoins] < coins)
    {
        return NO;
    }
    [self setCoins:[self getCoins] - coins];
    return YES;
}

- (void)setCoins:(int)coins
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:coins forKey:KEY_COINS];
    [defaults synchronize];
}

- (int)getVideoViews
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:KEY_VIDEOS];
}

- (BOOL)substractVideoViews
{
    int views = [self getVideoViews];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (views == 1)
    {
        [defaults setInteger:COINS_VIDEO_MIN_VIEWS forKey:KEY_VIDEOS];
        [defaults synchronize];
        return YES;
    }
    else
    {
        [defaults setInteger:views-1 forKey:KEY_VIDEOS];
        [defaults synchronize];
        return NO;
    }
}

@end
