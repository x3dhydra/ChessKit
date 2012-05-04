//
//  CKGameFormatter.h
//  ChessKit
//
//  Created by Austen Green on 5/2/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCPiece.h"

@class CKGame;

@interface CKGameFormatter : NSObject
@property (nonatomic, strong, readonly) CKGame *game;
@property (nonatomic, strong) NSString *variationStartString; // Default '['
@property (nonatomic, strong) NSString *variationEndString;   // Default ']'
@property (nonatomic, strong) NSString *commentStartString;   // Default '{'
@property (nonatomic, strong) NSString *commentEndString;     // Default '}'

- (id)initWithGame:(CKGame *)game;
- (NSString *)gameString;
- (NSAttributedString *)attributedGameTree;

- (NSString *)stringForPiece:(CCPiece)piece;
- (void)setString:(NSString *)string forPiece:(CCPiece)piece;

@end