//
//  CKGameFormatter.m
//  ChessKit
//
//  Created by Austen Green on 5/2/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKGameFormatter.h"
#import "ChessKit.h"

@implementation CKGameFormatter
@synthesize game = _game;
@synthesize variationEndString = _variationEndString;
@synthesize variationStartString = _variationStartString;
@synthesize commentEndString = _commentEndString;
@synthesize commentStartString = _commentStartString;

- (id)initWithGame:(CKGame *)game
{
    self = [super init];
    if (self)
    {
        _game = game;
    }
    return self;
}

- (NSString *)gameString
{
    NSMutableString *string = [NSMutableString string];
    
    
    CKGameTree *tree = self.game.gameTree;
    if (tree.position.sideToMove == CCBlack)
        [string appendFormat:@"%d...", tree.position.moveNumber];
    
    NSLog(@"Tree before enumeration: %@", tree);
    
    while (tree.children.count) 
    {
        tree = [tree nextTree];
        CKPosition *position = tree.position;
        
        if (position.sideToMove == CCBlack)
            [string appendFormat:@"%d.", position.moveNumber];
        
        [string appendFormat:@"%@ ", tree.moveString];
    }
        
    return string;
}

- (NSAttributedString *)attributedGameTree
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    
    return string;
}


@end