//
//  CoreDataImportWords.h
//  words
//
//  Created by Marius Rott on 9/10/13.
//  Copyright (c) 2013 mrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataImportWords : NSObject

- (id)initWithFileName:(NSString*)fileNamed;
- (void)importFile;

@end
