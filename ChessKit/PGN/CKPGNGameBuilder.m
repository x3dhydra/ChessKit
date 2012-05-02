//
//  CKPGNGameBuilder.m
//  ChessKit
//
//  Created by Austen Green on 4/28/12.
//  Copyright (c) 2012 Austen Green Consulting. All rights reserved.
//

#import "CKPGNGameBuilder.h"
#import "ChessKit.h"
#import "CKPGNTokenizer.h"
#import "CKFENHelper.h"
#import "CKSANHelper.h"

static inline BOOL CKTokenIsTagPair(CCTokenType token)
{
    return token == CCTokenBeginTag ||
    token == CCTokenEndTag ||
    token == CCTokenTagSymbol ||
    token == CCTokenString;
}

@interface CKPGNGameBuilder()
{
    CKGame *_game;
    NSDictionary *_metadata;
    NSInteger _variationDepth;
}
@property (nonatomic, strong) NSMutableArray *variationStack;
@end

@implementation CKPGNGameBuilder
@synthesize gameText = _gameText;
@synthesize options = _options;
@synthesize variationStack = _variationStack;

- (id)init
{
    return [self initWithString:nil];
}

- (id)initWithString:(NSString *)gameText
{
    return [self initWithString:gameText options:CKPGNFullFormat];
}

- (id)initWithString:(NSString *)gameText options:(CKGameBuilderOptions)options
{
    self = [super init];
    if (self)
    {
        _options = options;
        _gameText = gameText;
    }
    return self;
}

- (CKGame *)game
{
    if (!_game)
    {
        [self buildGame];
    }
    return _game;
}

- (void)buildGame
{
    CKPGNTokenizer *tokenizer = [[CKPGNTokenizer alloc] initWithString:self.gameText];
    
    CCTokenType tokenType = CCTokenNull;
    NSString *token = nil;
    
    NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
    
    do 
    {
        token = [tokenizer getNextToken:&tokenType];
        
        if (tokenType == CCTokenTagSymbol)
        {
            NSString *key = token;
            NSString *value = [tokenizer getNextToken:&tokenType];
            
            if (tokenType == CCTokenString)
                [metadata setObject:value forKey:key];
        }
        
    } while (token && CKTokenIsTagPair(tokenType));
    
    CKMutablePosition *position = nil;;
    
    NSString *fen = [metadata objectForKey:@"FEN"];
    if (fen)
    {
        CKFENHelper *helper = [[CKFENHelper alloc] init];
        CKPosition *startPosition = [helper positionWithFEN:fen];
        
        // Break early if the FEN position couldn't be processed
        if (!startPosition)
            return;
        
        position = [CKMutablePosition positionWithPosition:startPosition];
    }
    else 
    {
        position = [CKMutablePosition standardPosition];
    }
    
    _metadata = metadata;
    
    // Break early if we only want the metadata
    if (self.options == CKPGNMetadataOnly)
        return;
    
    _game = [[CKGame alloc] initWithStartingPosition:position];
    [_game setMetadata:metadata];
    
    
    
    CKGameTree *tree = _game.gameTree;
    
    CKGameBuilderOptions options = self.options;
    BOOL shouldIgnoreTokens = NO;
    
    do 
    {
        //NSLog(@"Token: %@ - %d", token, tokenType);
        
        switch (tokenType) {
            case CCTokenSymbol:
            {
                if (shouldIgnoreTokens)
                    break;
                
                // Ignore move numbers, which are also processed as symbols
                if (isnumber([token characterAtIndex:0]))
                    break;
                
                //NSLog(@"%@\n%@", token, _game.gameTree.position);
                
                CKMove *move = [CKSANHelper moveFromString:token withPosition:position];
                [tree addMove:move withValidation:NO];
                tree = [tree.children lastObject];
                tree.moveString = token;
                [position makeMove:move];
            }
                break;
            case CCTokenBeginRAV:
            {
                _variationDepth++;
                if (options == CKPGNReducedFormat)
                    shouldIgnoreTokens = YES;
                else {
                    [self.variationStack addObject:tree];
                    tree = tree.parent;
                    position = [CKMutablePosition positionWithPosition:tree.position];
                }
                break;
            }
            case CCTokenEndRAV:
            {
                _variationDepth--;
                if (options == CKPGNReducedFormat && _variationDepth == 0)
                    shouldIgnoreTokens = NO;
                else if (options == CKPGNFullFormat) {
                    tree = [self.variationStack lastObject];
                    position = [CKMutablePosition positionWithPosition:tree.position];
                    [self.variationStack removeLastObject];
                }
                break;
            }
            case CCTokenAnnotation:
                //if (options == CKPGNFullFormat)
                {
                    tree.comment = token;
                }
                break;
            default:
                break;
        }
        token = [tokenizer getNextToken:&tokenType];
    } while (token && tokenType != CCTokenGameTermination);
    
    //NSLog(@"%@ %@", _game.gameTree,  _game.gameTree.position);
}

- (NSMutableArray *)variationStack
{
    if (!_variationStack)
        _variationStack = [[NSMutableArray alloc] init];
    return _variationStack;
}

- (NSDictionary *)metadata
{
    if (!_metadata)
    {
        [self buildGame];
    }
    return _metadata;
}

@end
