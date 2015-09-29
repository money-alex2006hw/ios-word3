//
//  CoreDataUtils.h
//  words
//
//  Created by Marius Rott on 9/10/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataUtils : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (CoreDataUtils*)sharedInstance;

- (NSArray*)getAllCategories;
- (NSArray*)getAllPackageBundleIDs;

@end
