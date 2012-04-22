//
//  CKMove.m
//  ChessKit
//
//  Created by Austen Green on 12/10/11.
//  Copyright (c) 2011 Austen Green Consulting. All rights reserved.
//

#import "CKMove.h"

@implementation CKMove
@synthesize from = _from;
@synthesize to = _to;
@synthesize promotionPiece = _promotionPiece;
@synthesize undoState = _undoState;

- (id)initWithFrom:(CCSquare)from to:(CCSquare)to
{
    self = [super init];
    if (self)
    {
        _from = from;
        _to = to;
    }
    return self;
}

+ (id)moveWithFrom:(CCSquare)from to:(CCSquare)to
{
    return [[[self class] alloc] initWithFrom:from to:to];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> from=%@ to=%@", [self class], self, CCSquareName(self.from), CCSquareName(self.to)]; 
}

@end
