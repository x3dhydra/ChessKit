//
//  CKPGNGameBuilderTestCase.m
//  ChessKit
//
//  Created by Austen Green on 4/28/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKPGNGameBuilderTestCase.h"
#import "CKPGNGameBuilder.h"
#import "ChessKit.h"
#import "CKFENHelper.h"
#import "CKGameFormatter.h"

@implementation CKPGNGameBuilderTestCase

- (void)testGameBuilder
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"Sample" withExtension:@"pgn"];
    NSString *gameText = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
    CKPGNGameBuilder *builder = [[CKPGNGameBuilder alloc] initWithString:gameText];
    
    CKGame *game = [builder game];
    CKPosition *position = [CKFENHelper positionWithFEN:@"8/8/4R1p1/2k3p1/1p4P1/1P1b1P2/3K1n2/8 b - - 2 43"];
    
    CKPosition *endPosition = [game endPosition];
    
    STAssertTrue([position isEqualToPosition:endPosition options:CKAbsolutePositionComparison], @"%@\nEnd Position:\n%@", position, endPosition);

}

- (void)testGameBuilderWithSetup
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"Variations" withExtension:@"pgn"];
    NSString *gameText = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
    CKPGNGameBuilder *builder = [[CKPGNGameBuilder alloc] initWithString:gameText options:CKPGNFullFormat];
    
    CKGame *game = [builder game];
    CKPosition *position = [CKFENHelper positionWithFEN:@"r5N1/ppp1kp1p/3p3p/2b1p3/2BnP3/3P1P2/PPP2P1P/R2Q3K b - - 0 14"];
    CKPosition *startPosition = [game startPosition];
    
    STAssertTrue([position isEqualToPosition:startPosition options:CKAbsolutePositionComparison], @"%@\nEnd Position:\n%@", position, startPosition);

    CKGameFormatter *formatter = [[CKGameFormatter alloc] initWithGame:game];
    NSString *gameString = [formatter gameString];
    
    NSLog(@"%@", gameString);
}

- (void)testGameFormatter
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"Variations" withExtension:@"pgn"];
    NSString *gameText = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
    CKPGNGameBuilder *builder = [[CKPGNGameBuilder alloc] initWithString:gameText options:CKPGNFullFormat];
    
    CKGame *game = [builder game];

    CKGameFormatter *formatter = [[CKGameFormatter alloc] initWithGame:game];
    NSAttributedString *string = [formatter attributedGameTree];
    
    NSLog(@"%@", string);
}

- (void)testRandom
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"moscowWC2012" withExtension:@"pgn"];
    NSString *gameText = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
    CKPGNGameBuilder *builder = [[CKPGNGameBuilder alloc] initWithString:gameText options:CKPGNFullFormat];
    
    STAssertNoThrow([builder game], nil);
}

@end
