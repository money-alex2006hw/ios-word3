//
//  SoundUtils.h
//  Snake4iPhone
//
//  Created by marius on 5/11/13.
//  Copyright (c) 2013 DibiStore. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    SoundTypeBack = 1,
    SoundTypeCoinsAdded,
    SoundTypeFoundWord,
    SoundTypeStartTmpWord,
    SoundTypeClickOnButton,
    SoundTypeGameFinished,
    SoundTypeHint,
    SoundTypeRemoveChars,
    SoundTypeQuestCompleted     //  same as game finished
    
} SOUND_TYPE;

@interface SoundUtils : NSObject

@property (nonatomic, assign) BOOL soundOn;

+ (SoundUtils*)sharedInstance;

- (void)removeAllPlayingSounds;
- (void)playMusic:(SOUND_TYPE)soundType;
- (void)playSoundEffect:(SOUND_TYPE)soundType;

- (BOOL)isPlaying;

@end
