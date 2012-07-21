//
//  CKDatabase.m
//  ChessKit
//
//  Created by Austen Green on 3/10/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKDatabase.h"
#import "CKPGNDatabase.h"

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

@end
