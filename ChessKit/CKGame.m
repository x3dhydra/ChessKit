//
//  CKGame.m
//  ChessKit
//
//  Created by Austen Green on 3/10/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKGame.h"
#import "CKGameTree.h"

@interface CKGame()
{
    NSMutableDictionary *_metadata;
    CKGameTree *_gameTree;
}

@end

@implementation CKGame
@synthesize metadata = _metadata;

+ (id)game
{
    return [self gameWithStartingPosition:nil];
}

+ (id)gameWithStartingPosition:(CKPosition *)position
{
    return [[self alloc] initWithPosition:position];
}

- (id)initWithStartingPosition:(CKPosition *)position
{
    self = [super init];
    if (self)
    {
        if (!position)
            position = [CKPosition standardPosition];
        
        _gameTree = [[CKGameTree alloc] initWithPosition:position];
    }
    return self;
}

- (void)setMetadata:(NSDictionary *)metadata
{
    _metadata = [NSMutableDictionary dictionaryWithDictionary:metadata];
}

- (NSDictionary *)metadata
{
    if (!_metadata)
        _metadata = [NSMutableDictionary dictionary];
    return _metadata;
}

- (CKPosition *)startPosition
{
    return [self.gameTree position];
}

- (CKPosition *)endPosition
{
    return [[self.gameTree endOfLine] position];
}

- (CKGameTree *)gameTree
{
    return _gameTree;
}

@end

NSString *const CKGameEventKey = @"Event";
NSString *const CKGameSiteKey = @"Site";
NSString *const CKGameDateKey = @"Date";
NSString *const CKGameRoundKey = @"Round";
NSString *const CKGameWhitePlayerKey = @"White";
NSString *const CKGameBlackPlayerKey = @"Black";
NSString *const CKGameResultKey = @"Result";