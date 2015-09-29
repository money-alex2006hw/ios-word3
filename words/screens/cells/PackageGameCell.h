//
//  PackageGameCell.h
//  words
//
//  Created by Marius Rott on 9/11/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PackageGameCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *labelName;
@property (nonatomic, retain) IBOutlet UIImageView *imageViewIcon;
@property (nonatomic, retain) IBOutlet UIView *viewStars;

@end
