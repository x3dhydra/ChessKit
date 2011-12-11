//
//  ChessKitTests.m
//  ChessKitTests
//
//  Created by Austen Green on 11/11/11.
//  Copyright (c) 2011 Austen Green Consulting. All rights reserved.
//

#import "ChessKitTests.h"

@implementation ChessKitTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    standardPosition = [CKPosition standardPosition];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testEnPassantSquareOnFirstMove
{
    CKPosition *position = [standardPosition positionByMakingMove:[CKMove moveWithFrom:e2 to:e4]];
    STAssertEquals(position.enPassantSquare, e3, @"En passant square is wrong");
}

@end
