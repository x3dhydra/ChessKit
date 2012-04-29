//
//  PGNTokenizer.h
//  ChessParser
//
//  Created by Austen Green on 5/22/11.
//  Copyright 2011 Austen Green Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tokens.h"

@interface CKPGNTokenizer : NSObject {
    NSScanner *scanner;
    CCTokenType lastToken;
    
    // Character sets
    NSCharacterSet *tokenEndCharacters;
    NSCharacterSet *selfTerminatingCharacters;
    NSCharacterSet *whiteSpace;
}

- (id)initWithString:(NSString *)gameText;
- (void)scan;
- (NSString *)nextToken;
- (NSString *)getNextToken:(CCTokenType *)tokenType;
- (char)peek;
- (void)setupCharacterSets;

@end
