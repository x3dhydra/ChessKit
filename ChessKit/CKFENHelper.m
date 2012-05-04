//
//  CKFENHelper.m
//  ChessKit
//
//  Created by Austen Green on 4/23/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKFENHelper.h"
#import "CKPosition.h"
#import "CKMutablePosition.h"

@interface CKFENHelper()
- (CCColoredPiece)coloredPieceForCharacter:(char)character;
@end

@implementation CKFENHelper

+ (CKFENHelper *)sharedHelper
{
    static CKFENHelper *sharedHelper = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[self alloc] init];
    });
    return sharedHelper;
}

+ (CKPosition *)positionWithFEN:(NSString *)FENString
{
    return [[self sharedHelper] positionWithFEN:FENString];
}

- (CKPosition *)positionWithFEN:(NSString *)FENString
{
    CKMutablePosition *position = [[CKMutablePosition alloc] init];
    CCMutableBoardRef board = position.board;
    
    const char *string = [FENString cStringUsingEncoding:NSUTF8StringEncoding];
    
    // Do a quick validation check on the string to make sure that there are an appropriate number of spaces (5)
    int count = 0;
    char *pointer = strchr(string, ' ');
    while (pointer != NULL) {
        count++;
        pointer = strchr(pointer+1, ' ');
    }
    if (count != 5)
        return nil;
    
    int index = 0;
    char currentCharacter = 0;
    
    // Start scanning the position
    int rank = 7;
    int file = 0;
    
    do 
    {
        currentCharacter = string[index];
        index++;
        
        if (isnumber(currentCharacter))
            file += currentCharacter - '0';
        else if (currentCharacter == '/')
        {
            file = 0;
            rank--;
        }
        else if (strchr("KQBRNPkqbrnp", currentCharacter))
        {
            CCSquare square = CCSquareMake(rank, file);
            CCBoardSetSquareWithPiece(board, square, [self coloredPieceForCharacter:currentCharacter]);
            file++;
        }
        
    } while (currentCharacter && currentCharacter != ' ');
    
    // The last square scanned needs to be h1.  The file may actually be 8 if a piece was scanned,
    // due to the file++ statement after scanning a piece
    if ((file != 8 && file != 7) || rank != 0)
        return nil;
    
    // Side to move
    char sideToMove = string[index];
    if (tolower(sideToMove) == 'w')
        position.sideToMove = CCWhite;
    else if (tolower(sideToMove) == 'b')
        position.sideToMove = CCBlack;
    else
        return nil;
    
    index += 2; // Skip the next whitespace
    
    // Castling rights
    CCCastlingRights castlingRights = CCCastlingRightsNone;
    
    if (string[index] == '-')
    {
        index += 2; // Skip the next whitespace
    }
    else
    {
        do 
        {
            currentCharacter = string[index];
            
            switch (currentCharacter) {
                case 'K':
                    castlingRights |= CCCastlingRightsWhiteKingside;
                    break;
                case 'Q':
                    castlingRights |= CCCastlingRightsWhiteQueenside;
                    break;
                case 'k':
                    castlingRights |= CCCastlingRightsBlackKingside;
                    break;
                case 'q':
                    castlingRights |= CCCastlingRightsBlackQueenside;
                    break;
                case ' ':
                    break;
                default:
                    return nil;
                    break;
            }
            
            index++;
        } while (currentCharacter && currentCharacter != ' ');
    }
    
    position.castlingRights = castlingRights;
    
    // En passant square
    CCSquare enPassantSquare = InvalidSquare;
    
    if (string[index] == '-')
    {
        // Do nothing - the whitespace will be skipped regardless
    }
    else
    {
        signed char file = string[index] - 'a';
        signed char rank = string[++index] - '1';
        enPassantSquare = CCSquareMake(rank, file);
        if (!CCSquareIsValid(enPassantSquare))
            return nil;
    }
    index+= 2; // Skip the next whitespace
    
    position.enPassantSquare = enPassantSquare;
    
    // Halfmove clock
    int halfmove = atoi(&string[index]);
    position.halfmoveClock = halfmove;
    
    // Full move
    char *moveStart = strchr(&string[index], ' ');
    if (!moveStart)
        return nil;
    moveStart++;
    
    int fullMove = atoi(moveStart);
    if (fullMove <= 0)
        return nil;
    
    // Convert from ful move to ply since that's how it's represented in position
    int ply = (fullMove - 1) * 2;
    ply += position.sideToMove == CCWhite ? 0 : 1;
    position.ply = ply;
    
    return position;
}

- (CCColoredPiece)coloredPieceForCharacter:(char)character
{
    return CCColoredPieceForCharacter(character);
}

@end
