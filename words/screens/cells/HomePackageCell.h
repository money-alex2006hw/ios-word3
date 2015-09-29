//
//  HomePackageCell.h
//  words
//
//  Created by Marius Rott on 9/10/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomePackageCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *labelName;
@property (nonatomic, retain) IBOutlet UILabel *labelDescription;
@property (nonatomic, retain) IBOutlet UIImageView *imageViewIcon;

@end
