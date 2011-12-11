//
//  CKMove.h
//  ChessKit
//
//  Created by Austen Green on 12/10/11.
//  Copyright (c) 2011 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreChess.h"

@interface CKMove : NSObject
@property (nonatomic, assign) CCSquare from;
@property (nonatomic, assign) CCSquare to;
@property (nonatomic, assign) CCPiece promotionPiece;
@property (nonatomic, strong) id undoState;

+ (id)moveWithFrom:(CCSquare)from to:(CCSquare)to;

- (id)initWithFrom:(CCSquare)from to:(CCSquare)to;


@end
