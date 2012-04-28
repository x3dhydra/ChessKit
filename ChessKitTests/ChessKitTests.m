//
//  ChessKitTests.m
//  ChessKitTests
//
//  Created by Austen Green on 11/11/11.
//  Copyright (c) 2011 Austen Green Consulting. All rights reserved.
//

#import "ChessKitTests.h"
#import "CKGameTree.h"
#import "CKFENHelper.h"

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

- (void)testGameTree
{
    CKGameTree *tree = [[CKGameTree alloc] initWithPosition:[CKPosition standardPosition]];
    CKGameTree *root = tree;
    
    CKMove *move = [CKMove moveWithFrom:e2 to:e4];
    //NSLog(@"%@", move);
    [tree addMove:[CKMove moveWithFrom:e2 to:e4]];
    tree = [tree nextTree];
    
    [tree addMove:[CKMove moveWithFrom:c7 to:c5]];
    tree = [tree nextTree];

    [tree addMove:[CKMove moveWithFrom:g1 to:f3]];
    tree = [tree nextTree];
    
    for (CKGameTree *gameTree in [root mainLineEnumerator])
    {
        //NSLog(@"%@", [gameTree position]);
    }
    
    //NSLog(@"%@", [tree position]);
}

- (void)testDatabaseLength
{
    __block NSURL *url = nil;
    
    [[NSBundle allBundles] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        url = [obj URLForResource:@"twic910" withExtension:@"pgn"];
        if (url)
            *stop = YES;
    }];
    
    CKDatabase *database = [CKDatabase databaseWithContentsOfURL:url];
    STAssertTrue(database.count == 1908, @"Database count = %d", database.count);
}

@end
