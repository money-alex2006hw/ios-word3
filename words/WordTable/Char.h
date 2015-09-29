//
//  Char.h
//  word
//
//  Created by Marius Rott on 8/27/13.
//  Copyright (c) 2013 marius. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Position;

@interface Char : NSObject

@property (nonatomic, retain) NSString* string;
@property (nonatomic, retain) Position* position;
@property (nonatomic, retain) UILabel* label;

- (id)initWithString:(NSString*)string position:(Position*)position;

@end
