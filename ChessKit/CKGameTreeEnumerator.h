//
//  CKGameTreeEnumerator.h
//  ChessKit
//
//  Created by Austen Green on 4/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKGameTree, CKMutablePosition;

@interface CKGameTreeEnumerator : NSEnumerator
{
    CKGameTree *_gameTree;
    CKGameTree *_currentNode;
    CKMutablePosition *_currentPosition;
    BOOL _exhaustedLine;
}

- (id)initWithGameTree:(CKGameTree *)tree;
@end
