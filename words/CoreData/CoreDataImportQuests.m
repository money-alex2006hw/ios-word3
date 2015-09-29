//
//  CoreDataImportQuests.m
//  words
//
//  Created by Marius Rott on 9/10/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "CoreDataImportQuests.h"
#import "CoreDataUtils.h"
#import "Level.h"
#import "Quest.h"

@interface CoreDataImportQuests ()
{
    NSString *_fileName;
}

- (BOOL)isFileImported:(NSString*)fileName;
- (void)setFileImported:(NSString*)fileName;

- (Level*)importLevel:(NSDictionary*)dictionary;
- (Quest*)importQuest:(NSDictionary*)dictionary level:(Level*)level;

@end

@implementation CoreDataImportQuests

- (id)initWithFileName:(NSString *)fileNamed
{
    self = [super init];
    if (self)
    {
        _fileName = [fileNamed retain];
    }
    return self;
}

- (void)dealloc
{
    [_fileName release];
    [super dealloc];
}

- (void)importFile
{
    if ([self isFileImported:_fileName])
    {
        return;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:_fileName ofType:@"json"];
    
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:kNilOptions
                                                           error:&error];
    if (error == nil)
    {
        NSArray *levels = [json valueForKeyPath:@"levels"];
        for (NSDictionary *levelDict in levels)
        {
            Level *level = [self importLevel:levelDict];
            NSArray *quests = [levelDict objectForKey:@"quests"];
            
            for (NSDictionary *questDict in quests)
            {
                Quest *quest = [self importQuest:questDict
                                           level:level];
            }
        }
    }
    
    NSError *error2 = nil;
    [[CoreDataUtils sharedInstance].managedObjectContext save:&error2];
    if (error2)
    {
        NSLog([NSString stringWithFormat:@"%@", error2.debugDescription]);
    }
    
    [self setFileImported:_fileName];
}


- (BOOL)isFileImported:(NSString *)fileName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:fileName] != nil;
}

- (void)setFileImported:(NSString *)fileName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"imported" forKey:fileName];
    [userDefaults synchronize];
}


- (Level *)importLevel:(NSDictionary *)dictionary
{
    Level *level = [NSEntityDescription insertNewObjectForEntityForName:@"Level"
                                                 inManagedObjectContext:[CoreDataUtils sharedInstance].managedObjectContext];
    level.identifier = [dictionary objectForKey:@"identifier"];
    level.name = [dictionary objectForKey:@"name"];
    return level;
}

- (Quest *)importQuest:(NSDictionary *)dictionary level:(Level *)level
{
    Quest *quest = [NSEntityDescription insertNewObjectForEntityForName:@"Quest"
                                                 inManagedObjectContext:[CoreDataUtils sharedInstance].managedObjectContext];
    quest.identifier = [dictionary objectForKey:@"identifier"];
    quest.type = [dictionary objectForKey:@"type"];
    quest.completed = [NSNumber numberWithBool:NO];
    quest.cost = [dictionary objectForKey:@"cost"];
    quest.desc = [dictionary objectForKey:@"description"];
    quest.value = [dictionary objectForKey:@"value"];
    quest.valuetime = [dictionary objectForKey:@"valuetime"];
    quest.level = level;
    return quest;
}

@end
