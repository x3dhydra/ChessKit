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

#pragma mark - Enumeration

- (void)enumerateChildrenUsingBlock:(void (^)(CKGameTree *child, CKGameTreeEnumerationInfo info, BOOL *stop))block;
{
    [self enumerateChildrenUsingBlock:block options:CKEnumerationAllLines];
}

- (void)enumerateChildrenUsingBlock:(void (^)(CKGameTree *, CKGameTreeEnumerationInfo, BOOL *))block options:(CKEnumerationOptions)options
{
    if (options == CKEnumerationAllLines)
    {
        BOOL stop = NO;
        CKGameTreeEnumerationInfo info;
        info.depth = 0;
        info.status = CKGameTreeEnumerationStatusStartOfLine;
        info.index = NSNotFound;
        [self enumerateLinesUsingBlock:block context:info stop:&stop];
    }
    else if (options == CKEnumerationMainLine)
    {
        BOOL stop = NO;
        CKGameTreeEnumerationInfo info;
        info.depth = 0;
        info.status = CKGameTreeEnumerationStatusStartOfLine;
        info.index = 0;
    }
}

// Return NO to indicate that the recursive enumeration should stop
- (void)enumerateLinesUsingBlock:(void (^)(CKGameTree *child, CKGameTreeEnumerationInfo info, BOOL *stop))block context:(CKGameTreeEnumerationInfo)context stop:(BOOL *)stop
{
    // Bail early if there is no block, if stop has explicity been set to YES, or there are no children
    if (!block || *stop || self.children.count == 0)
        return;
    
    CKGameTree *child = [self nextTree];
    
    __block CKGameTreeEnumerationInfo info;
    info.depth = context.depth;
    info.index = 0;
    info.status = 0;
    if (child.children.count == 0)
        info.status = CKGameTreeEnumerationStatusEndOfLine;
        
    block(child, info, stop);
    if (*stop)
        return;
    
    if (self.children.count > 1)
    {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, self.children.count - 1)];
        [self.children enumerateObjectsAtIndexes:indexes options:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stopEnumeration) {
            
            // We're going deeper into the variation tree, so add one to the depth
            info.depth = context.depth + 1;
            info.index = idx;
            info.status = CKGameTreeEnumerationStatusStartOfLine;
            if ([[obj children] count] == 0)
                info.status |= CKGameTreeEnumerationStatusEndOfLine;
            
            block(obj, info, stop);
            
            if (!*stop)
                [obj enumerateLinesUsingBlock:block context:info stop:stop];
            
            *stopEnumeration = *stop;
            
            info.depth = context.depth;
        }];
        
        if (*stop)
            return;
    }
    
    [child enumerateLinesUsingBlock:block context:info stop:stop];
}

- (void)replaceChildAtIndex:(NSUInteger)index withGameTree:(CKGameTree *)gameTree
{
	[_children replaceObjectAtIndex:index withObject:gameTree];
}

- (void)deleteChildAtIndex:(NSUInteger)index
{
	[_children removeObjectAtIndex:index];
}


@end

