//
//  Position.h
//  word
//
//  Created by Marius Rott on 8/21/13.
//  Copyright (c) 2013 marius. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Position : NSObject

@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;

- (id)initWithX:(int)x Y:(int)y;

- (BOOL)equals:(Position*)position;

@end
