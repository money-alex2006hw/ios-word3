//
//  LevelPopupView.m
//  words
//
//  Created by Marius Rott on 9/13/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "LevelPopupView.h"

@implementation LevelPopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [self.viewPopup release];
    [self.labelTitle release];
    [self.labelQuest release];
    [self.labelButtonOK release];
    [self.buttonOK release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
