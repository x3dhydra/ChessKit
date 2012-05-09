//
//  CKGameFormatter.m
//  ChessKit
//
//  Created by Austen Green on 5/2/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKGameFormatter.h"
#import "ChessKit.h"
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

@interface CKGameFormatter()
{
    BOOL _hasVariations;
    BOOL _hasTopLevelCommentary;
    NSDictionary *_topLevelAttributes;
    NSDictionary *_commentAttributes;
    NSDictionary *_shallowNestedAttributes;
    NSDictionary *_deeplyNestedAttributes;
}
@end

@implementation CKGameFormatter
@synthesize game = _game;
@synthesize variationEndString = _variationEndString;
@synthesize variationStartString = _variationStartString;
@synthesize commentEndString = _commentEndString;
@synthesize commentStartString = _commentStartString;
@synthesize textSize = _textSize;

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
    
    // Keep a flag to denote when a move number needs to be prepended.
    // Always start off needing a move number for the first move of the game
    __block BOOL needsMoveNumberPrepended = YES;    
    
    [self.game.gameTree enumerateChildrenUsingBlock:^(CKGameTree *child, CKGameTreeEnumerationInfo info, BOOL *stop) {
                
        if ((info.status & CKGameTreeEnumerationStatusStartOfLine) && info.depth)
        {
            [string appendString:@"("];
            needsMoveNumberPrepended = YES;
        }
        
        // White always has the move number prepended
        if (child.position.sideToMove == CCBlack)
            needsMoveNumberPrepended = YES;
        
        if (needsMoveNumberPrepended)
        {
            [string appendFormat:@"%d.", child.position.moveNumber];
            if (child.position.sideToMove == CCWhite)
                [string appendString:@".."]; 
            
            // Reset the context so that move numbers won't be appended
            needsMoveNumberPrepended = NO;
        }
        
        [string appendFormat:@"%@ ", child.moveString];
                
        if (child.comment)
        {
            [string appendFormat:@"{%@} ", child.comment];
            needsMoveNumberPrepended = YES;
        }
        
        if ((info.status & CKGameTreeEnumerationStatusEndOfLine) && info.depth)
        {
            [string appendString:@") "];
            needsMoveNumberPrepended = YES;
        }
    }];

    return string;
}

- (NSAttributedString *)attributedGameTree
{
    [self preprocessGame];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    
    __block BOOL needsMoveNumberPrepended = YES;
    
    [self.game.gameTree enumerateChildrenUsingBlock:^(CKGameTree *child, CKGameTreeEnumerationInfo info, BOOL *stop) {
        if ((info.status & CKGameTreeEnumerationStatusStartOfLine) && info.depth)
        {
            NSString *opener = info.depth > 1 ? @"(" : @"[";
            NSDictionary *attributes = info.depth > 1 ? [self deeplyNestedAttributes] : [self shallowNestedAttributes];
            
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:opener attributes:attributes]];
            needsMoveNumberPrepended = YES;
        }
        
        // White always has the move number prepended
        if (child.position.sideToMove == CCBlack)
            needsMoveNumberPrepended = YES;
        
        NSDictionary *attributes = nil;
        if (info.depth == 0)
            attributes = [self topLevelAttributes];
        else if (info.depth == 1)
            attributes = [self shallowNestedAttributes];
        else
            attributes = [self deeplyNestedAttributes];
        
        if (needsMoveNumberPrepended)
        {
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d.", child.position.moveNumber] attributes:attributes]];
            if (child.position.sideToMove == CCWhite)
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:@".." attributes:attributes]];
            
            // Reset the context so that move numbers won't be appended
            needsMoveNumberPrepended = NO;
        }
        
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", child.moveString] attributes:attributes]];
        
        if (child.comment)
        {
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:child.comment attributes:[self commentAttributes]]];
            needsMoveNumberPrepended = YES;
        }
        
        if ((info.status & CKGameTreeEnumerationStatusEndOfLine) && info.depth)
        {
            NSString *closer = info.depth > 1 ? @") " : @"] ";
            NSDictionary *attributes = info.depth > 1 ? [self deeplyNestedAttributes] : [self shallowNestedAttributes];
            
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:closer attributes:attributes]];
            needsMoveNumberPrepended = YES;
        }
    }];
    
    return string;
}

- (void)preprocessGame
{
    [self.game.gameTree enumerateChildrenUsingBlock:^(CKGameTree *child, CKGameTreeEnumerationInfo info, BOOL *stop) {
        if (_hasVariations && _hasTopLevelCommentary)
        {
            *stop = YES;
        }
        
        if (info.depth > 0)
            _hasVariations = YES;
        
        if (child.comment && info.depth == 0)
            _hasTopLevelCommentary = YES;
    }];
}

- (NSDictionary *)topLevelAttributes
{
    if (!_topLevelAttributes)
    {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:(__bridge id)[[UIColor blackColor] CGColor]  forKey:(__bridge NSString *)kCTForegroundColorAttributeName];
        CTFontRef font = NULL;
        
        if (_hasTopLevelCommentary || _hasVariations)
        {
            UIFont *aFont = [UIFont boldSystemFontOfSize:12.0f];
            font = CTFontCreateWithName((__bridge CFStringRef)[aFont fontName], [self textSize], NULL);
        }
        else 
        {
            font = CTFontCreateWithName((__bridge CFStringRef)[[UIFont systemFontOfSize:[self textSize]] fontName], [self textSize], NULL);
        }
        
        [attributes setObject:(__bridge id)font forKey:(__bridge NSString *)kCTFontAttributeName];
        CFRelease(font);
        
        _topLevelAttributes = [[NSDictionary alloc] initWithDictionary:attributes];
    }
    return _topLevelAttributes;
}

- (NSDictionary *)commentAttributes
{
    if (!_commentAttributes)
    {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:(__bridge id)[[UIColor blueColor] CGColor]  forKey:(__bridge NSString *)kCTForegroundColorAttributeName];
        
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)[[UIFont systemFontOfSize:[self textSize]] fontName], [self textSize], NULL);
        [attributes setObject:(__bridge id)font forKey:(__bridge NSString *)kCTFontAttributeName];
        CFRelease(font);
        
        _commentAttributes = [[NSDictionary alloc] initWithDictionary:attributes];
    }
    return _commentAttributes;
}

- (NSDictionary *)shallowNestedAttributes
{
    if (!_shallowNestedAttributes)
    {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:(__bridge id)[[UIColor blackColor] CGColor]  forKey:(__bridge NSString *)kCTForegroundColorAttributeName];
        
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)[[UIFont systemFontOfSize:[self textSize]] fontName], [self textSize], NULL);
        [attributes setObject:(__bridge id)font forKey:(__bridge NSString *)kCTFontAttributeName];
        CFRelease(font);

        _shallowNestedAttributes = [[NSDictionary alloc] initWithDictionary:attributes];
    }
    return _shallowNestedAttributes;
}

- (NSDictionary *)deeplyNestedAttributes
{
    if (!_deeplyNestedAttributes)
    {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:(__bridge id)[[UIColor blackColor] CGColor]  forKey:(__bridge NSString *)kCTForegroundColorAttributeName];
        
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)[[UIFont italicSystemFontOfSize:[self textSize]] fontName], [self textSize], NULL);
        [attributes setObject:(__bridge id)font forKey:(__bridge NSString *)kCTFontAttributeName];
        CFRelease(font);
        
        _deeplyNestedAttributes = [[NSDictionary alloc] initWithDictionary:attributes];
    }
    return _deeplyNestedAttributes;
}

- (CGFloat)textSize
{
    if (_textSize == 0.0f)
    {
        return [UIFont systemFontSize];
    }
    return _textSize;
}

@end