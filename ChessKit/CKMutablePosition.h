//
//  CKMutablePosition.h
//  ChessKit
//
//  Created by Austen Green on 12/10/11.
//  Copyright (c) 2011 Austen Green Consulting. All rights reserved.
//

#import "CKPosition.h"

@interface CKMutablePosition : CKPosition

- (void)makeMove:(CKMove *)move;
- (void)unmakeMove:(CKMove *)move;

@end
