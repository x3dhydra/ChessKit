//
//  PGNTokenizer.m
//  ChessParser
//
//  Created by Austen Green on 5/22/11.
//  Copyright 2011 Austen Green Consulting. All rights reserved.
//

#import "CKPGNTokenizer.h"

@implementation CKPGNTokenizer

- (id)initWithString:(NSString *)gameText
{
    if (!gameText)
    {
        return nil;
    }
    
    self = [super init];
    if (self)
    {
        scanner = [[NSScanner alloc] initWithString:gameText];
        [scanner setCharactersToBeSkipped:nil];
        [self setupCharacterSets];
    }
    return self;
}


- (NSString *)getNextToken:(CCTokenType *)tokenType
{
    NSString *token = [self nextToken];
    *tokenType = lastToken;    
    return token;
}

- (NSString *)nextToken
{
    NSString *token = nil;
    
    // Check to see if the last token scanned indicates that special scanning behavior should 
    // be used fo grab the next token.  This occurs when starting a tag-pair value '[' or
    // when using an embedded comment '{'.
    if (lastToken == CCTokenBeginTag)
    {
        [scanner scanUpToString:@"\"" intoString:&token];
        token = [token stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (!token)
            token = @"";
        lastToken = CCTokenTagSymbol;
        
        // The next character to be scanned is a " so set the scan location
        // one more character forward so that the quote will be skipped
        [scanner setScanLocation:[scanner scanLocation] + 1];
    }
    
    // Tag symbols are followed by the tag-pair string
    else if (lastToken == CCTokenTagSymbol)
    {
        [scanner scanUpToString:@"\"" intoString:&token];
        if (!token)
            token = @"";
        lastToken = CCTokenString;
        
        // The next character to be scanned is a " so set the scan location
        // one more character forward so that the quote will be skipped
        [scanner setScanLocation:[scanner scanLocation] + 1];
    }
    
    // Annotations are delimited by '{' and '}'.  Simply scan up to the '}' to get the comment token
    else if (lastToken == CCTokenBeginAnnotation)
    {
        // Don't ignore whitespace in parsing the comment
        NSCharacterSet *skippedCharacters = [scanner charactersToBeSkipped];
        [scanner setCharactersToBeSkipped:nil];
        
        [scanner scanUpToString:@"}" intoString:&token];
        lastToken = CCTokenAnnotation;
        
        [scanner setCharactersToBeSkipped:skippedCharacters];
    }
    
    // 
    else
    {
        // Skip whitespace
        [scanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
        
        // Peek at the next character to see if it's self-terminating;
        char c = [self peek];
        if ([selfTerminatingCharacters characterIsMember:c])
        {
            token = [NSString stringWithFormat:@"%c", c];
            switch (c) {
                case '{':
                    lastToken = CCTokenBeginAnnotation;
                    break;
                case '}':
                    lastToken = CCTokenEndAnnotation;
                    break;
                case '(':
                    lastToken = CCTokenBeginRAV;
                    break;
                case ')':
                    lastToken = CCTokenEndRAV;
                    break;
                case '[':
                    lastToken = CCTokenBeginTag;
                    break;
                case ']':
                    lastToken = CCTokenEndTag;
                    break;
                case '.':
                    lastToken = CCTokenPeriod;
                    break;
                case '*':
                    lastToken = CCTokenGameTermination;
                    break;
                case '\0':
                    token = nil;
                    // Fallthrough
                default:
                    lastToken = CCTokenUnrecognized;
                    break;
            }
            
            // Move the scanner forward one character since we didn't need it
            // to find a self-terminating token
            [scanner setScanLocation:[scanner scanLocation] + 1];
        }
        
        // Otherwise it's a symbol
        else
        {
            [scanner scanUpToCharactersFromSet:tokenEndCharacters intoString:&token];
            lastToken = CCTokenSymbol;
            
            switch ([token characterAtIndex:0]) {
                case '0':
                    if ([token isEqualToString:@"0-1"])
                        lastToken = CCTokenGameTermination;
                    break;
                case '1':
                    if ([token isEqualToString:@"1-0"] || [token isEqualToString:@"1/2-1/2"])
                        lastToken = CCTokenGameTermination;
                    break;
                default:
                    break;
            }
        }
    }
    
    if (!token)
        lastToken = CCTokenNull;
    
    return token;
}

// Peeks at the next character to be scanned
- (char)peek
{
    NSString *string = [scanner string];
    NSUInteger location = [scanner scanLocation];
    
    char nextChar = 0;
    if (location < [string length])
        nextChar = [string characterAtIndex:location];
    return nextChar;
}

- (void)setupCharacterSets
{
    selfTerminatingCharacters = [NSCharacterSet characterSetWithCharactersInString:@"{}()[]<>.*"];
    
    NSMutableCharacterSet *tmp = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
    [tmp formUnionWithCharacterSet:selfTerminatingCharacters];
    tokenEndCharacters = [tmp copy];
    
    whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
}

- (NSUInteger)scanLocation
{
    return scanner.scanLocation;
}

@end
