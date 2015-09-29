//
//  Word.h
//  word
//
//  Created by Marius Rott on 8/27/13.
//  Copyright (c) 2013 marius. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Char;

typedef enum DIRECTION {
    DIRECTION_E = 0,
    DIRECTION_NE,
    DIRECTION_N,
    DIRECTION_NV,
    DIRECTION_V,
    DIRECTION_SV,
    DIRECTION_S,
    DIRECTION_SE,
    DIRECTION_NULL
} Direction;

typedef enum ImageBackgroundType
{
    ImageBackgroundTypeTmp = 1,
    ImageBackgroundTypeFull
} ImageBackgroundType;

@interface Word : NSObject

@property (nonatomic, retain) NSArray *chars;
@property (nonatomic, assign) Direction direction;
@property (nonatomic, assign) bool isFound;
@property (nonatomic, retain) UIImageView *imageViewBackground;

- (id)initWithChars:(NSArray*)chars;

- (NSString*)getString;
- (void)reset;

- (void)setImgViewBackground:(ImageBackgroundType)imgType;
- (void)moveCharsToFront;

- (BOOL)equals:(Word*)word;
- (BOOL)canFit:(NSString*)string;
- (BOOL)hasCharIntersection:(NSString*)string;

@end
