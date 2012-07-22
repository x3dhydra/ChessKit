//
//  CKPGNDatabaseTestCase.m
//  ChessKit
//
//  Created by Austen Green on 5/19/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKPGNDatabaseTestCase.h"
#import "ChessKit.h"
#import "CKPGNMetadataScanner.h"

@implementation CKPGNDatabaseTestCase

- (void)testSquareBracketInGameText
{
    // Tests the database count when there is a square bracket which appears as the first 
    // character in a line within the movetext block of a game.
    
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"moscowWC2012" withExtension:@"pgn"];
    CKDatabase *database = [CKDatabase databaseWithContentsOfURL:url];
    
    STAssertTrue(database.count == 1, @"Database count is %d", database.count);    
}

- (void)testDatabaseLength
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"twic910" withExtension:@"pgn"];
    CKDatabase *database = [CKDatabase databaseWithContentsOfURL:url];

    STAssertTrue(database.count == 1908, @"Database count = %d", database.count);
}

- (void)testMetadataScanner
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"moscowWC2012" withExtension:@"pgn"];
    NSString *gameText = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    CKPGNMetadataScanner *scanner = [[CKPGNMetadataScanner alloc] initWithGameText:gameText];
    [scanner metadata];
}

@end
