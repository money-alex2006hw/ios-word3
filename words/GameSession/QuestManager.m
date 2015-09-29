//
//  QuestManager.m
//  words
//
//  Created by Marius Rott on 9/11/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "QuestManager.h"
#import "CoreDataUtils.h"
#import "configuration.h"
#import "Quest.h"
#import "Level.h"
#import "Session.h"
#import "Game.h"

#define QUEST_TYPE_1    1   //  complete value different sessions in under valuetime each
#define QUEST_TYPE_2    2   //  complete value consecutive sessions in under valuetime
#define QUEST_TYPE_3    3   //  complete value games

@interface QuestManager ()

- (NSArray*)getCurrentQuests;

- (BOOL)checkType1:(Quest*)quest;   //  check if Quest is completed. If it is, set completed=YES
- (BOOL)checkType2:(Quest*)quest;   //
- (BOOL)checkType3:(Quest*)quest;   //

- (float)getType1Completion:(Quest*)quest;  //  get 0-1 float with completion percentage
- (float)getType2Completion:(Quest*)quest;  //
- (float)getType3Completion:(Quest*)quest;  //

@end

@implementation QuestManager

- (NSArray*)getCompletedQuests
{
    NSArray *quests = [self getCurrentQuests];
    NSMutableArray *completedQuests = [[[NSMutableArray alloc] init] autorelease];
    for (Quest *quest in quests)
    {
        if (quest.completed.boolValue == NO)
        {
            if (quest.type.intValue == QUEST_TYPE_1)
            {
                BOOL completed = [self checkType1:quest];
                if (completed)
                {
                    NSLog(@"completed quest 1 value %d value time %d", quest.value.intValue, quest.valuetime.intValue);
                    [completedQuests addObject:quest];
                }
            }
            if (quest.type.intValue == QUEST_TYPE_2)
            {
                BOOL completed = [self checkType2:quest];
                if (completed)
                {
                    NSLog(@"completed quest 2 value %d value time %d", quest.value.intValue, quest.valuetime.intValue);
                    [completedQuests addObject:quest];
                }
            }
            if (quest.type.intValue == QUEST_TYPE_3)
            {
                BOOL completed = [self checkType3:quest];
                if (completed)
                {
                    NSLog(@"completed quest 3 value %d value time %d", quest.value.intValue, quest.valuetime.intValue);
                    [completedQuests addObject:quest];
                }
            }
        }
    }
    return completedQuests;
}

- (float)getQuestCompletionPercentage:(Quest *)quest
{
    if (quest.completed.boolValue == YES)
    {
        return 1.0;
    }
    float completion = 0.0;
    if (quest.type.intValue == QUEST_TYPE_1)
    {
        completion = [self getType1Completion:quest];
    }
    if (quest.type.intValue == QUEST_TYPE_2)
    {
        completion = [self getType2Completion:quest];
    }
    if (quest.type.intValue == QUEST_TYPE_3)
    {
        completion = [self getType3Completion:quest];
    }
    if (completion > 1.0)
        completion = 1.0;
    return completion;
}

- (NSArray *)getCurrentQuests
{
    NSFetchRequest *requestQuests = [[[NSFetchRequest alloc] initWithEntityName:@"Quest"] autorelease];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completed == NO"];
    [requestQuests setPredicate:predicate];
    NSSortDescriptor *sortDescriptorID = [[[NSSortDescriptor alloc] initWithKey:@"identifier"
                                                                     ascending:YES] autorelease];
    requestQuests.sortDescriptors = [NSArray arrayWithObjects:sortDescriptorID, nil];
    NSError *error2 = nil;
    NSArray *quests = [[CoreDataUtils sharedInstance].managedObjectContext executeFetchRequest:requestQuests error:&error2];
    if (!error2)
    {
        if (quests.count)
        {
            quests = [((Quest*)[quests objectAtIndex:0]).level.quests allObjects];
            quests = [quests sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptorID]];
        }
    }
    return quests;
}

- (BOOL)checkType1:(Quest*)quest
{
    NSFetchRequest *requestQuests = [[[NSFetchRequest alloc] initWithEntityName:@"Session"] autorelease];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"duration <= %@", quest.valuetime];
    [requestQuests setPredicate:predicate];
    NSError *error2 = nil;
    NSArray *sessions = [[CoreDataUtils sharedInstance].managedObjectContext executeFetchRequest:requestQuests error:&error2];
    if (!error2)
    {
        if (sessions.count && sessions.count >= quest.value.intValue)
        {
            //  completed quest
            quest.completed = [NSNumber numberWithBool:YES];
            NSError *error3 = nil;
            [[CoreDataUtils sharedInstance].managedObjectContext save:&error3];
            if (error3)
            {
                NSLog(error3.debugDescription);
                return NO;
            }
            return YES;
        }
    }
    return NO;
}

- (BOOL)checkType2:(Quest*)quest
{
    NSFetchRequest *requestSessions = [[[NSFetchRequest alloc] initWithEntityName:@"Session"] autorelease];
    NSSortDescriptor *sortDescriptorID = [[[NSSortDescriptor alloc] initWithKey:@"date"
                                                                     ascending:NO] autorelease];
    requestSessions.sortDescriptors = [NSArray arrayWithObjects:sortDescriptorID, nil];
    [requestSessions setFetchLimit:quest.value.intValue];
    NSError *error2 = nil;
    NSArray *sessions = [[CoreDataUtils sharedInstance].managedObjectContext executeFetchRequest:requestSessions error:&error2];
    if (!error2)
    {
        if (sessions.count < quest.value.intValue)
        {
            return NO;
        }
        for (Session *session in sessions)
        {
            if (session.duration.intValue > quest.valuetime.intValue)
            {
                return NO;
            }
        }
        
        //  completed quest
        quest.completed = [NSNumber numberWithBool:YES];
        NSError *error3 = nil;
        [[CoreDataUtils sharedInstance].managedObjectContext save:&error3];
        if (error3)
        {
            NSLog(error3.debugDescription);
            return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)checkType3:(Quest*)quest
{
    NSFetchRequest *requestGames = [[[NSFetchRequest alloc] initWithEntityName:@"Game"] autorelease];
    NSError *error2 = nil;
    NSArray *games = [[CoreDataUtils sharedInstance].managedObjectContext executeFetchRequest:requestGames error:&error2];
    if (!error2)
    {
        int count = 0;
        for (Game *game in games)
        {
            NSNumber *sum = [game.sessions valueForKeyPath:@"@sum.points"];
            if (sum.intValue >= GAME_TOTAL_POINTS)
            {
                count++;
            }
        }
        
        if (count >= quest.value.intValue)
        {
            //  completed quest
            quest.completed = [NSNumber numberWithBool:YES];
            NSError *error3 = nil;
            [[CoreDataUtils sharedInstance].managedObjectContext save:&error3];
            if (error3)
            {
                NSLog(error3.debugDescription);
                return NO;
            }
            return YES;
        }
    }
    return NO;
}

- (float)getType1Completion:(Quest *)quest
{
    NSFetchRequest *requestQuests = [[[NSFetchRequest alloc] initWithEntityName:@"Session"] autorelease];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"duration <= %@", quest.valuetime];
    [requestQuests setPredicate:predicate];
    NSError *error2 = nil;
    NSArray *sessions = [[CoreDataUtils sharedInstance].managedObjectContext executeFetchRequest:requestQuests error:&error2];
    if (!error2)
    {
        return sessions.count / quest.value.floatValue;
    }
    return 0.0;
}

- (float)getType2Completion:(Quest *)quest
{
    NSFetchRequest *requestSessions = [[[NSFetchRequest alloc] initWithEntityName:@"Session"] autorelease];
    NSSortDescriptor *sortDescriptorID = [[[NSSortDescriptor alloc] initWithKey:@"date"
                                                                     ascending:NO] autorelease];
    requestSessions.sortDescriptors = [NSArray arrayWithObjects:sortDescriptorID, nil];
    [requestSessions setFetchLimit:quest.value.intValue];
    NSError *error2 = nil;
    NSArray *sessions = [[CoreDataUtils sharedInstance].managedObjectContext executeFetchRequest:requestSessions error:&error2];
    if (!error2)
    {
        float count = 0.0;
        for (Session *session in sessions)
        {
            if (session.duration.intValue > quest.valuetime.intValue)
            {
                return 0.0;
            }
            else
            {
                count++;
            }
        }
        return count / quest.value.floatValue;
    }
    return 0.0;
}

- (float)getType3Completion:(Quest *)quest
{
    NSFetchRequest *requestGames = [[[NSFetchRequest alloc] initWithEntityName:@"Game"] autorelease];
    NSError *error2 = nil;
    NSArray *games = [[CoreDataUtils sharedInstance].managedObjectContext executeFetchRequest:requestGames error:&error2];
    if (!error2)
    {
        float count = 0.0;
        for (Game *game in games)
        {
            NSNumber *sum = [game.sessions valueForKeyPath:@"@sum.points"];
            if (sum.intValue >= GAME_TOTAL_POINTS)
            {
                count++;
            }
        }
        return count / quest.value.floatValue;
    }
    return 0.0;
}

@end
