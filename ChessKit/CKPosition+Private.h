//
//  CKPosition+Private.h
//  CoreChess
//
//  Created by Austen Green on 12/10/11.
//  Copyright (c) 2011 Austen Green Consulting. All rights reserved.
//

#import "CoreChess.h"
#import "CKPosition.h"
@class CKPosition, CKMove;

@interface CKPosition (Private)

@property (nonatomic, readwrite, assign) CCCastlingRights castlingRights;
@property (nonatomic, readwrite, assign) CCSquare enPassantSquare;
@property (nonatomic, readwrite, assign) CCColor sideToMove;
@property (nonatomic, readwrite, assign) NSInteger halfmoveClock;
@property (nonatomic, readwrite, assign) NSInteger ply;
@property (nonatomic, readwrite, assign) BOOL requiresPromotion;


- (void)makeMove:(CKMove *)move withPosition:(CKPosition *)position;
- (void)makeSaveStateForMove:(CKMove *)move;
- (void)makeRookMove:(CKMove *)move withPosition:(CKPosition *)position;
- (void)makeKingMove:(CKMove *)move withPosition:(CKPosition *)position;
- (void)makePawnMove:(CKMove *)move withPosition:(CKPosition *)position;
- (void)makeCastleMove:(CKMove *)move withPosition:(CKPosition *)position;

- (void)unmakeMove:(CKMove *)move withPosition:(CKPosition *)position;
- (void)unmakeSaveStateForMove:(CKMove *)move withPosition:(CKPosition *)position;
- (void)unmakeCastleMove:(CKMove *)move withPosition:(CKPosition *)position;

- (BOOL)isMovePseudoLegal:(CKMove *)move;

- (void)promotePosition:(CKPosition *)position withMove:(CKMove *)move;

@end