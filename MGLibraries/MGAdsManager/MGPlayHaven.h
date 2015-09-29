//
//  MGPlayHaven.h
//  MGAdsManagerSample
//
//  Created by Marius Rott on 9/17/13.
//  Copyright (c) 2013 Marius Rott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGAdsManager.h"

@interface MGPlayHaven : NSObject <MGAdsProvider>
{
    bool _isAvailable;
}

@end
