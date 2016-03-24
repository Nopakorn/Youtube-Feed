//
//  DataController.h
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 3/23/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataController : NSObject

@property (strong) NSManagedObjectContext *managedObjectContext;

- (void)initializeCoreData;

@end
