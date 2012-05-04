//
//  CKGameTree.m
//  ChessKit
//
//  Created by Austen Green on 4/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKGameTree.h"
#import "CKMove.h"
#import "CKPosition.h"
#import "CKMutablePosition.h"
#import "CKGameTreeEnumerator.h"

@interface CKGameTree()
{
    CKPosition *_position;
    CKMove *_move;
    NSMutableArray *_children;
    __weak CKGameTree *_parent;
}

@end

@implementation CKGameTree
@synthesize move = _move;
@synthesize parent = _parent;
@synthesize comment = _comment;
@synthesize moveString = _moveString;
@synthesize annotationGlyphs = _annotationGlyphs;

- (void)commonInit
{
    _children = [[NSMutableArray alloc] init];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithPosition:(CKPosition *)position
{
    self = [super init];
    if (self)
    {
        _position = [position copy];
        [self commonInit];
    }
    return self;
}

- (CKGameTree *)gameTreeWithMove:(CKMove *)move
{
    return [self gameTreeWithMove:move withValidation:NO];
}

- (CKGameTree *)gameTreeWithMove:(CKMove *)move withValidation:(BOOL)shouldValidate
{
    CKPosition *position = [self position];

    if (shouldValidate)
    {
        BOOL valid = [position isMoveLegal:move];
        if (!valid)
            return nil;
    }
    
    CKGameTree *tree = [[CKGameTree alloc] init];
    tree->_position = [position positionByMakingMove:move];
    tree->_move = move;
    
    return tree;
}

- (void)addMove:(CKMove *)move
{
    [self addMove:move withValidation:NO];
}

- (BOOL)addMove:(CKMove *)move withValidation:(BOOL)shouldValidate
{
    if (shouldValidate)
    {
        CKPosition *position = [self position];
        
        BOOL valid = [position isMoveLegal:move];
        if (!valid)
            return NO;
        
        CKGameTree *tree = [[CKGameTree alloc] init];
        tree->_position = [position positionByMakingMove:move];
        tree->_move = move;
        tree->_parent = self;
        [_children addObject:tree];
    }
    else 
    {
        CKGameTree *tree = [[CKGameTree alloc] init];
        tree->_move = move;
        tree->_parent = self;
        [_children addObject:tree];
    }

    return YES;
}

- (CKPosition *)position
{
    if (!_position)
    {
        if (self.move && self.parent)
        {
            _position = [self.parent.position positionByMakingMove:self.move];
        }
    }
    return _position;
}

- (CKGameTree *)nextTree
{
    if (self.children.count)
        return [self.children objectAtIndex:0];
    else
        return nil;
}

- (CKGameTree *)endOfLine
{
    CKGameTree *tree = self;
    
    while (tree.children.count)
        tree = tree.nextTree;
    
    return tree;
}

- (NSArray *)children
{
    return _children;
}

- (NSEnumerator *)mainLineEnumerator
{
    return [[CKGameTreeEnumerator alloc] initWithGameTree:self];
}

- (void)setPosition:(CKPosition *)position
{
    _position = position;
}

- (BOOL)hasVariations
{
    BOOL hasVariations = NO;
    
    CKGameTree *tree = self;
    while (tree)
    {
        if (tree.children.count == 0)
            break;
        
        if (tree.children.count > 1)
        {
            hasVariations = YES;
            break;
        }
        
        tree = tree.nextTree;
    }
    
    return hasVariations;
}

- (NSString *)description
{
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"<%@ %p>", [self class], self];
    if (self.move)
        [string appendFormat:@" %@", self.move];
    if (self.comment)
        [string appendFormat:@" \"%@\"", self.comment];
    if (self.children.count)
        [string appendFormat:@"\n%@", [self valueForKeyPath:@"children.move"]];
    
    return string;
}

@end

