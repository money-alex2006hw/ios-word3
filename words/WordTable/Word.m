//
//  Word.m
//  word
//
//  Created by Marius Rott on 8/27/13.
//  Copyright (c) 2013 marius. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Word.h"
#import "Char.h"
#import "Position.h"

@implementation Word

- (id)initWithChars:(NSArray *)chars
{
    self = [super init];
    if (self) {
        self.chars = chars;
        self.isFound = false;
        
    }
    return self;
}

- (void)dealloc
{
    [self.chars release];
    [self.imageViewBackground release];
    [super dealloc];
}

- (NSString *)getString
{
    NSString *str = @"";
    for (Char *c in self.chars)
    {
        if ([c.string caseInsensitiveCompare:@""] == NSOrderedSame)
        {
            return @"";
        }
        str = [NSString stringWithFormat:@"%@%@", str, c.string];
    }
    return str;
}

- (void)reset
{
    self.chars = nil;
    self.direction = DIRECTION_NULL;
    if (self.imageViewBackground != nil)
    {
        if (self.imageViewBackground.superview != nil)
        {
            [self.imageViewBackground removeFromSuperview];
        }
        self.imageViewBackground = nil;
    }
}

- (void)setImgViewBackground:(ImageBackgroundType)imgType
{
    UIImage *image = nil;
    if (imgType == ImageBackgroundTypeTmp)
    {
        image = [UIImage imageNamed:@"select_word_over.png"];
    }
    if (imgType == ImageBackgroundTypeFull)
    {
        image = [UIImage imageNamed:@"select_word_pressed.png"];
    }
    
    Char *chrFirst = [self.chars objectAtIndex:0];
    float charSize = chrFirst.label.frame.size.width;
    float size = (self.chars.count) * charSize;
    if (self.direction == DIRECTION_NE || self.direction == DIRECTION_NV || self.direction == DIRECTION_SE || self.direction == DIRECTION_SV)
    {
        size = size * 1.41 - charSize/2;
    }
    
    UIImage *stretchableImage = [image stretchableImageWithLeftCapWidth:charSize/2 topCapHeight:0];
    
    self.imageViewBackground = [[[UIImageView alloc] initWithFrame:CGRectMake(chrFirst.label.frame.origin.x, chrFirst.label.frame.origin.y, size, charSize)] autorelease];
    self.imageViewBackground.image = stretchableImage;
    
    self.imageViewBackground.layer.anchorPoint = CGPointMake(charSize/2/(size), 0.5);
    CALayer *l = self.imageViewBackground.layer;
    self.imageViewBackground.center = CGPointMake(l.position.x - (l.frame.size.width/2) + charSize/2, l.position.y);
    
    self.imageViewBackground.layer.transform = CATransform3DMakeRotation(-1 * M_PI * 45 * self.direction / 180.0, 0, 0, 1);
}

- (void)moveCharsToFront
{
    for (Char *chr in self.chars)
    {
        [chr.label.superview bringSubviewToFront:chr.label];
    }
}

- (BOOL)equals:(Word *)word
{
    if (self.chars.count != word.chars.count)
    {
        return false;
    }
    
    for (int i = 0; i < self.chars.count; i++)
    {
        Char *cSelf = [self.chars objectAtIndex:i];
        Char *c = [word.chars objectAtIndex:i];
        
        if (![cSelf.position equals:c.position])
        {
            return false;
        }
    }
    return true;
}

- (BOOL)canFit:(NSString *)string
{
    for (int pos = 0; pos < string.length; pos++)
    {
        Char *chr = [self.chars objectAtIndex:pos];
        NSString *c = chr.string;
        NSString *cString = [[string substringFromIndex:pos] substringToIndex:1];
        
        if ([c caseInsensitiveCompare:@""] != NSOrderedSame && [c caseInsensitiveCompare:cString] != NSOrderedSame)
        {
            return false;
        }
    }
    return true;
}

- (BOOL)hasCharIntersection:(NSString *)string
{
    for (int pos = 0; pos < string.length; pos++)
    {
        NSString *c = ((Char*)[self.chars objectAtIndex:pos]).string;
        NSString *cString = [[string substringFromIndex:pos] substringToIndex:1];
        
        if ([c caseInsensitiveCompare:@""] != NSOrderedSame && [c caseInsensitiveCompare:cString] == NSOrderedSame)
        {
            return true;
        }
    }
    return false;
}

@end
