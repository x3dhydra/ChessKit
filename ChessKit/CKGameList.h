//
//  CKGameList.h
//  ChessKit
//
//  Created by Austen Green on 5/27/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKGameProvider.h"

@interface CKGameList : NSObject <CKGameProvider>

- (void)filterUsingPredicate:(NSPredicate *)predicate;
- (void)sortUsingDescriptors:(NSArray *)sortDescriptors;

@end
