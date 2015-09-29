//
//  PackageGameCell.m
//  words
//
//  Created by Marius Rott on 9/11/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "PackageGameCell.h"

@implementation PackageGameCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [self.labelName release];
    [self.imageViewIcon release];
    [self.viewStars release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted)
    {
        self.imageViewIcon.image = [UIImage imageNamed:@"puzzle_sel.png"];
    }
    else
    {
        self.imageViewIcon.image = [UIImage imageNamed:@"puzzle.png"];
    }
}

@end
