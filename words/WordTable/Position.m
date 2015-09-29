//
//  Position.m
//  word
//
//  Created by Marius Rott on 8/21/13.
//  Copyright (c) 2013 marius. All rights reserved.
//

#import "Position.h"

@implementation Position

- (id)initWithX:(int)x Y:(int)y
{
    self = [super init];
    if (self)
    {
        self.x = x;
        self.y = y;
    }
    return self;
}

- (BOOL)equals:(Position *)position
{
    return self.x == position.x && self.y == position.y;
}

@end
