//
//  ImageUtils.m
//  words
//
//  Created by Marius Rott on 9/17/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import "ImageUtils.h"
#import "configuration.h"

@implementation ImageUtils

+ (UIView*)getStarImageViewForPercentage:(float)percentage
{
    if (percentage > 1.0)
    {
        percentage = 1.0;
    }
    
    int offset = 10;
    UIImage *imageStar = [UIImage imageNamed:@"yellow_star.png"];
    UIImage *imageStarGrey = [UIImage imageNamed:@"gray_star.png"];
    
    float starPercent = 1.0 / STAR_IMAGES_COUNT;
    
    
    int viewWidth = STAR_IMAGES_COUNT *imageStar.size.width + ((STAR_IMAGES_COUNT - 1) * offset);
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, imageStar.size.height)] autorelease];
    
    int fullStars = percentage / starPercent;
    int i = 0;
    for (i = 0; i < fullStars; i++)
    {
        UIImageView *background = [[[UIImageView alloc] initWithFrame:CGRectMake((i * imageStar.size.width) + (i * offset),
                                                                       0,
                                                                       imageStar.size.width,
                                                                       imageStar.size.height)] autorelease];
        background.image = imageStarGrey;
        UIImageView *starImageView = [[[UIImageView alloc] initWithImage:imageStar] autorelease];
        [background addSubview:starImageView];
        
        [view addSubview:background];
    }
    
    float lastPercent = (percentage - (fullStars * starPercent)) * STAR_IMAGES_COUNT;
    if (lastPercent || i < STAR_IMAGES_COUNT - 1)
    {
        UIImageView *background = [[[UIImageView alloc] initWithFrame:CGRectMake((fullStars * imageStar.size.width) + (fullStars * offset),
                                                                                 0,
                                                                                 imageStar.size.width,
                                                                                 imageStar.size.height)] autorelease];
        background.image = imageStarGrey;
        
        UIImageView *starImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageStar.size.width * lastPercent, imageStar.size.height)] autorelease];
        starImageView.contentMode = UIViewContentModeLeft;
        starImageView.clipsToBounds = YES;
        starImageView.image = imageStar;
        [background addSubview:starImageView];
        
        [view addSubview:background];
    }
    
    if (i < STAR_IMAGES_COUNT - 1)
    {
        for (int j = i+1; j < STAR_IMAGES_COUNT; j++)
        {
            UIImageView *background = [[[UIImageView alloc] initWithFrame:CGRectMake((j * imageStar.size.width) + (j * offset),
                                                                                     0,
                                                                                     imageStar.size.width,
                                                                                     imageStar.size.height)] autorelease];
            background.image = imageStarGrey;
            [view addSubview:background];
        }
    }
    
    return view;
}

+ (UIImage *)imageWithColor:(UIColor *)color rectSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
