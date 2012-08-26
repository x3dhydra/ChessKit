//
//  CKPieceList.h
//  ChessKit
//
//  Created by Austen Green on 8/26/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreChess.h"

@interface CKPieceList : NSObject

+ (id)englishPieceList;
+ (id)defaultPieceList;
- (void)setDefaultPieceList:(CKPieceList *)list;

- (CCPiece)pieceForString:(NSString *)string;
- (NSString *)stringForPiece:(CCPiece)piece;

// keys are NSNumber wrapping CCPiece, values are the string values for the piece.
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
