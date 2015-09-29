//
//  Char.m
//  word
//
//  Created by Marius Rott on 8/27/13.
//  Copyright (c) 2013 marius. All rights reserved.
//

#import "Char.h"
#import "Position.h"

@implementation Char

- (id)initWithString:(NSString *)string position:(Position *)position
{
    self = [super init];
    if (self)
    {
        self.string = string;
        self.position = position;
    }
    return self;
}

- (void)dealloc
{
    [self.string release];
    [self.position release];
    [self.label release];
    [super dealloc];
}

@end
