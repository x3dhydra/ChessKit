//
//  CKMutablePosition.m
//  ChessKit
//
//  Created by Austen Green on 12/10/11.
//  Copyright (c) 2011 Austen Green Consulting. All rights reserved.
//

#import "CKMutablePosition.h"
#import "CKPosition+Private.h"

@implementation CKMutablePosition

- (void)makeMove:(CKMove *)move
{
    [self makeMove:move withPosition:self];
}

- (void)unmakeMove:(CKMove *)move
{
    [self unmakeCastleMove:move withPosition:self];
}

@end
