//
//  AppDelegate.m
//  words
//
//  Created by Marius Rott on 9/4/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "CoreDataUtils.h"
#import "CoreDataImportWords.h"
#import "CoreDataImportQuests.h"
#import "SoundUtils.h"
#import "GameKitHelper.h"
#import "MGIAPHelper.h"
#import "MGAdsManager.h"
#import "MGLinkAdsManager.h"

#import <RevMobAds/RevMobAds.h>
#import "MGShare.h"
#import "MKLocalNotificationsScheduler.h"
#import "configuration.h"
#import "Appirater.h"


#import <Chartboost/Chartboost.h>
#import <Chartboost/CBNewsfeed.h>
#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    [super dealloc];
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //  start revmob
    [RevMobAds startSessionWithAppID:MG_ADS_REVMOB_APP_ID];
    [[MGAdsManager sharedInstance] startAdsManager];
    
    [Chartboost cacheMoreApps:CBLocationHomeScreen];
    [Appirater appLaunched];
    
    //[[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
    [self customizeMGShare];
    
    [SoundUtils sharedInstance];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    [CoreDataUtils sharedInstance].managedObjectContext = self.managedObjectContext;
    
    //  import words1.json
    CoreDataImportWords *importWords = [[[CoreDataImportWords alloc] initWithFileName:@"words1"] autorelease];
    [importWords importFile];
    //  import quests1.json
    CoreDataImportQuests *importQuests = [[[CoreDataImportQuests alloc] initWithFileName:@"quests1"] autorelease];
    [importQuests importFile];
    
    HomeViewController *homeViewController = [[[HomeViewController alloc] init] autorelease];
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:homeViewController] autorelease];
    self.navigationController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navigationController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[MGLinkAdsManager sharedInstance] loadAdLink];
    [self localNotificationsSetup];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}



#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"words1" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"words1.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)localNotificationsSetup
{
    //  remove all notifications & clear badge count
    [[MKLocalNotificationsScheduler sharedInstance] clearBadgeCount];
    [[MKLocalNotificationsScheduler sharedInstance] removeAllNotifications];
    
    NSString *message1 = @"notification message 1";
    NSString *message2 = @"notification message 2";
    NSString *message3 = @"notification message 3";
    NSString *message4 = @"notification message 4";
    NSString *message5 = @"notification message 5";
    NSString *message6 = @"notification message 6";
    
    NSMutableArray *arrayAll = [[[NSMutableArray alloc] init] autorelease];
    [arrayAll addObject:[NSArray arrayWithObjects:message1, message2, message4, message6, nil]];
    [arrayAll addObject:[NSArray arrayWithObjects:message4, message5, message1, message6, nil]];
    [arrayAll addObject:[NSArray arrayWithObjects:message2, message5, message3, message6, nil]];
    [arrayAll addObject:[NSArray arrayWithObjects:message3, message1, message4, message6, nil]];
    [arrayAll addObject:[NSArray arrayWithObjects:message5, message2, message1, message6, nil]];
    [arrayAll addObject:[NSArray arrayWithObjects:message4, message2, message5, message6, nil]];
    
    NSArray *messages = [arrayAll objectAtIndex:arc4random() % (arrayAll.count)];
    
    for (int i = 0; i < messages.count; i++)
    {
        [[MKLocalNotificationsScheduler sharedInstance] scheduleNotificationOn:[NSDate dateWithTimeIntervalSinceNow:60*60*24*(i+1)]
                                                                  repeatWeekly:NO
                                                                          text:[messages objectAtIndex:i]
                                                                        action:@"View"
                                                                         sound:nil
                                                                   launchImage:nil
                                                                       andInfo:nil];
    }
}

- (void)customizeMGShare
{
    [MGShare sharedInstance].stringTitle = @"Share Title";
    [MGShare sharedInstance].stringURL = @"bit.ly share link";
    [MGShare sharedInstance].stringPathToLocalImage = @"Icon@2x.png";
}

@end
