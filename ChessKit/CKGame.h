//
//  CKGame.h
//  ChessKit
//
//  Created by Austen Green on 3/10/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKPosition.h"
#import "CKGameTree.h"

typedef enum
{
    CKGameSevenTagRoster   = 0,
    CKGamePlayerAttributes = 1 << 0,
    CKGameEventAttributes  = 1 << 1,
    CKGameAttributes       = 1 << 2,
} CKGameAttributeMask;

@interface CKGame : NSObject
@property (nonatomic, strong) NSDictionary *metadata;

+ (id)game;
+ (id)gameWithStartingPosition:(CKPosition *)position;

+ (NSArray *)attributesForMask:(CKGameAttributeMask)mask;

- (id)initWithStartingPosition:(CKPosition *)position;

- (CKPosition *)startPosition;
- (CKPosition *)endPosition;

- (CKGameTree *)gameTree;

// Seven Tag Roster (STR)
- (NSString *)whitePlayer;
- (NSString *)blackPlayer;
- (NSString *)location;
- (NSDate *)date;
- (NSNumber *)whiteELO;
- (NSNumber *)blackELO;
- (NSNumber *)round;

- (NSDictionary *)metadataForKeys:(NSArray *)keys;

- (NSString *)localizedAttributeForKey:(NSString *)key;

@end

// Game metadata attribute.  Used by CKFetchRequest for potentially optimized searches

// Seven Tag Roster
extern NSString *const CKGameEventKey;
extern NSString *const CKGameSiteKey;
extern NSString *const CKGameDateKey;
extern NSString *const CKGameRoundKey;
extern NSString *const CKGameWhitePlayerKey;
extern NSString *const CKGameBlackPlayerKey;
extern NSString *const CKGameResultKey;

// Player-related tags
extern NSString * const CKGameWhiteTitleKey;
extern NSString * const CKGameBlackTitleKey;
extern NSString * const CKGameWhiteELOKey;
extern NSString * const CKGameBlackELOKey;
extern NSString * const CKGameWhiteUSCFKey;
extern NSString * const CKGameBlackUSCFKey;

// Event-related tags
extern NSString * const CKGameEventDateKey;
extern NSString * const CKGameEventSponsorKey;
extern NSString * const CKGameStageKey;
extern NSString * const CKGameBoardKey;
extern NSString * const CKGameOpeningKey;
extern NSString * const CKGameECOKey;