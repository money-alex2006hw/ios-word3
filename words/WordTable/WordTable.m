//
//  WordTableViewController.m
//  word
//
//  Created by marius on 8/5/13.
//  Copyright (c) 2013 marius. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WordTable.h"
#import "Word.h"
#import "Char.h"

@interface WordTable ()
{
    NSMutableArray *_words;
    NSMutableArray *_wordStrings;
    NSArray *_wordStringsInitial;
    
    NSMutableArray *_charTable;
    Word *_tmpWord;
    
    NSArray *_charsForRandom;
    
    id<WordTableDelegate> _delegate;
}

@property (nonatomic, retain) Position *positionStart;
@property (nonatomic, retain) Position *positionEnd;
@property (nonatomic, retain) Word *tmpWord;

- (void)resetTable;
- (void)refreshView;
- (Word*)generateWord:(NSString*)wordString;
- (void)fillEmptySpace;
- (Char*)getRandomCharForPosition:(Position*)position;
- (Word*)getWordFromPosition:(Position*)positionStart toPosition:(Position*)positionEnd;
- (Word*)getWordFromPosition:(Position*)position direction:(Direction)direction count:(int)count;
- (Direction)getDirectionFromPosition:(Position*)positionStart toPosition:(Position*)positionEnd;
- (Position*)getPositionFromPoint:(CGPoint)point;

@end

@implementation WordTable

- (id)initWithWords:(NSArray *)words delegate:(id<WordTableDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        _wordStringsInitial = [[NSArray alloc] initWithArray:words];
        _wordStrings = [[NSMutableArray alloc] initWithArray:words];
        _delegate = delegate;
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"length"
                                                      ascending:NO] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [_wordStrings sortUsingDescriptors:sortDescriptors];
        
        _words = [[NSMutableArray alloc] init];
        
        _charTable = [[NSMutableArray alloc] init];
        for (int i = 0; i < TABLE_SIZE; i++)
        {
            NSMutableArray *column = [[[NSMutableArray alloc] init] autorelease];
            [_charTable addObject:column];
        }
        
        _charsForRandom = [[NSArray alloc] initWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
    }
    return self;
}

- (void)dealloc
{
    [_words release];
    [_wordStringsInitial release];
    [_wordStrings release];
    [_charTable release];
    [_view release];
    [self.positionStart release];
    [self.positionEnd release];
    [self.tmpWord release];
    [_charsForRandom release];
    [super dealloc];
}

- (void)viewDidLoadWithSize:(CGSize)size
{
    self.view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)] autorelease];
    
    //  init words
    [self resetTable];
    
    int cellSize = size.width / TABLE_SIZE;
    
    //  set chars on screen
    for (int i = 0; i < TABLE_SIZE; i++)
    {
        for (int j = 0; j < TABLE_SIZE; j++)
        {
            NSArray *column = [_charTable objectAtIndex:i];
            Char *chr = [column objectAtIndex:j];
            chr.label = [[[UILabel alloc] initWithFrame:CGRectMake(cellSize * i, cellSize * j, cellSize, cellSize)] autorelease];
            chr.label.backgroundColor = [UIColor clearColor];
            chr.label.textAlignment = NSTextAlignmentCenter;
            chr.label.text = [chr.string uppercaseString];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                chr.label.font = [UIFont fontWithName:@"Nexa Bold" size:30];
            else
                chr.label.font = [UIFont fontWithName:@"Nexa Bold" size:15];
            
            [self.view addSubview:chr.label];
        }
    }
}

- (bool)canRemoveUnnecessaryChars:(int)charsCount
{
    NSMutableSet *tmpChars = [[[NSMutableSet alloc] init] autorelease];
    for (int i = 0; i < TABLE_SIZE; i++)
    {
        for (int j = 0; j < TABLE_SIZE; j++)
        {
            NSArray *column = [_charTable objectAtIndex:i];
            Char *chr = [column objectAtIndex:j];
            if ([chr.string caseInsensitiveCompare:@""] != NSOrderedSame)
            {
                [tmpChars addObject:chr];
            }
        }
    }
    
    for (Word *word in _words)
    {
        for (Char *c in word.chars)
        {
            [tmpChars removeObject:c];
        }
    }
    
    if (tmpChars.count >= charsCount)
        return true;
    else
        return false;
}

- (void)doRemoveUnnecessaryChars:(int)charsCount
{
    NSMutableSet *tmpChars = [[[NSMutableSet alloc] init] autorelease];
    for (int i = 0; i < TABLE_SIZE; i++)
    {
        for (int j = 0; j < TABLE_SIZE; j++)
        {
            NSArray *column = [_charTable objectAtIndex:i];
            Char *chr = [column objectAtIndex:j];
            if ([chr.string caseInsensitiveCompare:@""] != NSOrderedSame)
            {
                [tmpChars addObject:chr];
            }
        }
    }
    
    for (Word *word in _words)
    {
        for (Char *c in word.chars)
        {
            [tmpChars removeObject:c];
        }
    }
    
    for (int i = 0; i < charsCount; i++)
    {
        NSArray *allObjects = [tmpChars allObjects];
        Char *c = [allObjects objectAtIndex:arc4random() % (allObjects.count)];
        [tmpChars removeObject:c];
        
        c.label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"select_word_pressed.png"]];
        [UIView animateWithDuration:1.0 
                         animations:^{
                             c.label.transform = CGAffineTransformMakeScale(0.0, 0.0);
                         }
                         completion:^(BOOL finished) {
                             c.string = @"";
                             c.label.text = @"";
                         }];
    }
}

- (void)doWordStartCharHint
{
    Word *word;
    
    bool dobreak = false;
    for (NSString *wordStr in _wordStringsInitial)
    {
        if (dobreak)
        {
            break;
        }
        for (Word *wordTmp in _words)
        {
            if ([[wordTmp getString] caseInsensitiveCompare:wordStr] == NSOrderedSame && !wordTmp.isFound)
            {
                word = wordTmp;
                dobreak = true;
                break;
            }
        }
    }
    
    //  animate first char as for hint
    UILabel *label = ((Char*)[word.chars objectAtIndex:0]).label;
    float offset = label.frame.size.width / 5;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.15];
    [animation setRepeatCount:6];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([label center].x - offset, [label center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([label center].x + offset, [label center].y)]];
    [[label layer] addAnimation:animation forKey:@"position"];
}

- (void)doResolveGame
{
    for (Word *word in _words)
    {
        if (!word.isFound)
        {
            word.isFound = TRUE;
            [word setImgViewBackground:ImageBackgroundTypeFull];
        }
    }
    [self refreshView];
}

- (void)touchesBegan:(CGPoint)point
{
    self.positionStart = [self getPositionFromPoint:point];
    self.positionEnd = nil;
    [self.tmpWord reset];
    [self refreshView];
}

- (void)touchesCancelled:(CGPoint)point
{
    self.positionStart = nil;
    self.positionEnd = nil;
    [self.tmpWord reset];
    [self refreshView];
}

- (void)touchesEnded:(CGPoint)point
{
    self.positionEnd = [self getPositionFromPoint:point];
    
    Direction currentDirection = [self getDirectionFromPosition:self.positionStart toPosition:self.positionEnd];
    [self.tmpWord reset];
    if (currentDirection != DIRECTION_NULL)
    {
        self.tmpWord = [self getWordFromPosition:self.positionStart toPosition:self.positionEnd];
    }
    
    for (Word *word in _words)
    {
        if ([word equals:self.tmpWord])
        {
            if (!word.isFound)
            {
                word.isFound = true;
                [word setImgViewBackground:ImageBackgroundTypeFull];
                if (_delegate != nil)
                {
                    [_delegate wordTable:self foundWord:[self.tmpWord getString]];
                }
    
                bool completed = true;
                for (Word *w in _words)
                {
                    if (!w.isFound)
                    {
                        completed = false;
                    }
                }
                if (completed)
                {
                    if (_delegate != nil)
                    {
                        [_delegate wordTableCompletedGame:self];
                    }
                }
            }
        }
    }
    [self.tmpWord reset];
    if (_delegate != nil)
    {
        [_delegate wordTable:self changedTmpWord:[self.tmpWord getString]];
    }
    [self refreshView];
}

- (void)touchesMoved:(CGPoint)point
{
    if (![self.positionEnd equals:[self getPositionFromPoint:point]])
    {
        self.positionEnd = [self getPositionFromPoint:point];
        
        if (self.positionEnd.x < 0 || self.positionEnd.x >= _charTable.count || self.positionEnd.y < 0 || self.positionEnd.y >= _charTable.count)
        {
            return;
        }
        
        //  animate the char at the current point
        NSLog(@"%d %d", self.positionEnd.x, self.positionEnd.y);
        Char *chr = [[_charTable objectAtIndex:self.positionEnd.x] objectAtIndex:self.positionEnd.y];
        UILabel *label = chr.label;
        float offset = label.frame.size.width / 12;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.15];
        [animation setRepeatCount:2];
        [animation setAutoreverses:YES];
        [animation setFromValue:[NSValue valueWithCGPoint:
                                 CGPointMake([label center].x - offset, [label center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                               CGPointMake([label center].x + offset, [label center].y)]];
        [[label layer] addAnimation:animation forKey:@"position"];
        
        Direction currentDirection = [self getDirectionFromPosition:self.positionStart toPosition:self.positionEnd];
        NSLog(@"direction %d", currentDirection);
        if (currentDirection != DIRECTION_NULL)
        {
            Word *newWord = [self getWordFromPosition:self.positionStart toPosition:self.positionEnd];
            if ([self.tmpWord equals:newWord])
                return;
            [self.tmpWord reset];
            self.tmpWord = newWord;
            [self.tmpWord setImgViewBackground:ImageBackgroundTypeTmp];
            [self refreshView];
        }
        
        if (currentDirection != DIRECTION_NULL && _delegate != nil)
        {
            [_delegate wordTable:self changedTmpWord:[self.tmpWord getString]];
        }
        
    }
}

#pragma mark GAME

- (void)resetTable
{
    //[_wordPositions removeAllObjects];
    for (int i = 0; i < TABLE_SIZE; i++)
    {
        NSMutableArray *column = [[[NSMutableArray alloc] init] autorelease];
        for (int j = 0; j < TABLE_SIZE; j++)
        {
            Position *p = [[[Position alloc] initWithX:i Y:j] autorelease];
            Char *chr = [[[Char alloc] initWithString:@""
                                             position:p] autorelease];
            [column addObject:chr];
        }
        
        [_charTable replaceObjectAtIndex:i withObject:column];  //todo
    }
    
    for (NSString *wordString in _wordStrings)
    {
        Word *word = [self generateWord:wordString];
        if (word == nil)
        {
            continue;
        }
        Char *cc;
        for (int i = 0; i < word.chars.count; i++)
        {
            Char *c = [word.chars objectAtIndex:i];
            c.string = [[wordString substringFromIndex:i] substringToIndex:1];
            NSMutableArray *column = [_charTable objectAtIndex:c.position.x];
            [column replaceObjectAtIndex:c.position.y withObject:c];
            cc = c;
        }
        [_words addObject:word];
    }
    
    [self fillEmptySpace];
}

- (void)refreshView
{
    //  refresh word background images
    for (Word *word in _words)
    {
        if (word.imageViewBackground != nil)
        {
            [self.view addSubview:word.imageViewBackground];
            [word moveCharsToFront];
        }
    }
    if (self.tmpWord != nil && self.tmpWord.imageViewBackground != nil)
    {
        [self.view addSubview:self.tmpWord.imageViewBackground];
        [self.tmpWord moveCharsToFront];
    }
}

- (Word*)generateWord:(NSString *)wordString
{
    NSMutableArray *intersectionWords = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *allWords = [[[NSMutableArray alloc] init] autorelease];
    
    for (int i = 0; i < TABLE_SIZE; i++)
    {
        for (int j = 0; j < TABLE_SIZE; j++)
        {
            for (int k = 0; k < 8; k++)
            {
                Position *position = [[[Position alloc] initWithX:i Y:j] autorelease];
                Word *word = [self getWordFromPosition:position
                                             direction:(Direction)k
                                                 count:wordString.length - 1];
                
                if (word != nil)
                {
                    if ([word canFit:wordString])
                    {
                        [allWords addObject:word];
                        if ([word hasCharIntersection:wordString])
                        {
                            [intersectionWords addObject:word];
                        }
                    }
                }
            }
        }
    }
    
    if (allWords.count == 0)
        return nil;
    
    if (intersectionWords.count)
        return [intersectionWords objectAtIndex:arc4random() % (intersectionWords.count)];
    
    return [allWords objectAtIndex:arc4random() % (allWords.count)];
}

- (void)fillEmptySpace
{
    for (int i = 0; i < TABLE_SIZE; i++)
    {
        NSMutableArray *column = [_charTable objectAtIndex:i];
        for (int j = 0; j < TABLE_SIZE; j++)
        {
            Char *c = [column objectAtIndex:j];
            if ([c.string caseInsensitiveCompare:@""] == NSOrderedSame)
            {
                Position *p = [[[Position alloc] initWithX:i Y:j] autorelease];
                [column replaceObjectAtIndex:j
                                  withObject:[self getRandomCharForPosition:p]];
            }
        }
    }
}

- (Char *)getRandomCharForPosition:(Position *)position
{
    Char *c = [[[Char alloc] initWithString:[_charsForRandom objectAtIndex:arc4random() % (_charsForRandom.count)]
                                   position:position] autorelease];
    return c;
}

- (Word *)getWordFromPosition:(Position *)positionStart toPosition:(Position *)positionEnd
{
    int x1 = positionStart.x;
    int y1 = positionStart.y;
    int x2 = positionEnd.x;
    int y2 = positionEnd.y;
    int count = MAX(abs(x1-x2), abs(y1-y2));
    
    Direction d = [self getDirectionFromPosition:positionStart toPosition:positionEnd];
    return [self getWordFromPosition:positionStart direction:d count:count];
}


- (Word *)getWordFromPosition:(Position *)position direction:(Direction)direction count:(int)count
{
    int x1 = position.x;
    int y1 = position.y;
    
    int x2, y2, xSign=0, ySign=0;
    
    switch ((int)direction)
    {
        case DIRECTION_E:
            x2 = x1 + count;
            y2 = y1;
            xSign = 1; ySign = 0;
            break;
        case DIRECTION_SE:
            x2 = x1 + count;
            y2 = y1 + count;
            xSign = 1; ySign = 1;
            break;
        case DIRECTION_S:
            x2 = x1;
            y2 = y1 + count;
            xSign = 0; ySign = 1;
            break;
        case DIRECTION_SV:
            x2 = x1 - count;
            y2 = y1 + count;
            xSign = -1; ySign = 1;
            break;
        case DIRECTION_V:
            x2 = x1 - count;
            y2 = y1;
            xSign = -1; ySign = 0;
            break;
        case DIRECTION_NV:
            x2 = x1 - count;
            y2 = y1 - count;
            xSign = -1; ySign = -1;
            break;
        case DIRECTION_N:
            x2 = x1;
            y2 = y1 - count;
            xSign = 0; ySign = -1;
            break;
        case DIRECTION_NE:
            x2 = x1 + count;
            y2 = y1 - count;
            xSign = 1; ySign = -1;
            break;
    }
    
    if (x2 < 0 || x2 >= TABLE_SIZE || y2 < 0 || y2 >= TABLE_SIZE)
    {
        return nil;
    }
    
    NSMutableArray *tmpChars = [[[NSMutableArray alloc] init] autorelease];
    
    for (int i = 0; i <= count; i++)
    {
        int xi = x1+(i*xSign);
        int yi = y1+(i*ySign);
        NSArray *column = [_charTable objectAtIndex:xi];
        
        [tmpChars addObject:[column objectAtIndex:yi]];
    }
    
    Word *w = [[[Word alloc] initWithChars:tmpChars] autorelease];
    w.direction = direction;
    return w;
}

- (Direction)getDirectionFromPosition:(Position *)positionStart toPosition:(Position *)positionEnd
{
    int x1 = positionStart.x;
    int y1 = positionStart.y;
    int x2 = positionEnd.x;
    int y2 = positionEnd.y;
    int count = MAX(abs(x1-x2), abs(y1-y2));
    
    int margin;
    if (count <= 3)
    {
        margin = 0;
    }
    else
    {
        margin = 1;
    }
    
    Direction direction = DIRECTION_NULL;
    
//    if (abs(x1-x2) > margin && abs(y1-y2) > margin )    //&& abs(x1-x2) != abs(y1-y2) )
//    {
//        return direction;
//    }
    
    if (x2 == x1 && y2 == y1)
    {
        return DIRECTION_E; //  todo: direction E for same char
    }
    
    if (abs(x2 - (x1 + count)) <= margin && abs(y2 - y1) <= margin)
    {
        direction = DIRECTION_E;
    }
    if (abs(x2 - (x1 + count)) <= margin && abs(y2 - (y1 + count)) <= margin)
    {
        direction = DIRECTION_SE;
    }
    if (abs(x2 - x1) <= margin && abs(y2 - (y1 + count)) <= margin)
    {
        direction = DIRECTION_S;
    }
    if (abs(x2 - (x1 - count)) <= margin && abs(y2 - (y1 + count)) <= margin)
    {
        direction = DIRECTION_SV;
    }
    if (abs(x2 - (x1 - count)) <= margin && abs(y2 - y1) <= margin)
    {
        direction = DIRECTION_V;
    }
    if (abs(x2 - (x1 - count)) <= margin && abs(y2 - (y1 - count)) <= margin)
    {
        direction = DIRECTION_NV;
    }
    if (abs(x2 - x1) <= margin && abs(y2 - (y1 - count)) <= margin)
    {
        direction = DIRECTION_N;
    }
    if (abs(x2 - (x1 + count)) <= margin && abs(y2 - (y1 - count)) <= margin)
    {
        direction = DIRECTION_NE;
    }
    return direction;
}

#pragma mark -

- (Position *)getPositionFromPoint:(CGPoint)point
{
    int cellSize = self.view.frame.size.width / TABLE_SIZE;
    int x = point.x / cellSize;
    int y = point.y / cellSize;
    if (x < 0)
    {
        x = 0;
    }
    if (x >= TABLE_SIZE)
    {
        x = TABLE_SIZE - 1;
    }
    if (y < 0)
    {
        y = 0;
    }
    if (y >= TABLE_SIZE)
    {
        y = TABLE_SIZE - 1;
    }
    return [[[Position alloc] initWithX:x Y:y] autorelease];
}


@end
