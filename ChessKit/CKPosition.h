//
//  CKPosition.h
//  ChessKit
//
//  Created by Austen Green on 12/10/11.
//  Copyright (c) 2011 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreChess.h"

@class CKMove;

@interface CKPosition : NSObject <NSCopying, NSMutableCopying>
@property (nonatomic, readonly) CCMutableBoardRef board;
@property (nonatomic, readonly, assign) CCCastlingRights castlingRights;
@property (nonatomic, readonly, assign) CCSquare enPassantSquare;
@property (nonatomic, readonly, assign) CCColor sideToMove;
@property (nonatomic, readonly, assign) NSInteger halfmoveClock;
@property (nonatomic, readonly, assign) NSInteger ply;
@property (nonatomic, readonly, assign) BOOL requiresPromotion;

+ (id)position;         // Returns an empty position
+ (id)standardPosition; // Returns the standard starting position
+ (id)positionWithPosition:(CKPosition *)position; // Performs a deep copy of the position

- (id)initWithStandardPosition;
- (id)initWithPosition:(CKPosition *)position; // Performs a deep copy of the position
- (id)initWithFEN:(NSString *)FENString;  // Position from Forscythe-Edwards Notation.  Returs nil if the string is invalid

// Making Moves
- (CKPosition *)positionByMakingMove:(CKMove *)move;
- (CKPosition *)positionByUnmakingMove:(CKMove *)move;
- (BOOL)isMoveLegal:(CKMove *)move;

// State
- (CCColoredPiece)coloredPieceAtSquare:(CCSquare)square;

- (BOOL)inCheck:(CCColor)color;  // Returns YES if the king for color is in check.

// Comparison
- (BOOL)isEqual:(id)object;
- (BOOL)isEqualToPosition:(CKPosition *)position;

@end
