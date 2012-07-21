//
//  CKFetchRequest.h
//  ChessKit
//
//  Created by Austen Green on 7/21/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKGame.h"

// CKFetchRequest represents a query for a list of indexes of games matching a predicate.
// If the predicate property is set, an NSDictionary of metadata will be evaluated for each
// game in the database.
//
// If predicate is nil and additional predicates have been set using setPredicate:forAttribute:,
// then each predicate will be evaluated with the appropriate object (for example, CKGameWhitePlayerKey
// will be evaluated with an NSString).  The database searches may be optimized if predicates are specified
// on an attribute-by-attribue basis.

@interface CKFetchRequest : NSObject
//@property (nonatomic, strong) NSArray *sortDescriptors;
@property (nonatomic, strong) NSPredicate *predicate;

// Currently not supported
- (void)setPredicate:(NSPredicate *)predicate forAttribute:(NSString *)attribute;
- (NSPredicate *)predicateForAttribute:(NSString *)attribute;

- (NSArray *)evaluationAttributes;

@end
