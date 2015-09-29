//
//  QuestManager.h
//  words
//
//  Created by Marius Rott on 9/11/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Quest;

@interface QuestManager : NSObject

- (NSArray*)getCompletedQuests;

- (float)getQuestCompletionPercentage:(Quest*)quest;

@end
