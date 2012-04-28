//
//  CKMutablePosition.h
//  ChessKit
//
//  Created by Austen Green on 12/10/11.
//  Copyright (c) 2011 Austen Green Consulting. All rights reserved.
//

#import "CKPosition.h"

@interface CKMutablePosition : CKPosition
@property (nonatomic, readwrite, assign) CCColor sideToMove;
@property (nonatomic, readwrite, assign) CCCastlingRights castlingRights;
@property (nonatomic, readwrite, assign) CCSquare enPassantSquare;
@property (nonatomic, readwrite, assign) NSUInteger halfmoveClock;
@property (nonatomic, readwrite, assign) NSUInteger ply;

- (void)makeMove:(CKMove *)move;
- (void)unmakeMove:(CKMove *)move;

@end
