//
//  CKDatabase.m
//  ChessKit
//
//  Created by Austen Green on 3/10/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKDatabase.h"
#import "CKPGNDatabase.h"
#import "CKFetchOperation.h"
#import "CKFetchRequest.h"

@interface CKDatabase()
{
    NSOperationQueue *_searchQueue;
}
@end

@implementation CKDatabase
@synthesize url = _url;

+ (id)databaseWithContentsOfFile:(NSString *)file
{
    return [self databaseWithContentsOfURL:[NSURL fileURLWithPath:file]];
}

+ (id)databaseWithContentsOfURL:(NSURL *)url
{
    Class databaseClass = NULL;
    
    if ([[url pathExtension] caseInsensitiveCompare:@"pgn"] == NSOrderedSame)
    {
        databaseClass = [CKPGNDatabase class];
    }
    
    if (databaseClass)
    {
        id database = [(CKDatabase *)[databaseClass alloc] initWithContentsOfURL:url];
        return database;
    }
    else
        return nil;
}

- (id)initWithContentsOfFile:(NSString *)file
{
    return [self initWithContentsOfURL:[NSURL fileURLWithPath:file]];
}

- (id)initWithContentsOfURL:(NSURL *)url
{
    self = [super init];
    if (self)
    {
        _url = url;
    }
    return self;
}

- (NSUInteger)count
{
    [NSException raise:NSGenericException format:@"%@ must be implemented in a concrete subclass", NSStringFromSelector(_cmd)];
    return 0;
}

- (NSString *)title
{
    return [[self.url lastPathComponent] stringByDeletingPathExtension];
}

- (CKGame *)gameAtIndex:(NSUInteger)index
{
    [NSException raise:NSGenericException format:@"%@ must be implemented in a concrete subclass", NSStringFromSelector(_cmd)];
    return nil;
}

- (NSDictionary *)metadataAtIndex:(NSUInteger)index
{
    [NSException raise:NSGenericException format:@"%@ must be implemented in a concrete subclass", NSStringFromSelector(_cmd)];
    return nil;
}

#pragma mark - Search

- (NSIndexSet *)filteredGamesUsingPredicate:(NSPredicate *)predicate
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < self.count; i++)
    {
        NSDictionary *dictionary = [self metadataAtIndex:i];
        if ([predicate evaluateWithObject:dictionary])
            [array addObject:[NSNumber numberWithUnsignedInteger:i]];
    }
    
    return array;
}

- (id)executeFetchRequest:(CKFetchRequest *)fetchRequst completion:(void (^)(NSArray *matchingIndexes, CKDatabase *database))completion
{
    CKFetchOperation *operation = [[CKFetchOperation alloc] initWithFetchRequest:fetchRequst database:self];
    completion = [completion copy];
    
    __weak CKFetchOperation *weakOperation = operation;
    [operation setCompletionBlock:^{
        if (!weakOperation.isCancelled)
        {
            completion([weakOperation matchingIndexes], self);
        }
    }];
    
    dispatch_async(dispatch_get_current_queue(), ^{
        [[self searchQueue] addOperation:operation];
    });
    
    return operation;
}

- (void)cancelSearch:(id)context
{
    CKFetchOperation *operation = (CKFetchOperation *)context;
    [operation cancel];
}

- (NSOperationQueue *)searchQueue
{
    if (!_searchQueue)
    {
        _searchQueue = [[NSOperationQueue alloc] init];
    }
    return _searchQueue;
}

@end
