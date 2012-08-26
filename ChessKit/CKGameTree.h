//
//  CKGameTree.h
//  ChessKit
//
//  Created by Austen Green on 4/22/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    CKGameTreeEnumerationStatusStartOfLine = 1,
    CKGameTreeEnumerationStatusEndOfLine = 2,
} CKGameTreeEnumerationStatus;

struct CKGameTreeEnumerationInfo 
{
    NSUInteger depth;
    NSUInteger index;  // Index in parent's children array.
    CKGameTreeEnumerationStatus status;
};

enum {
    CKEnumerationMainLine,
    CKEnumerationAllLines,
};
typedef NSUInteger CKEnumerationOptions;


typedef  struct CKGameTreeEnumerationInfo CKGameTreeEnumerationInfo;

@class CKMove, CKPosition;

/**
 @class CKGameTree
 @abstract CKGameTree represents a single, mutable node in a chess game tree.
 A CKGameTree always has a parent CKGameTree object unless it is the root position for a game.
 A CKGameTree has one or more child CKGameTree objects that are accessible from the children property.
 If there is at least one child tree, the child at index 0 is considered to be the main line.
 The game tree's move provides the move that was made to go from the parent's position to the current node's
 position.
 */
@interface CKGameTree : NSObject
@property (strong, nonatomic, readonly) NSArray *children;
@property (nonatomic, readonly, weak) CKGameTree *parent;
@property (nonatomic, readonly, strong) CKMove *move;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *moveString;
@property (nonatomic, strong) NSIndexSet *annotationGlyphs;

- (CKPosition *)position;

- (id)initWithPosition:(CKPosition *)position;
- (id)initWithPosition:(CKPosition *)position move:(CKMove *)move;

- (CKGameTree *)gameTreeWithMove:(CKMove *)move;
- (CKGameTree *)gameTreeWithMove:(CKMove *)move withValidation:(BOOL)shouldValidate;

- (void)addMove:(CKMove *)move;
- (BOOL)addMove:(CKMove *)move withValidation:(BOOL)shouldValidate;

- (void)replaceChildAtIndex:(NSUInteger)index withGameTree:(CKGameTree *)gameTree;
- (void)deleteChildAtIndex:(NSUInteger)index;

/**
 Returns the main line in the tree
 */
- (CKGameTree *)nextTree;

/**
 Returns the last CKGameTree object in the current main line
 */
- (CKGameTree *)endOfLine;

- (NSEnumerator *)mainLineEnumerator;
- (BOOL)hasVariations;

- (void)enumerateChildrenUsingBlock:(void (^)(CKGameTree *child, CKGameTreeEnumerationInfo info, BOOL *stop))block;
- (void)enumerateChildrenUsingBlock:(void (^)(CKGameTree *child, CKGameTreeEnumerationInfo info, BOOL *stop))block options:(CKEnumerationOptions)options;

@end
