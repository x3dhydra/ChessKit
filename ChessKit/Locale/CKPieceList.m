//
//  CKPieceList.m
//  ChessKit
//
//  Created by Austen Green on 8/26/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKPieceList.h"

static CKPieceList *_defaultPieceList = nil;

@interface CKPieceList()
{
	NSDictionary *_pieceForString;
	NSDictionary *_stringForPiece;
}

@end

@implementation CKPieceList

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self)
	{
		NSMutableDictionary *pieces = [NSMutableDictionary dictionaryWithCapacity:dictionary.count];
		NSMutableDictionary *strings = [NSMutableDictionary dictionaryWithCapacity:dictionary.count];
		[dictionary enumerateKeysAndObjectsUsingBlock:^(id key, NSString *pieceSymbol, BOOL *stop) {
			pieceSymbol = [pieceSymbol copy];
			[strings setObject:key forKey:pieceSymbol];
			[pieces setObject:pieceSymbol forKey:key];
		}];
		_pieceForString = strings;
		_stringForPiece = pieces;
	}
	return self;
}

- (id)keyForPiece:(CCPiece)piece
{
	return [NSNumber numberWithInteger:piece];
}

- (CCPiece)pieceForKey:(NSNumber *)key
{
	if (key)
		return [key integerValue];
	else
		return NoPiece;
}

- (CCPiece)pieceForString:(NSString *)string
{
	return [self pieceForKey:[_pieceForString objectForKey:string]];
}

- (NSString *)stringForPiece:(CCPiece)piece
{
	id key = [self keyForPiece:piece];
	return [_stringForPiece objectForKey:key];
}


+ (id)englishPieceList
{
	static CKPieceList *_englishPieceList;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_englishPieceList = [[self alloc] initWithDictionary:@{ @(RookPiece) : @"R",
							 @(KnightPiece) : @"N",
							 @(BishopPiece) : @"B",
							 @(QueenPiece) : @"Q",
							 @(KingPiece) : @"K"
							 }];
	});
	return _englishPieceList;
}

+ (id)defaultPieceList
{
	if (!_defaultPieceList)
		return [self englishPieceList];
	else
		return _defaultPieceList;
}

- (void)setDefaultPieceList:(CKPieceList *)list
{
	_defaultPieceList = list;
}

@end
