//
//  GameSession.m
//  words
//
//  Created by Marius Rott on 9/11/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "GameSession.h"
#import "CoreDataUtils.h"
#import "QuestManager.h"
#import "Game.h"
#import "Session.h"
#import "configuration.h"

@interface GameSession ()
{
    NSTimeInterval _timeInterval;
    id<GameSessionDelegate> _delegate;
}

@property (nonatomic, retain) NSArray *completedQuests;
@property (nonatomic, retain) NSTimer *timer;

- (void)onTimerUpdate;
- (void)writeSessionInDB;

@end

@implementation GameSession

- (id)initWithGame:(Game*)game delegate:(id<GameSessionDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.game = game;
        _delegate = delegate;
        _timeInterval = 0;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(onTimerUpdate)
                                                userInfo:nil
                                                 repeats:YES];
    }
    return self;
}

- (void)dealloc
{
    if ([self.timer isValid])
    {
        [self.timer invalidate];
    }
    [self.timer release];
    [self.game release];
    [self.completedQuests release];
    [super dealloc];
}

- (void)pause
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)resume
{
    if ([self.timer isValid])
    {
        [self.timer invalidate];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(onTimerUpdate)
                                            userInfo:nil
                                             repeats:YES];
}

- (BOOL)isPlaying
{
    if (self.timer != nil && [self.timer isValid])
    {
        return YES;
    }
    return NO;
}

- (void)gameCompleted
{
    [self.timer invalidate];
    self.timer = nil;
    
    [self writeSessionInDB];
    
    QuestManager *questManager = [[[QuestManager alloc] init] autorelease];
    self.completedQuests = [questManager getCompletedQuests];
    NSLog(@"%d completed quests", self.completedQuests.count);
    
    //  do not delete this !!!
    //  set as completed the quests from next level which meet conditions
    QuestManager *questManagerSecond = [[[QuestManager alloc] init] autorelease];
    NSArray *allreadyCompletedQuests = [questManagerSecond getCompletedQuests];
    NSLog(@"%d allready completed quests", allreadyCompletedQuests.count);
    //  //  //  //  //  //  //
}

- (BOOL)isHighscore
{
    for (Session *session in _game.sessions)
    {
        if (session.duration.intValue < _timeInterval)
        {
            return NO;
        }
    }
    return YES;
}

- (int)getHighscore
{
    int highscore = INT32_MAX;
    for (Session *session in _game.sessions)
    {
        if (session.duration.intValue < highscore)
        {
            highscore = session.duration.intValue;
        }
    }
    return highscore;
}

- (int)getSessionPoints
{
    int points = 0;
    
    float slope = (-1.0 * GAME_SESSION_MAX_POINTS) / (GAME_SESSION_ZERO_POINTS_AT);
    
    points = (slope * _timeInterval) + GAME_SESSION_MAX_POINTS;
    
    if (_timeInterval > GAME_SESSION_TIME1)
    {
        points = points - GAME_SESSION_TIME1_MINUS_P;
    }
    
    if (points < GAME_SESSION_MIN_POINTS)
    {
        points = GAME_SESSION_MIN_POINTS;
    }
    
    return points;
}

- (int)getSessionTimeInterval
{
    return _timeInterval;
}

- (NSArray *)getQuestsCompleted
{
    return self.completedQuests;
}

- (void)onTimerUpdate
{
    _timeInterval++;
    if (_delegate != nil)
    {
        [_delegate onTimeChanged:[self getTimeString:_timeInterval]];
    }
}

- (NSString *)getTimeString:(NSTimeInterval)interval
{
    if (interval == INT32_MAX)
    {
        return @"--:--";
    }
    
    NSString *time = @"";
    
    int hours = interval / 3600;
    if (hours)
    {
        time = [NSString stringWithFormat:@"%d:", hours];
    }
    
    int minutes = (interval - (hours * 3600)) / 60;
    time = [NSString stringWithFormat:@"%@%@%d:", time, minutes<10?@"0":@"", minutes];
    
    int seconds = interval - (hours * 3600) - (minutes * 60);
    time = [NSString stringWithFormat:@"%@%@%d", time, seconds<10?@"0":@"", seconds];
    return time;
}

- (void)writeSessionInDB
{
    Session *session = [NSEntityDescription insertNewObjectForEntityForName:@"Session"
                                                     inManagedObjectContext:[CoreDataUtils sharedInstance].managedObjectContext];
    session.game = _game;
    session.duration = [NSNumber numberWithInt:_timeInterval];
    session.date = [NSDate date];
    session.points = [NSNumber numberWithInt:[self getSessionPoints]];
    
    NSError *error = nil;
    [[CoreDataUtils sharedInstance].managedObjectContext save:&error];
    if (error)
    {
        NSLog(error.debugDescription);
    }
}


@end
