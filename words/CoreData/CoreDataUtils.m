//
//  CoreDataUtils.m
//  words
//
//  Created by Marius Rott on 9/10/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "CoreDataUtils.h"
#import "Category.h"

@interface CoreDataUtils ()
{
    NSArray *_categories;
}
@end

@implementation CoreDataUtils

+ (CoreDataUtils *)sharedInstance
{
    static CoreDataUtils *instance;
    if (instance == nil)
    {
        instance = [[CoreDataUtils alloc] init];
    }
    return instance;
}

- (void)dealloc
{
    [self.managedObjectContext release];
    [super dealloc];
}

- (NSArray *)getAllCategories
{
    if (_categories)
    {
        return _categories;
    }
    NSSortDescriptor *sortDescriptorID = [[[NSSortDescriptor alloc] initWithKey:@"identifier"
                                                                      ascending:YES] autorelease];
    
    NSFetchRequest *requestCategory = [[[NSFetchRequest alloc] initWithEntityName:@"Category"] autorelease];
    requestCategory.sortDescriptors = [NSArray arrayWithObjects:sortDescriptorID, nil];
    NSError *error1 = nil;
    _categories = [self.managedObjectContext executeFetchRequest:requestCategory error:&error1];
    return _categories;
}

- (NSArray *)getAllPackageBundleIDs
{
    NSArray *categs = [self getAllCategories];
    NSMutableArray *bundleIDs = [[[NSMutableArray alloc] init] autorelease];
    for (Category *categ in categs)
    {
        [bundleIDs addObject:categ.bundleID];
    }
    return bundleIDs;
}

@end
