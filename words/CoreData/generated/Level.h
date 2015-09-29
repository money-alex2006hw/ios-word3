//
//  Level.h
//  words
//
//  Created by Marius Rott on 9/10/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Quest;

@interface Level : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *quests;
@end

@interface Level (CoreDataGeneratedAccessors)

- (void)addQuestsObject:(Quest *)value;
- (void)removeQuestsObject:(Quest *)value;
- (void)addQuests:(NSSet *)values;
- (void)removeQuests:(NSSet *)values;

@end
