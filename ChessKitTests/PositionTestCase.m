//
//  PositionTestCase.m
//  ChessKit
//
//  Created by Austen Green on 4/28/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "PositionTestCase.h"
#import "ChessKit.h"

@implementation PositionTestCase

- (void)testImmutableVSMutableEquality
{
    CKPosition *immutable = [CKPosition standardPosition];
    CKPosition *mutable = [CKMutablePosition standardPosition];
    
    STAssertEqualObjects(immutable, mutable, nil);
}

@end
