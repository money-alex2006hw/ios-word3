//
//  CoreDataImportWords.m
//  words
//
//  Created by Marius Rott on 9/10/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "CoreDataImportWords.h"
#import "CoreDataUtils.h"
#import "Category.h"
#import "Game.h"
#import "WordStr.h"

@interface CoreDataImportWords ()
{
    NSString *_fileName;
}

- (BOOL)isFileImported:(NSString*)fileName;
- (void)setFileImported:(NSString*)fileName;

- (Category*)importCategory:(NSDictionary*)dictionary;
- (Game*)importGame:(NSDictionary*)dictionary category:(Category*)category;
- (WordStr*)importWord:(NSString*)word game:(Game*)game;

@end

@implementation CoreDataImportWords

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
    if (error) {
        return;
    }
    NSArray *categories = [json valueForKeyPath:@"categories"];
    for (NSDictionary *categoryDict in categories)
    {
        Category *category = [self importCategory:categoryDict];
        NSArray *games = [categoryDict objectForKey:@"games"];
        
        for (NSDictionary *gameDict in games)
        {
            Game *game = [self importGame:gameDict
                                 category:category];
            NSArray *words = [gameDict objectForKey:@"words"];
            
            for (NSString *wordStr in words)
            {
                WordStr *word = [self importWord:wordStr
                                            game:game];
            }
        }
    }
    NSError *error2 = nil;
    [[CoreDataUtils sharedInstance].managedObjectContext save:&error2];
    if (error2)
    {
        NSLog(error2.debugDescription);
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


- (Category*)importCategory:(NSDictionary*)dictionary
{
    Category *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category"
                                                       inManagedObjectContext:[CoreDataUtils sharedInstance].managedObjectContext];
    category.identifier = [dictionary objectForKey:@"identifier"];
    category.name = [dictionary objectForKey:@"name"];
    category.bundleID = [dictionary objectForKey:@"bundle_id"];
    return category;
}

- (Game*)importGame:(NSDictionary*)dictionary category:(Category*)category
{
    Game *game = [NSEntityDescription insertNewObjectForEntityForName:@"Game"
                                               inManagedObjectContext:[CoreDataUtils sharedInstance].managedObjectContext];
    game.identifier = [dictionary objectForKey:@"identifier"];
    game.name = [dictionary objectForKey:@"name"];
    game.category = category;
    return game;
}

- (WordStr*)importWord:(NSString*)word game:(Game*)game
{
    WordStr *wordStr = [NSEntityDescription insertNewObjectForEntityForName:@"WordStr"
                                                     inManagedObjectContext:[CoreDataUtils sharedInstance].managedObjectContext];
    wordStr.string = word;
    wordStr.game = game;
    return wordStr;
}

@end
