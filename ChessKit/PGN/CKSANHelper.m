//
//  CCSanKit.c
//  CoreChess
//
//  Created by Austen Green on 6/18/11.
//  Copyright 2011 Austen Green Consulting. All rights reserved.
//

#import "CoreChess.h"
#import "CKSANHelper.h"
#import "CCSquare.h"
#import "ChessKit.h"

static NSCharacterSet *trimCharacters;

@interface CKSANHelper ()
+ (CCPiece)promotionPieceFromString:(NSString *)san;
+ (CCPiece)movingPieceFromString:(NSString *)san;
+ (CCSquare)destinationSquareFromString:(NSString *)san;
+ (CCSquare)disambiguateSourceSquareFromString:(NSString *)san;
+ (CCSquare)originSquareFromString:(NSString *)san position:(CKPosition *)position piece:(CCPiece)piece destination:(CCSquare)to;
@end

@implementation CKSANHelper

+ (void)initialize
{
    if (self == [CKSANHelper class])
    {
        trimCharacters = [NSCharacterSet characterSetWithCharactersInString:@"x=+*#"];
    }
}

+ (CKMove *)moveFromString:(NSString *)san withPosition:(CKPosition *)position
{
    // SAN moves must be between 2 and 7 characters
    if ([san length] < 2 || [san length] > 7)
        return nil;
    
    // No, this is not the most efficient way of doing it, but it'll do for now.
    NSMutableString *string = [NSMutableString stringWithCapacity:7];
    CKMove *move = nil;
    
    // Trim unnecesary characters from san
    for (int i = 0; i < [san length]; i++)
    {
        char c = [san characterAtIndex:i];
        if (![trimCharacters characterIsMember:c])
            [string appendFormat:@"%c", c];
    }
    
    // Castling is easy since it's an absolute string (at least in the context of a standard chess game)
    if ([string isEqualToString:@"O-O"] || [string isEqualToString:@"0-0"])
    {
        if (position.sideToMove == CCWhite)
            move = [CKMove moveWithFrom:e1 to:g1];
        else
            move = [CKMove moveWithFrom:e8 to:g8];
    }
    else if ([string isEqualToString:@"O-O-O"] || [string isEqualToString:@"0-0-0"])
    {
        if (position.sideToMove == CCWhite)
            move = [CKMove moveWithFrom:e1 to:c1];
        else
            move = [CKMove moveWithFrom:e8 to:c8];
    }
    
    // TODO: Null move
    
    // Otherwise it requires more parsing
    else
    {
        CCPiece promotion = [self promotionPieceFromString:string];
        // Delete the last character if the move was a promotion
        if (CCPieceIsValid(promotion))
            [string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
        
        // Set the to square and erase the last two characters, leaving only disambiguation terms
        CCSquare to = [self destinationSquareFromString:string];
        [string deleteCharactersInRange:NSMakeRange([string length] - 2, 2)];
        
        CCPiece piece = [self movingPieceFromString:string];
        if (piece != PawnPiece)
            [string deleteCharactersInRange:NSMakeRange(0, 1)];
        
        CCSquare from = [self originSquareFromString:string position:position piece:piece destination:to];
        
        CKMove *move = [CKMove moveWithFrom:from to:to];
        move.promotionPiece = promotion;
        return move;
    }
    
    return move;
}

/* This SanToMove implementation works by copying the SAN string and removing information from
 * the copied string as the information is parsed, making it easier to parse other pieces of 
 * information from the simplified string. */
    
    /* Otherwise it requires a bit more parsing */
/*    else {
        // Set a promotion piece
        move.setPromotionPiece(promotionPieceFromSan(s));
        if (move.promotionPiece().isPiece()) {
            s.erase(--s.end()); // Erase the last character from s if it indicates a promotion
        }
        
        Piece pt = movingPieceFromSan(s);
        if (pt != Pawn) {
            s.erase(s.begin()); // Erase the first character from s, so that the moving piece is
            // removed from the move.
        }
        
        move.setTo(destinationFromSan(s));
        s.erase(s.length() - 2, 2); // Erase the last two characters from s (the destination square)
        
        move.setFrom(disambiguateSourceFromSan(s, position, pt, move.to()));
    }*/
    


+ (NSString *)stringFromMove:(CKMove *)move withPosition:(CKPosition *)position
{
    return [self stringFromMove:move withPosition:position pieceList:nil];
}

+ (NSString *)stringFromMove:(CKMove *)move withPosition:(CKPosition *)position pieceList:(CKPieceList *)pieceList
{
	if (!pieceList)
		pieceList = [CKPieceList defaultPieceList];
	
	NSMutableString *string = [NSMutableString string];
	
	
	if ([position isMoveCastle:move])
	{
		if (move.to == c1 || move.to == c8)
			[string appendString:@"O-O-O"];
		else if (move.to == g1 || move.to == g8)
			[string appendString:@"O-O"];
	}
	else
	{
		CCColoredPiece coloredPiece = CCBoardGetPieceAtSquare(position.board, move.from);
		CCPiece piece = CCColoredPieceGetPiece(coloredPiece);
		NSString *pieceSymbol = [pieceList stringForPiece:piece];
		if (pieceSymbol.length)
			[string appendString:pieceSymbol];
	
		CCBitboard disambiguation = CCBoardGetAttacksToSquare(position.board, move.to) & CCBoardGetBitboardForColoredPiece(position.board, coloredPiece) & ~CCBitboardGetAbsolutePinsOfColor(position.board, position.sideToMove);
		if (piece != PawnPiece && CCBitboardPopulationCount(disambiguation) > 1)
		{
			// TODO: disambiguate here
			CCBitboard file = CCBitboardGetFileAttacks(EmptyBB, move.from) & disambiguation;
			CCBitboard rank= CCBitboardGetRankAttacks(EmptyBB, move.from) & disambiguation;
			
			// Note that file excludes the piece on the from square, so a non-empty bitboard indicates that another piece besides the one that's moving is present along that file/rank
			if (CCBitboardPopulationCount(file) == 0)
			{
				// Can disambiguate by file (preferred)
				[string appendString:[(__bridge NSString *)CCSquareName(move.from) substringToIndex:1]];
			}
			else if (CCBitboardPopulationCount(rank) == 0 && CCBitboardPopulationCount(file) > 0)
			{
				// Can disambiguate by rank
				[string appendFormat:@"%d", CCSquareRank(move.from) + 1];
			}
			else
			{
				// Couldn't disambiguate by rank or file - use actual square
				[string appendString:(__bridge NSString *)CCSquareName(move.from)];
			}
		}
		
		if (CCBoardGetPieceAtSquare(position.board, move.to) != NoColoredPiece || [position isMoveEnPassantCapture:move])
		{
			if (piece == PawnPiece)
			{
				// Get the file from the square
				[string appendString:[(__bridge NSString *)CCSquareName(move.from) substringToIndex:1]];
			}
			
			[string appendString:@"x"]; // Append capture token
		}
		
		NSString *squareName = (__bridge NSString *)(CCSquareName(move.to));
		[string appendString:squareName];
	}
	
	
	return string;
}

// Preconditions: san is a valid SAN move that has been normalized via normalizeSanString
// Returns the promoted piece as designated by san or returns 'None'.
+ (CCPiece)promotionPieceFromString:(NSString *)san
{
    char c = [san characterAtIndex:([san length] - 1)];
    return CCPieceMake(c);
}

// Preconditions: san is a valid, non-castling SAN move that has been normalized.
// Returns the PieceType moving as indicated by SAN, either indicated by the English
// character representation of the piece, or lack of indicating a pawn.

+ (CCPiece)movingPieceFromString:(NSString *)san
{
    // Generate the piece from the first character, otherwise it's a pawn
    CCPiece piece = PawnPiece;
    if ([san length] == 0)
        return piece;
    
    char c = [san characterAtIndex:0];
    if (strchr("NBRQK", c))
        piece = CCPieceMake(c);
    return piece;
}

// Preconditions: san is a valid, non-castling SAN move that has been normalized, and 
// trailing characters indicated a promotion piece have been removed from san.
// Returns the destination square as indicated by san */

+ (CCSquare)destinationSquareFromString:(NSString *)san
{
    // Use the last 2 characters from the string to get the destination square
    NSString *square = [san substringWithRange:NSMakeRange([san length] - 2, 2)];
    return CCSquareMakeForString([square cStringUsingEncoding:NSUTF8StringEncoding]);
}

+ (CCSquare)originSquareFromString:(NSString *)san position:(CKPosition *)position piece:(CCPiece)type destination:(CCSquare)to
{
    // No need for disambiguation - the source square is given in the san move
    if ([san length] == 2)
    {
        return CCSquareForString((__bridge CFStringRef)san);
    }
    
    // Get the bitboard of all pieces of pt which can pseudo-legally move to the destination square
    CCColoredPiece piece = CCColoredPieceMake(position.sideToMove, type);
#warning Finish implementation
    CCBitboard bitboard = CCBoardGetPseudoLegalMovesToSquareForPiece(position.board, to, piece);
        
    if (to == position.enPassantSquare && type == PawnPiece)
    {
        // Also include en passant targets
        bitboard |= (CCBoardGetAttacksToSquare(position.board, to) & CCBoardGetBitboardForColoredPiece(position.board, piece));
    }
    
    // TODO: Check legality, not just pseudo-legality
    
    if ([san length] == 1)
    {
        CCBitboard mask = EmptyBB;
        char c = [san characterAtIndex:0];
        if ((c >= 'a') && (c <= 'h'))
        {
            mask = filesBB(c - 'a');
        }
        else if ((c >= '1') && (c <= '8'))
        {
            mask = ranksBB(c - '1');
        }
        
        bitboard &= mask;
    }
    
    // If we have too many pieces, see if we can disambiguate by removing any absolutel pinned pieces
    if (CCBitboardPopulationCount(bitboard) > 1)
    {
        // Exclude pinned pieces from those pieces that can move.
        CCBitboard pinnedPieces = CCBitboardGetAbsolutePinsOfColor(position.board, position.sideToMove);
        bitboard &= ~pinnedPieces;
    }
    
    if (CCBitboardPopulationCount(bitboard) != 1)
    {   
        return InvalidSquare;
    }
    
    return CCSquareForBitboard(bitboard);
}

/*
Square SAN::disambiguateSourceFromSan(const std::string& san, const StandardPosition& pos, Piece pt, Square dest) {
    
    // No need for disambiguation - the source square is given in the san move
    if (san.length() == 2) {
        return Square(san);
    }
    
    // Get the bitboard of all pieces of pt which can pseudo-legally move to the destination square
    ColoredPiece piece = ColoredPiece(pos.sideToMove(), pt);
    Bitboard b = coloredPiecePseduoLegalMovesTo(dest, piece, pos);
    
    // 1 character for disambiguation:
    // Either rank or file.  Use the rank or file Bitboard as a mask for the
    // piece which needs disambiguation. 
    if (san.length() == 1) {
        Bitboard mask;
        if ((san.at(0) >= 'a') && (san.at(0) <= 'h')) {
            // Disambiguate ranks
            mask = FilesBB[(san.at(0) - 'a')];
        } else if ((san.at(0) >= '1') && (san.at(0) <= '8')) {
            // Disambiguate files
            mask = RanksBB[(san.at(0) - '1')];
        }
        b &= mask;
    }
    
    // Throw an exception if there is still ambiguity in the source square //
    if (BBPopCount(b) != 1) {
        print_bitboard(b);
        throw AGChess_Exception("SAN::disambiguateSourceFromSan() ambiguous source square in move");
    }
    
    return squareForBitboard(b);
}
};*/

@end