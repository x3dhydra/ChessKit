//
//  CKGameTreeEnumerator.m
//  ChessKit
//
//  Created by Austen Green on 4/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKGameTreeEnumerator.h"
#import "CKMutablePosition.h"
#import "CKGameTree.h"

@interface CKGameTree()
- (void)setPosition:(CKPosition *)position;
@end

@implementation CKGameTreeEnumerator

- (id)initWithGameTree:(CKGameTree *)tree
{
    self = [super init];
    if (self)
    {
        _gameTree = tree;
        _currentPosition = [CKMutablePosition positionWithPosition:tree.position];
    }
    return self;
}

- (id)nextObject
{
    if (_currentNode == nil && !_exhaustedLine)
    {
        _currentNode = _gameTree;
        return _currentNode;
    }
    
    _currentNode = [_currentNode nextTree];
    
    if (!_currentNode)
    {
        _exhaustedLine = YES;
        return nil;
    }
    
    [_currentPosition makeMove:_currentNode.move];
    [_currentNode setPosition:_currentPosition];
    
    return _currentNode;
}

@end
