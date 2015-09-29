//
//  WordStr.h
//  words
//
//  Created by Marius Rott on 9/10/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Game;

@interface WordStr : NSManagedObject

@property (nonatomic, retain) NSString * string;
@property (nonatomic, retain) Game *game;

@end
