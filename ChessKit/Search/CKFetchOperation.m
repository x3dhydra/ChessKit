//
//  CKFetchOperation.m
//  ChessKit
//
//  Created by Austen Green on 7/21/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKFetchOperation.h"

static const NSInteger kCKCancelIncrement = 25;  // Check for cancellation

@interface CKFetchOperation()
{
    NSMutableArray *_matchingIndexes;
}
@end

@implementation CKFetchOperation
@synthesize fetchRequest = _fetchRequest;
@synthesize database = _database;

- (id)initWithFetchRequest:(CKFetchRequest *)fetchRequest database:(CKDatabase *)database
{
    self = [super init];
    if (self)
    {
        _fetchRequest = fetchRequest;
        _database = database;
    }
    return self;
}

- (void)main
{
    _matchingIndexes = [[NSMutableArray alloc] init];
    
    if (self.fetchRequest.predicate)
    {
        [self executeNonOptimizedSearch];
    }
}

- (void)executeNonOptimizedSearch
{
    NSPredicate *predicate = self.fetchRequest.predicate;
    NSUInteger count = self.database.count;
    
    @autoreleasepool 
    {
        for (NSUInteger index = 0; index < count; index++)
        {
            @autoreleasepool 
            {
                if (index % kCKCancelIncrement == 0 && [self isCancelled])
                    break;
                
                NSDictionary *metadata = [self.database metadataAtIndex:index];
                if ([predicate evaluateWithObject:metadata])
                {
                    [_matchingIndexes addObject:[NSNumber numberWithUnsignedInteger:index]];
                }
            }
        }
    }
    
}

- (NSArray *)matchingIndexes
{
    return _matchingIndexes;
}

@end
