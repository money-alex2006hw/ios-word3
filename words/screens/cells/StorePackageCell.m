//
//  HomePackageCell.m
//  words
//
//  Created by Marius Rott on 9/10/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "StorePackageCell.h"

@implementation StorePackageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}

- (void)dealloc
{
    [self.labelName release];
    [self.labelDescription release];
    [self.imageViewIcon release];
    [self.labelPrice release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
//{
//    if (highlighted)
//    {
//        self.imageViewIcon.image = [UIImage imageNamed:@"packages_sel.png"];
//    }
//    else
//    {
//        self.imageViewIcon.image = [UIImage imageNamed:@"packages.png"];
//    }
//}

@end
