//
//  CKDatabase.h
//  ChessKit
//
//  Created by Austen Green on 3/10/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKGameProvider.h"

@class CKGame, CKFetchRequest;

@interface CKDatabase : NSObject <CKGameProvider>
@property (strong, nonatomic, readonly) NSURL *url;

+ (id)databaseWithContentsOfFile:(NSString *)file;
+ (id)databaseWithContentsOfURL:(NSURL *)url;

- (id)initWithContentsOfFile:(NSString *)file;
- (id)initWithContentsOfURL:(NSURL *)url;

// CKGameList methods
- (NSUInteger)count;
- (CKGame *)gameAtIndex:(NSUInteger)index;
- (NSDictionary *)metadataAtIndex:(NSUInteger)index;

- (NSArray *)filteredGamesUsingPredicate:(NSPredicate *)predicate;

- (id)executeFetchRequest:(CKFetchRequest *)fetchRequst completion:(void (^)(NSArray *matchingIndexes, CKDatabase *database))completion;
- (void)cancelSearch:(id)context;

@end
