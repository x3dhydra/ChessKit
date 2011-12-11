//
//  CKPosition.m
//  ChessKit
//
//  Created by Austen Green on 12/10/11.
//  Copyright (c) 2011 Austen Green Consulting. All rights reserved.
//

#import "CKPosition.h"
#import "CKMutablePosition.h"
#import "CKMove.h"
#import "CCBoard+MoveGeneration.h"
#import "CCBitboard+MoveGeneration.h"
#import "CKPosition+Private.h"

@interface CKPosition()
{
    CCMutableBoardRef _board;
    CCCastlingRights _castlingRights;
    CCSquare _epSquare;
    CCColor _sideToMove;
    
    NSInteger _halfmoveClock;
    NSInteger _ply;
    BOOL _requiresPromotion;
}
@property (nonatomic, readwrite, assign) CCCastlingRights castlingRights;
@property (nonatomic, readwrite, assign) CCSquare enPassantSquare;
@property (nonatomic, readwrite, assign) CCColor sideToMove;
@property (nonatomic, readwrite, assign) NSInteger halfmoveClock;
@property (nonatomic, readwrite, assign) NSInteger ply;
@property (nonatomic, readwrite, assign) BOOL requiresPromotion;


@end

@implementation CKPosition
@synthesize board = _board;
@synthesize castlingRights = _castlingRights;
@synthesize enPassantSquare = _epSquare;
@synthesize sideToMove = _sideToMove;
@synthesize halfmoveClock = _halfmoveClock;
@synthesize ply = _ply;
@synthesize requiresPromotion = _requiresPromotion;

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self)
    {
        _board = CCBoardCreateMutable();
    }
    return self;
}

- (id)initWithStandardPosition
{
    self = [self init];
    if (self)
    {
        CCBoardSetSquareWithPiece(self.board, a1, WR);
        CCBoardSetSquareWithPiece(self.board, b1, WN);
        CCBoardSetSquareWithPiece(self.board, c1, WB);
        CCBoardSetSquareWithPiece(self.board, d1, WQ);
        CCBoardSetSquareWithPiece(self.board, e1, WK);
        CCBoardSetSquareWithPiece(self.board, f1, WB);
        CCBoardSetSquareWithPiece(self.board, g1, WN);
        CCBoardSetSquareWithPiece(self.board, h1, WR);
        
        CCBoardSetSquareWithPiece(self.board, a2, WP);
        CCBoardSetSquareWithPiece(self.board, b2, WP);
        CCBoardSetSquareWithPiece(self.board, c2, WP);
        CCBoardSetSquareWithPiece(self.board, d2, WP);
        CCBoardSetSquareWithPiece(self.board, e2, WP);
        CCBoardSetSquareWithPiece(self.board, f2, WP);
        CCBoardSetSquareWithPiece(self.board, g2, WP);
        CCBoardSetSquareWithPiece(self.board, h2, WP);
        
        CCBoardSetSquareWithPiece(self.board, a8, BR);
        CCBoardSetSquareWithPiece(self.board, b8, BN);
        CCBoardSetSquareWithPiece(self.board, c8, BB);
        CCBoardSetSquareWithPiece(self.board, d8, BQ);
        CCBoardSetSquareWithPiece(self.board, e8, BK);
        CCBoardSetSquareWithPiece(self.board, f8, BB);
        CCBoardSetSquareWithPiece(self.board, g8, BN);
        CCBoardSetSquareWithPiece(self.board, h8, BR);
        
        CCBoardSetSquareWithPiece(self.board, a7, BP);
        CCBoardSetSquareWithPiece(self.board, b7, BP);
        CCBoardSetSquareWithPiece(self.board, c7, BP);
        CCBoardSetSquareWithPiece(self.board, d7, BP);
        CCBoardSetSquareWithPiece(self.board, e7, BP);
        CCBoardSetSquareWithPiece(self.board, f7, BP);
        CCBoardSetSquareWithPiece(self.board, g7, BP);
        CCBoardSetSquareWithPiece(self.board, h7, BP);
        
        _castlingRights = CCCastlingRightsAll;
        _sideToMove = White;
        _epSquare = InvalidSquare;
    }
    return self;
}

- (id)initWithPosition:(CKPosition *)position
{
    self = [super init];
    if (self)
    {
        _board = CCBoardCreateMutableCopy(position.board);
        _castlingRights = position.castlingRights;
        _epSquare = position.enPassantSquare;
        _sideToMove = position.sideToMove;
        _halfmoveClock = position.halfmoveClock;
        _ply = position.ply;
    }
    return self;
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    id copy = nil;
    
    if (![self isKindOfClass:[CKMutablePosition class]])
        copy = [[CKMutablePosition alloc] initWithPosition:self];
    else
        copy = [[[self class] alloc] initWithPosition:self];
    
    return copy;
}

- (void)dealloc
{
    CCBoardRelease(_board);
}

#pragma mark - State

- (CCColoredPiece)coloredPieceAtSquare:(CCSquare)square
{
    return CCBoardGetPieceAtSquare(self.board, square);
}

#pragma mark - Getters / Setters

- (void)setBoard:(CCMutableBoardRef)board
{
    if (board == _board)
        return;
    
    CCBoardRelease(_board);
    _board = CCBoardCreateMutableCopy(board);
}

#pragma mark - Move

- (CKPosition *)positionByMakingMove:(CKMove *)move
{
    CKPosition *position = [[[self class] alloc] initWithPosition:self];
    
    [self makeMove:move withPosition:position];
    return position;
}

- (CKPosition *)positionByUnmakingMove:(CKMove *)move
{
    CKPosition *position = move.undoState;  // Undo state is simply copying the original position
    return position;
}

#pragma mark - Move Private

- (void)makeMove:(CKMove *)move withPosition:(CKPosition *)position
{
    CCSquare        from      = move.from;
    CCSquare        to        = move.to;
    CCColoredPiece  piece     = CCBoardGetPieceAtSquare(position.board, from);
    CCPiece         pieceType = CCColoredPieceGetPiece(piece);
    
    if (![self isMovePseudoLegal:move])
    {
        NSLog(@"Non-pseudolegal move");
        return;
    }
    
    // Save state
    [self makeSaveStateForMove:move];
    
    // Reset the en passant square if the moving piece isn't a pawn.  If it is a pawn,
    // it will be set by makePawnMove().
    if (!CCPieceEqualToPiece(pieceType, PawnPiece))
        self.enPassantSquare = InvalidSquare;
    
    // If piece moving is a king, then adjust castling rights or castle
    if (CCPieceEqualToPiece(pieceType, KingPiece))
        [self makeKingMove:move withPosition:position];
    
    /* If piece moving is a rook, then adjust castling rights */
    else if (CCPieceEqualToPiece(pieceType, RookPiece))
        [self makeRookMove:move withPosition:position];
    
    /* If piece moving is a pawn, then adjust for promotion, en passant captures, and 
     * setting the en passant square if the move is a pawn push by two squares */
    else if (CCPieceEqualToPiece(pieceType, PawnPiece))
        [self makePawnMove:move withPosition:position];
    
    // Save captured piece information.  If the move was an en passant capture, it has
    // already been saved in makePawnMove(). Requires an if statement since there will
    // not be a piece on the destination square if the move is an en passant capture
    CCColoredPiece capturedPiece = CCBoardGetPieceAtSquare(position.board, to);
    
    // Move the piece from the source square to the destination square
    // Regardless of the special nature of the move (castling, promotion, ep capture),
    // a piece always moves from the source to the destination square
    CCBoardMoveFromSquareToSquare(position.board, from, to);
    
    // Swith side to move and increment ply and halfmove clock
    position.sideToMove = CCColorGetOpposite(self.sideToMove); // Switch side to move
    position.ply = self.ply + 1;
    position.halfmoveClock = self.halfmoveClock + 1;
    
    if (CCColoredPieceIsValid(capturedPiece) || CCPieceEqualToPiece(pieceType, PawnPiece))
        position.halfmoveClock = 0;  // Reset halfmove clock for captures and pawn moves
    
    // Promote immediately if the move has a promoted piece.
    if (CCPieceIsValid(move.promotionPiece))
        [self promotePosition:position withMove:move];
    
    // See if the side that just moved is in check.  If it is, unmake the move
    if ([self inCheck:CCColorGetOpposite(self.sideToMove)])
    {
        NSLog(@"In check after %@", NSStringFromSelector(_cmd));
        [self unmakeMove:move withPosition:position];
    }
}

// Preconditions: Move has been validated and the PieceType at move.from is a rook

- (void)makeRookMove:(CKMove *)move withPosition:(CKPosition *)position
{
    // Reset castling rights when a rook moves
    if (move.from == a1 && self.sideToMove == White)
        position.castlingRights = position.castlingRights & ~CCCastlingRightsWhiteQueenside;
    else if (move.from == h1 && self.sideToMove == White)
        position.castlingRights = position.castlingRights & ~CCCastlingRightsWhiteKingside;
    else if (move.from == a8 && self.sideToMove == Black)
        position.castlingRights = position.castlingRights & ~CCCastlingRightsBlackQueenside;
    else if (move.from == h8 && self.sideToMove == Black)
        position.castlingRights = position.castlingRights & ~CCCastlingRightsBlackKingside;
}


// Preconditions:  Move has been validated and the position's piece at move.from is KingPiece
- (void)makeKingMove:(CKMove *)move withPosition:(CKPosition *)position
{
    // Check to see if the move is a castling move.  Returning true guarantees that king is the right color and
    // on the right square, is castling with a rook that hasn't moved, and all the squares in between are clear.
    // The following logic prevents illegal castling because the king is in / moves through / or moves into check.
    if ([self isMoveCastle:move])
    {
        BOOL shouldCastle = YES;
        CCSquare to = move.to;
        
        // Don't castle if the king is in check
        if ([self inCheck:self.sideToMove])
            shouldCastle = NO;
        
        // Don't castle if destination square is attacked by opposing side
        if (CCBoardIsSquareAttackedByColor(self.board, move.to, CCColorGetOpposite(self.sideToMove)))
            shouldCastle = NO;
        
        // Don't castle if the 
        if ((to == g1) && (CCBoardIsSquareAttackedByColor(self.board, f1, Black)))
            shouldCastle = NO;
        else if ((to == c1) && (CCBoardIsSquareAttackedByColor(self.board, d1, Black)))
            shouldCastle = NO;
        else if ((to == g8) && (CCBoardIsSquareAttackedByColor(self.board, f8, White)))
            shouldCastle = NO;
        else if ((to == c8) && (CCBoardIsSquareAttackedByColor(self.board, d8, White)))
            shouldCastle = NO;
        
        if (shouldCastle)
            [self makeCastleMove:move withPosition:position];
    }
    
    // Reset castling rights for the side that moved the king
    CCCastlingRights rights = (self.sideToMove == White) ? CCCastlingRightsWhiteBoth : CCCastlingRightsBlackBoth;
    position.castlingRights = position.castlingRights & ~rights;
}

// Precondition: the move is a castling move and it is legal to castle in the position
- (void)makeCastleMove:(CKMove *)move withPosition:(CKPosition *)position
{
    // Since we're working with a standard chess position, we can hard code in source and destination
    // squares for castling (e1 is always the white king square, h1 is always the white O-O square, etc.).
    // This will need to be changed in a subclass made to support Chess960.
    // makeMove:withPosition: will take care of moving the king to the appropriate location, so this
    // method only needs to adjust the position of the rook
    if (move.to == g1)
        CCBoardMoveFromSquareToSquare(position.board, h1, f1);
    else if (move.to == c1)
        CCBoardMoveFromSquareToSquare(position.board, a1, d1);
    else if (move.to == g8)
        CCBoardMoveFromSquareToSquare(position.board, h8, f8);
    else if (move.to == c8)
        CCBoardMoveFromSquareToSquare(position.board, a8, d8);
}

- (BOOL)inCheck:(CCColor)color
{
    CCSquare square = CCBoardSquareForKingOfColor(self.board, color);
    return CCBoardIsSquareAttackedByColor(self.board, square, CCColorGetOpposite(color));
}


// Precondition: Move is pseudo-legal and the piece at move.from is a pawn
- (void)makePawnMove:(CKMove *)move withPosition:(CKPosition *)position
{
    if ([self isMoveDoubleJump:move])
    {
        // Set the en passant square for a double jump
        if (self.sideToMove == White)
            position.enPassantSquare = CCSquareNorthOne(move.from);
        else
            self.enPassantSquare = CCSquareSouthOne(move.from);
        return; // Nothing more to do, return early
    }
    
    // Update capture information if the move is an en passant capture
    else if ([self isMoveEnPassantCapture:move])
    {
        CCSquare captureSquare = CCSquareRank(move.to) == 2 ? CCSquareNorthOne(move.to) : CCSquareSouthOne(move.to);
        CCBoardClearSquare(position.board, captureSquare);
    }
    
    // Set the requires promotion flag.  makeMove:withPosition: will attempt to promote if a promotion piece is designated
    else if ([self isMovePromotion:move])
    {
        position.requiresPromotion = true;
    }
    
    // Reset the en passant square.  If the move was a two-square push the ep square was set
    // earlier and the method returned
    position.enPassantSquare = InvalidSquare;
}


- (void)promotePosition:(CKPosition *)position withMove:(CKMove *)move
{
    // Promotion is the last action to occur as part of the make move process
    
    if (move.promotionPiece == QueenPiece || move.promotionPiece == RookPiece ||
        move.promotionPiece == KnightPiece || move.promotionPiece == BishopPiece)
    {
        CCColoredPiece promotionPiece = CCColoredPieceMake(CCColorGetOpposite(position.sideToMove), move.promotionPiece);
        CCBoardSetSquareWithPiece(position.board, move.to, promotionPiece);
    }
}

- (void)makeSaveStateForMove:(CKMove *)move
{
    move.undoState = [self copy];  // Undo state in a naive form - simply copy the current position so it can be restored later.
}

// Undoes a move.  Unmake should be called with the most recent move first.  Subsequent calls
// to unmakeMove:withPosition: should be pass the moves made by makeMove:withPosition: in a stack order. 

- (void)unmakeMove:(CKMove *)move withPosition:(CKPosition *)position
{
    // TODO: Handle null move
    
    CKPosition *undo = move.undoState;
    NSAssert(undo != nil, @"Undo move state is nil");
    
    if (undo)
    {
        position.board = undo.board;
        position.castlingRights = undo.castlingRights;
        position.enPassantSquare = undo.enPassantSquare;
        position.sideToMove = undo.sideToMove;
        position.halfmoveClock = undo.halfmoveClock;
        position.ply = undo.ply;
    }
}

#pragma mark - Move queries

// Preconditions: Assumes that the piece at move.from is an appropriately colored king
- (BOOL)isMoveCastle:(CKMove *)move
{
    CCSquare to = move.to;
    CCSquare from = move.from;
    CCColoredPiece king = CCBoardGetPieceAtSquare(self.board, from);
    CCColor color = CCColoredPieceGetColor(king);
    
    if (color == White)
    {
        if (from != e1 || (to != c1 && to != g1))
            return NO;  // Break early if not on the starting square
        
        // Kingside castle
        if (to == g1)
        {
            // If no castling right or either square is occupied return NO
            if (!(self.castlingRights & CCCastlingRightsWhiteKingside) ||
                CCBoardGetPieceAtSquare(self.board, f1) != NoColoredPiece ||
                CCBoardGetPieceAtSquare(self.board, g1) != NoColoredPiece)
                return NO;
            return YES;
        }
        
        // Queenside castle
        else if (to == c1)
        {
            // If no castling right or any square between the king and rook is occupied return NO
            if (!(self.castlingRights & CCCastlingRightsWhiteQueenside) ||
                CCBoardGetPieceAtSquare(self.board, d1) != NoColoredPiece ||
                CCBoardGetPieceAtSquare(self.board, c1) != NoColoredPiece ||
                CCBoardGetPieceAtSquare(self.board, b1) != NoColoredPiece)
                return NO;
            return YES;
        }
    }
    
    else // color == Black
    {
        if (from != e8 || (to != c8 && to != g8))
            return NO;
        
        // Kingside castle
        if (to == g8)
        {
            // If no castling right or either square is occupied return NO
            if (!(self.castlingRights & CCCastlingRightsBlackKingside) ||
                CCBoardGetPieceAtSquare(self.board, f8) != NoColoredPiece ||
                CCBoardGetPieceAtSquare(self.board, g8) != NoColoredPiece)
                return NO;
            return YES;
        }
        
        else if (to == c8)
        {
            // If no castling right or any square between the king and rook is occupied return NO
            if (!(self.castlingRights & CCCastlingRightsBlackQueenside) ||
                CCBoardGetPieceAtSquare(self.board, d8) != NoColoredPiece ||
                CCBoardGetPieceAtSquare(self.board, c8) != NoColoredPiece ||
                CCBoardGetPieceAtSquare(self.board, b8) != NoColoredPiece)
                return NO;
            return YES;
        }
    }
    
    NSAssert(NO, @"CKPosition isMoveCastle: invalid control sequence");
    return NO;
}

// Preconditions: Move is pseudo-legal and the moving piece is a pawn
- (BOOL)isMoveDoubleJump:(CKMove *)move
{
    CCSquare from = move.from;
    CCSquare to   = move.to;
    CCColoredPiece piece = [self coloredPieceAtSquare:from];
    
    signed char fromRank = CCColoredPieceGetColor(piece) == White ? 1 : 3;
    signed char toRank   = CCColoredPieceGetColor(piece) == White ? 3 : 4;
    
    if ((CCSquareRank(from) != fromRank) || (to != CCSquareMake(toRank, CCSquareFile(to))))
        return NO;
    
    return YES;
}

// Preconditions: Move is pseudo-legal and the moving piece is a pawn
- (BOOL)isMoveEnPassantCapture:(CKMove *)move
{
    CCSquare from = move.from;
    CCSquare to   = move.to;
    
    if (to != self.enPassantSquare)
        return NO;
    
    if (self.sideToMove == White)
    {
        if ((CCSquareNorthEastOne(from) == self.enPassantSquare) || (CCSquareNorthWestOne(from) == self.enPassantSquare))
            return CCColoredPieceEqualsColoredPiece([self coloredPieceAtSquare:CCSquareSouthOne(self.enPassantSquare)], BP);
    }
    
    else // sideToMove == Black
    {
        if ((CCSquareSouthEastOne(from) == self.enPassantSquare) || (CCSquareSouthWestOne(from) == self.enPassantSquare))
            return CCColoredPieceEqualsColoredPiece([self coloredPieceAtSquare:CCSquareNorthOne(self.enPassantSquare)], WP);
    }
    
    return NO;
}

// Preconditions: Move is pseudo-legal and moving piece is a pawn
- (BOOL)isMovePromotion:(CKMove *)move
{
    unsigned char rank = CCSquareRank(move.to);
    return ((rank == 7 && CCColoredPieceEqualsColoredPiece([self coloredPieceAtSquare:move.from], WP))  || 
            (rank == 0 && CCColoredPieceEqualsColoredPiece([self coloredPieceAtSquare:move.from], BP)));
}

#pragma mark - Pseudolegal

- (CCBitboard)slidingAttacksForPiece:(CCPiece)piece atSquare:(CCSquare)square
{
    return CCBitboardGetSlidingAttacks(CCBoardGetOccupiedSquares(self.board), piece, square);
}

- (CCBitboard)pseudoLegalCastleForColor:(CCColor)color
{
    CCBitboard b = EmptyBB;
    
    if (color == White) {
        if (self.castlingRights & CCCastlingRightsWhiteKingside)
            b |= CCBitboardForSquare(g1);
        if (self.castlingRights & CCCastlingRightsWhiteQueenside)
            b |= CCBitboardForSquare(c1);
    }
    
    else
    {
        if (self.castlingRights & CCCastlingRightsBlackKingside)
            b |= CCBitboardForSquare(g8);
        if (self.castlingRights & CCCastlingRightsBlackQueenside)
            b |= CCBitboardForSquare(c8);
    }
    
    return b;
}

- (CCBitboard)pseudoLegalMovesFromSquare:(CCSquare)square
{
    CCColoredPiece piece = [self coloredPieceAtSquare:square];
    CCBitboard b = EmptyBB;
    if (!CCColoredPieceIsValid(piece)) 
        return b; // Return EmptyBB if square doesn't have a piece on it
    
    CCPiece type = CCColoredPieceGetPiece(piece);
    CCColor color = CCColoredPieceGetColor(piece);
    
    if (CCPieceIsSlider(type)) // Rook, bishop, or queen
    {
        // Sliding attacks and squares not occupied by friendly pieces of piece type
        b = ~ CCBoardGetOccupiedSquaresForColor(self.board, color) & [self slidingAttacksForPiece:type atSquare:square];
    }
    
    else if (CCPieceEqualToPiece(type, KnightPiece))
    {
        // Precomputed knight moves and not occupied by friendly pieces of piece type
        b = CCBitboardMovesForPieceAtSquare(type, square) & ~CCBoardGetOccupiedSquaresForColor(self.board, color);
    }
    
    else if (CCPieceEqualToPiece(type, KingPiece))
    {
        b = CCBitboardMovesForPieceAtSquare(type, square) & ~CCBoardGetOccupiedSquaresForColor(self.board, color);
        b |= [self pseudoLegalCastleForColor:color];
    }
    
    else if (CCPieceEqualToPiece(type, PawnPiece))
    {
        CCBitboard pawn = CCBitboardForSquare(square);
        CCBitboard push;
        CCBitboard attack;
        CCBitboard opponents;
        
        if (color == White) {
            push = CCBitboardGetWhitePawnPushTargets(pawn, CCBoardGetEmptySquares(self.board));
            attack    = CCBitboardGetWhitePawnAttacks(pawn);
            opponents = CCBoardGetOccupiedSquaresForColor(self.board, Black);
            
            if (CCSquareRank(self.enPassantSquare) == 5) 
                opponents |= CCBitboardForSquare(self.enPassantSquare);
        } 
        
        else 
        { // color == Black
            push = CCBitboardGetBlackPawnPushTargets(pawn, CCBoardGetEmptySquares(self.board));
            attack = CCBitboardGetBlackPawnAttacks(pawn);
            opponents = CCBoardGetOccupiedSquaresForColor(self.board, White);
            if (CCSquareRank(self.enPassantSquare) == 2)
                opponents |= CCBitboardForSquare(self.enPassantSquare);
        }
        
        b = push | (attack & opponents);
    }
    
    return b;
}

- (BOOL)isMovePseudoLegal:(CKMove *)move
{
    CCSquare to = move.to;
    CCBitboard toBB = CCBitboardForSquare(to);
    CCBitboard moves = [self pseudoLegalMovesFromSquare:move.from];
    
    return (toBB & moves) != 0;
}

#pragma mark - NSObject

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithString:NSStringFromCCBoard(self.board)];
    [desc appendFormat:@"\nCastling Rights: %d", self.castlingRights];
    [desc appendFormat:@"\nSide to move: %@", self.sideToMove == White ? @"White" : @"Black"];
    return desc;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[CKPosition class]] ? [self isEqualToPosition:(CKPosition *)object] : NO;
}

- (BOOL)isEqualToPosition:(CKPosition *)position
{
    if (position == self)
        return YES;
    
    BOOL equal = 
    self.castlingRights == position.castlingRights &&
    self.enPassantSquare == position.enPassantSquare &&
    self.sideToMove == position.sideToMove &&
    //self.halfmoveClock == position.halfmoveClock && // Not checking halfmove clock
    //self.ply == position.ply &&  // Not checking ply
    CCBoardEqualToBoard(self.board, position.board);
    
    return equal;
}

#pragma mark - Class Convenience methods

+ (id)position
{
    return [[self alloc] init];
}

+ (id)positionWithPosition:(CKPosition *)position
{
    return [[self alloc] initWithPosition:position];
}

+ (id)standardPosition
{
    return [[self alloc] initWithStandardPosition];
}


@end
