//
//  PositionTestCase.m
//  ChessKit
//
//  Created by Austen Green on 4/28/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "PositionTestCase.h"
#import "ChessKit.h"
#import "CKPGNGameBuilder.h"

@implementation PositionTestCase

- (void)testImmutableVSMutableEquality
{
    CKPosition *immutable = [CKPosition standardPosition];
    CKPosition *mutable = [CKMutablePosition standardPosition];
    
    STAssertEqualObjects(immutable, mutable, nil);
}

- (void)testBlackEnPassant
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestBlackEnPassant" withExtension:@"pgn"];
	CKDatabase *database = [CKDatabase databaseWithContentsOfURL:url];
	CKGame *game = [database gameAtIndex:1];
}

- (void)testSANHelperEnPassant
{
	// En passant was failing at one point if there was also an opposing pawn defending the en-passant square from the same file
	// because the disambiguation candidates were being set to all pawns instead of just the side-to-move's pawns.
	CKMutablePosition *position = [[CKMutablePosition alloc] init];
	CCMutableBoardRef board = [position board];
	CCBoardSetSquareWithPiece(board, a1, WK);
	CCBoardSetSquareWithPiece(board, a8, BK);
	CCBoardSetSquareWithPiece(board, h7, BP);
	CCBoardSetSquareWithPiece(board, g5, BP);
	CCBoardSetSquareWithPiece(board, h5, WP);
	position.enPassantSquare = g6;
	position.sideToMove = CCWhite;
	
	CKMove *move = [CKSANHelper moveFromString:@"hxg6" withPosition:position];
	STAssertTrue(move.from != InvalidSquare, @"Could not generate hxg6 with position: %@", position);
}

- (void)testPinnedDisambiguation
{
    // The following game fails on pinned disambiguation on Black's 18th move.  TODO: Look into this
	NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"pinnedDisambiguation" withExtension:@"pgn"];
	NSString *gameText = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	CKPGNGameBuilder *gameBuilder = [[CKPGNGameBuilder alloc] initWithString:gameText];
	CKGame *game = [gameBuilder game];
}

@end
