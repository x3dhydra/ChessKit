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

@interface CKGame : NSObject
@property (nonatomic, strong) NSDictionary *metadata;

+ (id)game;
+ (id)gameWithStartingPosition:(CKPosition *)position;

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

@end

extern NSString *const CKGameEventKey;
extern NSString *const CKGameSiteKey;
extern NSString *const CKGameDateKey;
extern NSString *const CKGameRoundKey;
extern NSString *const CKGameWhitePlayerKey;
extern NSString *const CKGameBlackPlayerKey;
extern NSString *const CKGameResultKey;
