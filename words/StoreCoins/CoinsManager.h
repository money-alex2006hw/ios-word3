//
//  CoinsManager.h
//  words
//
//  Created by Marius Rott on 9/11/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoinsManager : NSObject

+ (CoinsManager*)sharedInstance;

- (int)getCoins;
- (void)addCoins:(int)coins;
- (BOOL)substractCoins:(int)coins;

- (int)getVideoViews;
- (BOOL)substractVideoViews;

@end
