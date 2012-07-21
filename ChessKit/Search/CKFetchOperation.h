//
//  CKFetchOperation.h
//  ChessKit
//
//  Created by Austen Green on 7/21/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKFetchRequest.h"
#import "CKDatabase.h"

@interface CKFetchOperation : NSOperation
@property (nonatomic, readonly) CKDatabase *database;
@property (nonatomic, readonly) CKFetchRequest *fetchRequest;
@property (nonatomic, readonly) NSArray *matchingIndexes;

- (id)initWithFetchRequest:(CKFetchRequest *)fetchRequest database:(CKDatabase *)database;

@end
