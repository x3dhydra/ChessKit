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
