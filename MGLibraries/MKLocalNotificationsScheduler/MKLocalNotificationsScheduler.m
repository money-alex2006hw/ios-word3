//
//  MKLocalNotificationsScheduler.m
//  LocalNotifs
//
//  Created by Mugunth Kumar on 9-Aug-10.
//  Copyright 2010 Steinlogic. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://mugunthkumar.com
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

#import "MKLocalNotificationsScheduler.h"

#define NOTIFICATIONS_ON_KEY     @"NOTIFICATIONS_ON_KEY"
#define BADGE_COUNT_LIMIT        2

static MKLocalNotificationsScheduler *_instance;
@implementation MKLocalNotificationsScheduler

@synthesize badgeCount = _badgeCount;
+ (MKLocalNotificationsScheduler*)sharedInstance
{
	@synchronized(self) {
		
        if (_instance == nil) {
			
			// iOS 4 compatibility check
			Class notificationClass = NSClassFromString(@"UILocalNotification");
			
			if(notificationClass == nil)
			{
				_instance = nil;
			}
			else 
			{				
				_instance = [[super allocWithZone:NULL] init];				
				_instance.badgeCount = 0;
			}
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if ([userDefaults objectForKey:NOTIFICATIONS_ON_KEY])
            {
                _instance.notificationsOn = [userDefaults boolForKey:NOTIFICATIONS_ON_KEY];
            }
            else
            {
                _instance.notificationsOn = TRUE;
            }
        }
    }
    return _instance;
}


- (void)setNotificationsOn:(BOOL)notificationsOn
{
    _notificationsOn = notificationsOn;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:notificationsOn forKey:NOTIFICATIONS_ON_KEY];
    [userDefaults synchronize];
}

#pragma mark Singleton Methods

+ (id)allocWithZone:(NSZone *)zone
{	
   return [[self sharedInstance] retain];
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;	
}

- (id)retain
{	
    return self;	
}

- (unsigned)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;	
}


- (void) scheduleNotificationOn:(NSDate*) fireDate
                   repeatWeekly:(BOOL)repeat
                           text:(NSString*) alertText
                         action:(NSString*) alertAction
                          sound:(NSString*) soundfileName
                    launchImage:(NSString*) launchImage
                        andInfo:(NSDictionary*) userInfo
{
    if (!self.notificationsOn)
    {
        return;
    }
    
	UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate;
    if (repeat)
    {
        localNotification.repeatInterval = NSWeekdayCalendarUnit;
    }
    localNotification.timeZone = [NSTimeZone systemTimeZone];
	
    localNotification.alertBody = alertText;
    localNotification.alertAction = alertAction;	
	
	if(soundfileName == nil)
	{
		localNotification.soundName = UILocalNotificationDefaultSoundName;
	}
	else 
	{
		localNotification.soundName = soundfileName;
	}

	localNotification.alertLaunchImage = launchImage;
	
    if (self.badgeCount < BADGE_COUNT_LIMIT)
    {
        self.badgeCount ++;
    }
    localNotification.applicationIconBadgeNumber = self.badgeCount;
    localNotification.userInfo = userInfo;
	
	// Schedule it with the app
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [localNotification release];
}

- (void) clearBadgeCount
{
	self.badgeCount = 0;
	[UIApplication sharedApplication].applicationIconBadgeNumber = self.badgeCount;
}

- (void)removeAllNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void) decreaseBadgeCountBy:(int) count
{
	self.badgeCount -= count;
	if(self.badgeCount < 0) self.badgeCount = 0;
	
	//[UIApplication sharedApplication].applicationIconBadgeNumber = self.badgeCount;
}

- (void) handleReceivedNotification:(UILocalNotification*) thisNotification
{
	NSLog(@"Received: %@",[thisNotification description]);
	[self decreaseBadgeCountBy:1];
}

@end
