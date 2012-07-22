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

- (NSString *)localizedAttributeForKey:(NSString *)key
{
    return NSLocalizedStringFromTable(key, @"PGNTags", nil);
}

#pragma mark - Attributes

+ (NSArray *)attributesForMask:(CKGameAttributeMask)mask
{
    if (mask == CKGameSevenTagRoster)
    {
        return [NSArray arrayWithObjects:
                CKGameEventKey, 
                CKGameSiteKey, 
                CKGameDateKey, 
                CKGameRoundKey,
                CKGameWhitePlayerKey,
                CKGameBlackPlayerKey,
                CKGameResultKey,
                nil];
    }
    
    NSMutableArray *attributes = [NSMutableArray array];
    if (mask & CKGamePlayerAttributes)
    {
        [attributes addObjectsFromArray:
         [NSArray arrayWithObjects:
          CKGameWhitePlayerKey,
          CKGameWhiteELOKey,
          CKGameWhiteTitleKey,
          CKGameWhiteUSCFKey,
          CKGameBlackPlayerKey,
          CKGameBlackELOKey,
          CKGameBlackTitleKey,
          CKGameBlackUSCFKey,
          nil]];
    }
    if (mask & CKGameEventAttributes)
    {
        [attributes addObjectsFromArray:
         [NSArray arrayWithObjects:
          CKGameEventKey,
          CKGameSiteKey,
          CKGameEventDateKey,
          CKGameEventSponsorKey,
          CKGameStageKey,
          nil]];
    }
    if (mask & CKGameAttributes)
    {
        [attributes addObjectsFromArray:
         [NSArray arrayWithObjects:
          CKGameRoundKey,
          CKGameResultKey,
          CKGameECOKey,
          CKGameOpeningKey,
          CKGameBoardKey,
          nil]];
    }
    
    return attributes;
}

- (NSDictionary *)metadataForKeys:(NSArray *)keys
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [keys enumerateObjectsUsingBlock:^(NSString * key, NSUInteger idx, BOOL *stop) {
        id value = [self.metadata objectForKey:key];
        if (value)
            [dictionary setObject:value forKey:key];
    }];
    
    return dictionary;
}

@end

NSString *const CKGameEventKey = @"Event";
NSString *const CKGameSiteKey = @"Site";
NSString *const CKGameDateKey = @"Date";
NSString *const CKGameRoundKey = @"Round";
NSString *const CKGameWhitePlayerKey = @"White";
NSString *const CKGameBlackPlayerKey = @"Black";
NSString *const CKGameResultKey = @"Result";

NSString * const CKGameWhiteTitleKey = @"WhiteTitle";
NSString * const CKGameBlackTitleKey = @"BlackTitle";
NSString * const CKGameWhiteELOKey = @"WhiteElo";
NSString * const CKGameBlackELOKey = @"BlackElo";
NSString * const CKGameWhiteUSCFKey = @"WhiteUSCF";
NSString * const CKGameBlackUSCFKey = @"BlackUSCF";

NSString * const CKGameEventDateKey = @"EventDate";
NSString * const CKGameEventSponsorKey = @"EventSponsor";
NSString * const CKGameStageKey = @"Stage";
NSString * const CKGameBoardKey = @"Board";
NSString * const CKGameOpeningKey = @"Opening";
NSString * const CKGameECOKey = @"ECO";