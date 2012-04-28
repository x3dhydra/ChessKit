//
//  FENTestCase.m
//  ChessKit
//
//  Created by Austen Green on 4/28/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "FENTestCase.h"

@implementation FENTestCase

- (void)testStartPosition
{
    NSString *fen = @"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
    CKPosition *position = [CKFENHelper positionWithFEN:fen];
    STAssertEqualObjects(position, [CKPosition standardPosition], @"Position is not standard position: %@", position);
}

- (void)testFirstMoves
{
    NSString *fen = @"rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1";
    CKPosition *position = [CKFENHelper positionWithFEN:fen];
    
    CKMutablePosition *testPosition = [CKMutablePosition standardPosition];
    [testPosition makeMove:[CKMove moveWithFrom:e2 to:e4]];
    STAssertEqualObjects(position, testPosition, nil);
    
    fen = @"rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2";
    position = [CKFENHelper positionWithFEN:fen];
    [testPosition makeMove:[CKMove moveWithFrom:c7 to:c5]];
    STAssertTrue([position isEqualToPosition:testPosition options:CKAbsolutePositionComparison],  @"Position is not equal after 1... c5 - %@\n\n%@", position, testPosition);
}

@end
