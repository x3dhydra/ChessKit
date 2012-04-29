//
//  CCSanKit.h
//  CoreChess
//
//  Created by Austen Green on 6/18/11.
//  Copyright 2011 Austen Green Consulting. All rights reserved.
//

#ifndef CCSANKIT_H
#define CCSANKIT_H
#import <Foundation/Foundation.h>

@class CKMove, CKPosition;

// SANKit - Standard Algebraic Notation Kit.  Using a CCPosition, the SANKit methods translate between
// NSString objects containing SAN representation of moves and CCMove objects
@interface CKSANHelper : NSObject {}

// Takes an NSString containing a move in standard algebraic notation and a CKPosition as context
// for the move.  Returns nil if the move is invalid or ambiguous
+ (CKMove *)moveFromString:(NSString *)san withPosition:(CKPosition *)position;

// Takes a CCMove and CCPosition as context and returns an NSString in standard algebraic notation.
// Returns nil if the move is invalid in the provided position.

+ (NSString *)stringFromMove:(CKMove *)move withPosition:(CKPosition *)position;

@end


#endif