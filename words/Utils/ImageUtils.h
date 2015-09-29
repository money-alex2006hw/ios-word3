//
//  ImageUtils.h
//  words
//
//  Created by Marius Rott on 9/17/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtils : NSObject

+ (UIView*)getStarImageViewForPercentage:(float)percentage;

+ (UIImage *)imageWithColor:(UIColor *)color rectSize:(CGSize)size;

@end
