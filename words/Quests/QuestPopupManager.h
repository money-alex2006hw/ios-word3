//
//  QuestPopupManager.h
//  words
//
//  Created by Marius Rott on 9/13/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QuestPopupView;
@class LevelPopupView;

@interface QuestPopupManager : NSObject

@property (nonatomic, retain) IBOutlet QuestPopupView *viewPopupQuest;
@property (nonatomic, retain) IBOutlet LevelPopupView *viewPopupLevel;

@property (nonatomic, retain) UINib *viewLoaderQuest;
@property (nonatomic, retain) UINib *viewLoaderLevel;

- (IBAction)doButtonPopupOK:(id)sender;

- (id)initWithFinishedQuests:(NSArray*)quests inView:(UIView*)view;
- (void)showPopups;

@end
