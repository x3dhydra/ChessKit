//
//  CKFetchRequest.m
//  ChessKit
//
//  Created by Austen Green on 7/21/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKFetchRequest.h"

@interface CKFetchRequest()
{
    NSMutableDictionary *_predicates;
    NSPredicate *_mainPredicate;
}
@end

@implementation CKFetchRequest
@synthesize predicate = _mainPredicate;

- (void)setPredicate:(NSPredicate *)predicate forAttribute:(NSString *)attribute
{
    if (!_predicates)
        _predicates = [[NSMutableDictionary alloc] init];
    
    [_predicates setObject:predicate forKey:attribute];
}

- (NSPredicate *)predicateForAttribute:(NSString *)attribute
{
    return [_predicates objectForKey:attribute];
}

- (NSArray *)evaluationAttributes
{
    return _predicates.allKeys;
}

@end
